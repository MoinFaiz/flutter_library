import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';
import 'package:flutter_library/features/book_details/data/datasources/book_operations_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';

/// Implementation of BookOperationsRepository
class BookOperationsRepositoryImpl implements BookOperationsRepository {
  final BookOperationsRemoteDataSource remoteDataSource;
  final RentalStatusLocalDataSource? rentalStatusLocalDataSource;

  BookOperationsRepositoryImpl({
    required this.remoteDataSource,
    this.rentalStatusLocalDataSource,
  });

  @override
  Future<Either<Failure, Book>> rentBook(String bookId) async {
    try {
      final book = await remoteDataSource.rentBook(bookId);
      
      // Invalidate rental status cache since status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to rent book: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> buyBook(String bookId) async {
    try {
      final book = await remoteDataSource.buyBook(bookId);
      
      // Invalidate rental status cache since status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to buy book: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> returnBook(String bookId) async {
    try {
      final book = await remoteDataSource.returnBook(bookId);
      
      // Invalidate rental status cache since status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to return book: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> renewBook(String bookId) async {
    try {
      final book = await remoteDataSource.renewBook(bookId);
      
      // Invalidate rental status cache since status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to renew book: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> addToCart(String bookId) async {
    try {
      final book = await remoteDataSource.addToCart(bookId);
      
      // Invalidate rental status cache since cart status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to add book to cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> removeFromCart(String bookId) async {
    try {
      final book = await remoteDataSource.removeFromCart(bookId);
      
      // Invalidate rental status cache since cart status changed
      await _invalidateRentalStatusCache(bookId);
      
      return Right(book);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to remove book from cart: $e'));
    }
  }

  /// Invalidate rental status cache for a book after operations
  Future<void> _invalidateRentalStatusCache(String bookId) async {
    await rentalStatusLocalDataSource?.clearCacheForBook(bookId);
  }

  /// Handle Dio errors and convert them to appropriate failures
  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            return ServerFailure(message: 'Client error: ${e.response?.data ?? e.message}');
          } else if (statusCode >= 500) {
            return const ServerFailure(message: 'Server error');
          }
        }
        return ServerFailure(message: 'Bad response: ${e.message}');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'No internet connection');
      case DioExceptionType.badCertificate:
        return const NetworkFailure(message: 'Certificate error');
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request cancelled');
      case DioExceptionType.unknown:
        return NetworkFailure(message: 'Network error: ${e.message}');
    }
  }
}
