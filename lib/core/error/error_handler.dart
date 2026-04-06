import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';

/// Centralized error handling utilities for repositories and use cases
class ErrorHandler {
  /// Maps exceptions to failures with proper error messages
  static Either<Failure, T> handleError<T>(dynamic error) {
    if (error is ServerException) {
      return Left(ServerFailure(message: error.message));
    } else if (error is NetworkException) {
      return Left(NetworkFailure(message: error.message));
    } else if (error is CacheException) {
      return Left(CacheFailure(error.message));
    } else {
      return Left(UnknownFailure(error.toString()));
    }
  }

  /// Handles errors with fallback data for book lists
  static Either<Failure, List<T>> handleListErrorWithFallback<T>(
    dynamic error,
    List<T>? fallbackData,
  ) {
    if (fallbackData != null && fallbackData.isNotEmpty) {
      // If we have fallback data, return it instead of error
      return Right(fallbackData);
    }
    return handleError<List<T>>(error);
  }

  /// Generic try-catch wrapper for async operations
  static Future<Either<Failure, T>> safeExecute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (error) {
      return handleError<T>(error);
    }
  }

  /// Safe execution with fallback for data operations
  static Future<Either<Failure, T>> safeExecuteWithFallback<T>(
    Future<T> Function() operation,
    Future<T> Function() fallbackOperation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (error) {
      try {
        final fallbackResult = await fallbackOperation();
        return Right(fallbackResult);
      } catch (fallbackError) {
        return handleError<T>(fallbackError);
      }
    }
  }

  /// Map common error messages to user-friendly messages
  static String getUserFriendlyMessage(String errorMessage) {
    if (errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (errorMessage.toLowerCase().contains('server')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (errorMessage.toLowerCase().contains('cache')) {
      return 'Unable to load cached data. Please refresh and try again.';
    } else if (errorMessage.toLowerCase().contains('not found')) {
      return 'The requested content could not be found.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
