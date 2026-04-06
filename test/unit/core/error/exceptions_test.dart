import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/error/exceptions.dart';

void main() {
  group('Exceptions Tests', () {
    group('ServerException', () {
      test('should create ServerException with message', () {
        const exception = ServerException('Server error');
        expect(exception, isA<ServerException>());
        expect(exception.message, equals('Server error'));
      });

      test('should be an Exception', () {
        const exception = ServerException('Error');
        expect(exception, isA<Exception>());
      });

      test('should handle empty message', () {
        const exception = ServerException('');
        expect(exception.message, equals(''));
      });

      test('should handle long message', () {
        const longMessage = 'This is a very long error message that describes the server error in detail';
        const exception = ServerException(longMessage);
        expect(exception.message, equals(longMessage));
      });

      test('should be const constructible', () {
        const exception1 = ServerException('Error');
        const exception2 = ServerException('Error');
        // Test that const constructor works (compile-time check)
        expect(exception1.message, equals(exception2.message));
      });
    });

    group('CacheException', () {
      test('should create CacheException with message', () {
        const exception = CacheException('Cache error');
        expect(exception, isA<CacheException>());
        expect(exception.message, equals('Cache error'));
      });

      test('should be an Exception', () {
        const exception = CacheException('Error');
        expect(exception, isA<Exception>());
      });

      test('should handle empty message', () {
        const exception = CacheException('');
        expect(exception.message, equals(''));
      });

      test('should handle cache-specific messages', () {
        const exception = CacheException('Failed to read from cache');
        expect(exception.message, contains('cache'));
      });

      test('should be const constructible', () {
        const exception1 = CacheException('Error');
        const exception2 = CacheException('Error');
        expect(exception1.message, equals(exception2.message));
      });
    });

    group('NetworkException', () {
      test('should create NetworkException with message', () {
        const exception = NetworkException('Network error');
        expect(exception, isA<NetworkException>());
        expect(exception.message, equals('Network error'));
      });

      test('should be an Exception', () {
        const exception = NetworkException('Error');
        expect(exception, isA<Exception>());
      });

      test('should handle empty message', () {
        const exception = NetworkException('');
        expect(exception.message, equals(''));
      });

      test('should handle network-specific messages', () {
        const exception = NetworkException('No internet connection');
        expect(exception.message, contains('internet'));
      });

      test('should be const constructible', () {
        const exception1 = NetworkException('Error');
        const exception2 = NetworkException('Error');
        expect(exception1.message, equals(exception2.message));
      });
    });

    group('ValidationException', () {
      test('should create ValidationException with message', () {
        const exception = ValidationException('Validation error');
        expect(exception, isA<ValidationException>());
        expect(exception.message, equals('Validation error'));
      });

      test('should be an Exception', () {
        const exception = ValidationException('Error');
        expect(exception, isA<Exception>());
      });

      test('should handle empty message', () {
        const exception = ValidationException('');
        expect(exception.message, equals(''));
      });

      test('should handle validation-specific messages', () {
        const exception = ValidationException('Invalid input format');
        expect(exception.message, contains('Invalid'));
      });

      test('should be const constructible', () {
        const exception1 = ValidationException('Error');
        const exception2 = ValidationException('Error');
        expect(exception1.message, equals(exception2.message));
      });
    });

    group('Exception Comparison', () {
      test('should differentiate between exception types', () {
        const serverEx = ServerException('Error');
        const cacheEx = CacheException('Error');
        const networkEx = NetworkException('Error');
        const validationEx = ValidationException('Error');

        expect(serverEx, isNot(isA<CacheException>()));
        expect(cacheEx, isNot(isA<NetworkException>()));
        expect(networkEx, isNot(isA<ValidationException>()));
        expect(validationEx, isNot(isA<ServerException>()));
      });

      test('should all be Exception instances', () {
        const exceptions = [
          ServerException('Error'),
          CacheException('Error'),
          NetworkException('Error'),
          ValidationException('Error'),
        ];

        for (final exception in exceptions) {
          expect(exception, isA<Exception>());
        }
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in messages', () {
        const exception = ServerException('Error: @#\$%^&*()');
        expect(exception.message, contains('@#\$%'));
      });

      test('should handle unicode characters', () {
        const exception = CacheException('Fehler: Ungültige Daten');
        expect(exception.message, contains('Ungültige'));
      });

      test('should handle newlines in messages', () {
        const exception = NetworkException('Error\nLine 2');
        expect(exception.message, contains('\n'));
      });

      test('should handle very long messages', () {
        final longMessage = 'Error ' * 1000;
        final exception = ValidationException(longMessage);
        expect(exception.message.length, greaterThan(1000));
      });
    });

    group('Throwable Behavior', () {
      test('ServerException should be throwable', () {
        expect(
          () => throw const ServerException('Error'),
          throwsA(isA<ServerException>()),
        );
      });

      test('CacheException should be throwable', () {
        expect(
          () => throw const CacheException('Error'),
          throwsA(isA<CacheException>()),
        );
      });

      test('NetworkException should be throwable', () {
        expect(
          () => throw const NetworkException('Error'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('ValidationException should be throwable', () {
        expect(
          () => throw const ValidationException('Error'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should catch specific exception types', () {
        try {
          throw const ServerException('Server error');
        } on ServerException catch (e) {
          expect(e.message, equals('Server error'));
        }
      });

      test('should catch as general Exception', () {
        try {
          throw const NetworkException('Network error');
        } on Exception catch (e) {
          expect(e, isA<NetworkException>());
        }
      });
    });
  });
}
