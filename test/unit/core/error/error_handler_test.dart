import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/error_handler.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('handleError', () {
      test('should return ServerFailure when ServerException is thrown', () {
        // Arrange
        const exception = ServerException('Server error message');

        // Act
        final result = ErrorHandler.handleError<String>(exception);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, equals('Server error message'));
          },
          (_) => fail('Should return ServerFailure'),
        );
      });

      test('should return NetworkFailure when NetworkException is thrown', () {
        // Arrange
        const exception = NetworkException('Network error message');

        // Act
        final result = ErrorHandler.handleError<String>(exception);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, equals('Network error message'));
          },
          (_) => fail('Should return NetworkFailure'),
        );
      });

      test('should return CacheFailure when CacheException is thrown', () {
        // Arrange
        const exception = CacheException('Cache error message');

        // Act
        final result = ErrorHandler.handleError<String>(exception);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, equals('Cache error message'));
          },
          (_) => fail('Should return CacheFailure'),
        );
      });

      test('should return UnknownFailure when unknown exception is thrown', () {
        // Arrange
        const exception = 'Unknown error';

        // Act
        final result = ErrorHandler.handleError<String>(exception);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.message, equals('Unknown error'));
          },
          (_) => fail('Should return UnknownFailure'),
        );
      });

      test('should handle FormatException correctly', () {
        // Arrange
        final exception = FormatException('Invalid format');

        // Act
        final result = ErrorHandler.handleError<String>(exception);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.message, contains('Invalid format'));
          },
          (_) => fail('Should return UnknownFailure'),
        );
      });
    });

    group('handleListErrorWithFallback', () {
      test('should return fallback data when available and error occurs', () {
        // Arrange
        const error = 'Network error';
        const fallbackData = ['item1', 'item2'];

        // Act
        final result = ErrorHandler.handleListErrorWithFallback<String>(
          error,
          fallbackData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (_) => fail('Should return fallback data'),
          (data) => expect(data, equals(fallbackData)),
        );
      });

      test('should return error when no fallback data available', () {
        // Arrange
        const error = ServerException('Server error');

        // Act
        final result = ErrorHandler.handleListErrorWithFallback<String>(
          error,
          null,
        );

        // Assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, equals('Server error'));
          },
          (_) => fail('Should return error'),
        );
      });

      test('should return error when fallback data is empty', () {
        // Arrange
        const error = NetworkException('Network error');
        const emptyFallback = <String>[];

        // Act
        final result = ErrorHandler.handleListErrorWithFallback<String>(
          error,
          emptyFallback,
        );

        // Assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, equals('Network error'));
          },
          (_) => fail('Should return error'),
        );
      });
    });

    group('safeExecute', () {
      test('should return success result when operation completes successfully', () async {
        // Arrange
        const expectedResult = 'Success';
        Future<String> operation() async => expectedResult;

        // Act
        final result = await ErrorHandler.safeExecute(operation);

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, equals(expectedResult)),
        );
      });

      test('should return failure when operation throws exception', () async {
        // Arrange
        const exception = ServerException('Operation failed');
        Future<String> operation() async => throw exception;

        // Act
        final result = await ErrorHandler.safeExecute(operation);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, equals('Operation failed'));
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should handle async operation with delay', () async {
        // Arrange
        const expectedResult = 42;
        Future<int> operation() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return expectedResult;
        }

        // Act
        final result = await ErrorHandler.safeExecute(operation);

        // Assert
        expect(result, isA<Right<Failure, int>>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, equals(expectedResult)),
        );
      });
    });

    group('safeExecuteWithFallback', () {
      test('should return primary result when operation succeeds', () async {
        // Arrange
        const primaryResult = 'Primary';
        const fallbackResult = 'Fallback';
        Future<String> primaryOperation() async => primaryResult;
        Future<String> fallbackOperation() async => fallbackResult;

        // Act
        final result = await ErrorHandler.safeExecuteWithFallback(
          primaryOperation,
          fallbackOperation,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, equals(primaryResult)),
        );
      });

      test('should return fallback result when primary operation fails', () async {
        // Arrange
        const fallbackResult = 'Fallback';
        Future<String> primaryOperation() async => throw const ServerException('Primary failed');
        Future<String> fallbackOperation() async => fallbackResult;

        // Act
        final result = await ErrorHandler.safeExecuteWithFallback(
          primaryOperation,
          fallbackOperation,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Should return fallback success'),
          (data) => expect(data, equals(fallbackResult)),
        );
      });

      test('should return failure when both operations fail', () async {
        // Arrange
        Future<String> primaryOperation() async => throw const ServerException('Primary failed');
        Future<String> fallbackOperation() async => throw const NetworkException('Fallback failed');

        // Act
        final result = await ErrorHandler.safeExecuteWithFallback(
          primaryOperation,
          fallbackOperation,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, equals('Fallback failed'));
          },
          (_) => fail('Should return failure'),
        );
      });
    });

    group('getUserFriendlyMessage', () {
      test('should return network-specific message for network errors', () {
        // Arrange
        const errorMessages = [
          'Network connection failed',
          'Connection timeout occurred',
          'No internet connection available',
        ];

        // Act & Assert
        for (final errorMessage in errorMessages) {
          final result = ErrorHandler.getUserFriendlyMessage(errorMessage);
          expect(
            result,
            equals('Please check your internet connection and try again.'),
          );
        }
      });

      test('should return server-specific message for server errors', () {
        // Arrange
        const errorMessages = [
          'Server error occurred',
          'Internal server failure',
          'Server unavailable',
        ];

        // Act & Assert
        for (final errorMessage in errorMessages) {
          final result = ErrorHandler.getUserFriendlyMessage(errorMessage);
          expect(
            result,
            equals('Service temporarily unavailable. Please try again later.'),
          );
        }
      });

      test('should return cache-specific message for cache errors', () {
        // Arrange
        const errorMessages = [
          'Cache error occurred',
          'Cache data corrupted',
          'Cache unavailable',
        ];

        // Act & Assert
        for (final errorMessage in errorMessages) {
          final result = ErrorHandler.getUserFriendlyMessage(errorMessage);
          expect(
            result,
            equals('Unable to load cached data. Please refresh and try again.'),
          );
        }
      });

      test('should return not found message for not found errors', () {
        // Arrange
        const errorMessages = [
          'Resource not found',
          'Book not found',
          'User not found',
        ];

        // Act & Assert
        for (final errorMessage in errorMessages) {
          final result = ErrorHandler.getUserFriendlyMessage(errorMessage);
          expect(
            result,
            equals('The requested content could not be found.'),
          );
        }
      });

      test('should return generic message for unknown errors', () {
        // Arrange
        const errorMessages = [
          'Unknown error',
          'Unexpected failure',
          'Random error message',
        ];

        // Act & Assert
        for (final errorMessage in errorMessages) {
          final result = ErrorHandler.getUserFriendlyMessage(errorMessage);
          expect(
            result,
            equals('Something went wrong. Please try again.'),
          );
        }
      });

      test('should handle case insensitive error matching', () {
        // Arrange
        const errorMessages = [
          'NETWORK ERROR',
          'Network Error',
          'network error',
          'SERVER FAILURE',
          'Cache Error',
        ];

        // Act & Assert
        expect(
          ErrorHandler.getUserFriendlyMessage(errorMessages[0]),
          equals('Please check your internet connection and try again.'),
        );
        expect(
          ErrorHandler.getUserFriendlyMessage(errorMessages[1]),
          equals('Please check your internet connection and try again.'),
        );
        expect(
          ErrorHandler.getUserFriendlyMessage(errorMessages[2]),
          equals('Please check your internet connection and try again.'),
        );
        expect(
          ErrorHandler.getUserFriendlyMessage(errorMessages[3]),
          equals('Service temporarily unavailable. Please try again later.'),
        );
        expect(
          ErrorHandler.getUserFriendlyMessage(errorMessages[4]),
          equals('Unable to load cached data. Please refresh and try again.'),
        );
      });
    });
  });
}
