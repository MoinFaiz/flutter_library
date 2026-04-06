import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final cartItems = await remoteDataSource.getCartItems();
      await localDataSource.cacheCartItems(cartItems);
      return Right(cartItems);
    } on ServerException catch (e) {
      try {
        final cachedItems = await localDataSource.getCachedCartItems();
        if (cachedItems.isNotEmpty) {
          return Right(cachedItems);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartItem>> addToCart({
    required String bookId,
    required CartItemType type,
    int rentalPeriodInDays = 14,
  }) async {
    try {
      final cartItem = await remoteDataSource.addToCart(
        bookId: bookId,
        type: type,
        rentalPeriodInDays: rentalPeriodInDays,
      );
      return Right(cartItem);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String cartItemId) async {
    try {
      await remoteDataSource.removeFromCart(cartItemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartRequest>> sendRentalRequest({
    required String bookId,
    required int rentalPeriodInDays,
  }) async {
    try {
      final request = await remoteDataSource.sendRentalRequest(
        bookId: bookId,
        rentalPeriodInDays: rentalPeriodInDays,
      );
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartRequest>> sendPurchaseRequest({
    required String bookId,
  }) async {
    try {
      final request = await remoteDataSource.sendPurchaseRequest(
        bookId: bookId,
      );
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartRequest>>> getMyRequests() async {
    try {
      final requests = await remoteDataSource.getMyRequests();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartRequest>>> getReceivedRequests() async {
    try {
      final requests = await remoteDataSource.getReceivedRequests();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptRequest(String requestId) async {
    try {
      await remoteDataSource.acceptRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(String requestId, {String? reason}) async {
    try {
      await remoteDataSource.rejectRequest(requestId, reason: reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      final total = await remoteDataSource.getCartTotal();
      return Right(total);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
