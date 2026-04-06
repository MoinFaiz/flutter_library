import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';

class CartNotificationRepositoryImpl implements CartNotificationRepository {
  final CartNotificationRemoteDataSource remoteDataSource;
  final CartNotificationLocalDataSource localDataSource;

  CartNotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CartNotification>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      await localDataSource.cacheNotifications(notifications);
      return Right(notifications);
    } on ServerException catch (e) {
      try {
        final cachedNotifications = await localDataSource.getCachedNotifications();
        if (cachedNotifications.isNotEmpty) {
          return Right(cachedNotifications);
        }
      } catch (_) {}
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      await localDataSource.cacheUnreadCount(count);
      return Right(count);
    } on ServerException catch (e) {
      try {
        final cachedCount = await localDataSource.getCachedUnreadCount();
        return Right(cachedCount);
      } catch (_) {}
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<CartNotification>> watchNotifications() {
    return remoteDataSource.watchNotifications();
  }
}
