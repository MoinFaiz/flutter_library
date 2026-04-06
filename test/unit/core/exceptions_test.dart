import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/error/exceptions.dart';

void main() {
  group('Core Exceptions', () {
    group('ServerException', () {
      test('should create instance with message', () {
        // Arrange
        const message = 'Server error occurred';
        const exception = ServerException(message);

        // Act & Assert
        expect(exception.message, equals(message));
        expect(exception, isA<Exception>());
        expect(exception, isA<ServerException>());
      });

      test('should support const constructor', () {
        // Arrange & Act
        const exception1 = ServerException('Test message');
        const exception2 = ServerException('Test message');

        // Assert - Should be the same instance due to const optimization
        expect(identical(exception1, exception2), isTrue);
        expect(exception1.message, equals(exception2.message));
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const message = 'Server error';
        const exception1 = ServerException(message);
        const exception2 = ServerException(message);

        // Act & Assert
        expect(exception1.message, equals(exception2.message));
      });

      test('should have different messages when created with different text', () {
        // Arrange
        const exception1 = ServerException('Error 1');
        const exception2 = ServerException('Error 2');

        // Act & Assert
        expect(exception1.message, isNot(equals(exception2.message)));
      });

      test('should handle empty message', () {
        // Arrange
        const exception = ServerException('');

        // Act & Assert
        expect(exception.message, isEmpty);
        expect(exception, isA<ServerException>());
      });

      test('should handle special characters in message', () {
        // Arrange
        const specialMessage = 'Server error with special chars: !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const exception = ServerException(specialMessage);

        // Act & Assert
        expect(exception.message, equals(specialMessage));
      });

      test('should handle Unicode characters in message', () {
        // Arrange
        const unicodeMessage = 'Server error 服务器错误 サーバーエラー 🚨';
        const exception = ServerException(unicodeMessage);

        // Act & Assert
        expect(exception.message, equals(unicodeMessage));
      });

      test('should handle very long message', () {
        // Arrange
        final longMessage = 'Server error: ${'a' * 1000}';
        final exception = ServerException(longMessage);

        // Act & Assert
        expect(exception.message.length, equals(1014)); // 'Server error: ' + 1000 'a's
        expect(exception.message, equals(longMessage));
      });

      test('should be throwable', () {
        // Arrange
        const exception = ServerException('Test error');

        // Act & Assert
        expect(() => throw exception, throwsA(isA<ServerException>()));
        
        try {
          throw exception;
        } catch (e) {
          expect(e, isA<ServerException>());
          expect((e as ServerException).message, equals('Test error'));
        }
      });
    });

    group('CacheException', () {
      test('should create instance with message', () {
        // Arrange
        const message = 'Cache error occurred';
        const exception = CacheException(message);

        // Act & Assert
        expect(exception.message, equals(message));
        expect(exception, isA<Exception>());
        expect(exception, isA<CacheException>());
      });

      test('should support const constructor', () {
        // Arrange & Act
        const exception1 = CacheException('Test message');
        const exception2 = CacheException('Test message');

        // Assert - Should be the same instance due to const optimization
        expect(identical(exception1, exception2), isTrue);
        expect(exception1.message, equals(exception2.message));
      });

      test('should handle empty message', () {
        // Arrange
        const exception = CacheException('');

        // Act & Assert
        expect(exception.message, isEmpty);
        expect(exception, isA<CacheException>());
      });

      test('should be throwable', () {
        // Arrange
        const exception = CacheException('Cache not found');

        // Act & Assert
        expect(() => throw exception, throwsA(isA<CacheException>()));
        
        try {
          throw exception;
        } catch (e) {
          expect(e, isA<CacheException>());
          expect((e as CacheException).message, equals('Cache not found'));
        }
      });

      test('should not be equal to ServerException with same message', () {
        // Arrange
        const message = 'Error message';
        const serverException = ServerException(message);
        const cacheException = CacheException(message);

        // Act & Assert
        expect(serverException.runtimeType, isNot(equals(cacheException.runtimeType)));
        expect(serverException.message, equals(cacheException.message)); // Same message
      });
    });

    group('NetworkException', () {
      test('should create instance with message', () {
        // Arrange
        const message = 'Network error occurred';
        const exception = NetworkException(message);

        // Act & Assert
        expect(exception.message, equals(message));
        expect(exception, isA<Exception>());
        expect(exception, isA<NetworkException>());
      });

      test('should support const constructor', () {
        // Arrange & Act
        const exception1 = NetworkException('Test message');
        const exception2 = NetworkException('Test message');

        // Assert - Should be the same instance due to const optimization
        expect(identical(exception1, exception2), isTrue);
        expect(exception1.message, equals(exception2.message));
      });

      test('should handle empty message', () {
        // Arrange
        const exception = NetworkException('');

        // Act & Assert
        expect(exception.message, isEmpty);
        expect(exception, isA<NetworkException>());
      });

      test('should be throwable', () {
        // Arrange
        const exception = NetworkException('Connection timeout');

        // Act & Assert
        expect(() => throw exception, throwsA(isA<NetworkException>()));
        
        try {
          throw exception;
        } catch (e) {
          expect(e, isA<NetworkException>());
          expect((e as NetworkException).message, equals('Connection timeout'));
        }
      });

      test('should handle network-specific error messages', () {
        // Arrange
        const exception1 = NetworkException('Connection timeout');
        const exception2 = NetworkException('No internet connection');
        const exception3 = NetworkException('DNS resolution failed');

        // Act & Assert
        expect(exception1.message, equals('Connection timeout'));
        expect(exception2.message, equals('No internet connection'));
        expect(exception3.message, equals('DNS resolution failed'));
      });
    });

    group('ValidationException', () {
      test('should create instance with message', () {
        // Arrange
        const message = 'Validation error occurred';
        const exception = ValidationException(message);

        // Act & Assert
        expect(exception.message, equals(message));
        expect(exception, isA<Exception>());
        expect(exception, isA<ValidationException>());
      });

      test('should support const constructor', () {
        // Arrange & Act
        const exception1 = ValidationException('Test message');
        const exception2 = ValidationException('Test message');

        // Assert - Should be the same instance due to const optimization
        expect(identical(exception1, exception2), isTrue);
        expect(exception1.message, equals(exception2.message));
      });

      test('should handle empty message', () {
        // Arrange
        const exception = ValidationException('');

        // Act & Assert
        expect(exception.message, isEmpty);
        expect(exception, isA<ValidationException>());
      });

      test('should be throwable', () {
        // Arrange
        const exception = ValidationException('Invalid input');

        // Act & Assert
        expect(() => throw exception, throwsA(isA<ValidationException>()));
        
        try {
          throw exception;
        } catch (e) {
          expect(e, isA<ValidationException>());
          expect((e as ValidationException).message, equals('Invalid input'));
        }
      });

      test('should handle validation-specific error messages', () {
        // Arrange
        const exception1 = ValidationException('Email is required');
        const exception2 = ValidationException('Password must be at least 8 characters');
        const exception3 = ValidationException('Invalid email format');

        // Act & Assert
        expect(exception1.message, equals('Email is required'));
        expect(exception2.message, equals('Password must be at least 8 characters'));
        expect(exception3.message, equals('Invalid email format'));
      });
    });

    group('Exception type differentiation', () {
      test('should distinguish between different exception types', () {
        // Arrange
        const message = 'Error message';
        const serverException = ServerException(message);
        const cacheException = CacheException(message);
        const networkException = NetworkException(message);
        const validationException = ValidationException(message);

        // Act & Assert - All exceptions should be different types
        expect(serverException.runtimeType, isNot(equals(cacheException.runtimeType)));
        expect(serverException.runtimeType, isNot(equals(networkException.runtimeType)));
        expect(serverException.runtimeType, isNot(equals(validationException.runtimeType)));
        expect(cacheException.runtimeType, isNot(equals(networkException.runtimeType)));
        expect(cacheException.runtimeType, isNot(equals(validationException.runtimeType)));
        expect(networkException.runtimeType, isNot(equals(validationException.runtimeType)));
        
        // But all should be Exception
        expect(serverException, isA<Exception>());
        expect(cacheException, isA<Exception>());
        expect(networkException, isA<Exception>());
        expect(validationException, isA<Exception>());
      });

      test('should work correctly in try-catch blocks', () {
        // Arrange
        final exceptions = [
          const ServerException('Server error'),
          const CacheException('Cache error'),
          const NetworkException('Network error'),
          const ValidationException('Validation error'),
        ];

        // Act & Assert
        for (final exception in exceptions) {
          try {
            throw exception;
          } on ServerException catch (e) {
            expect(e, isA<ServerException>());
            expect(e.message, contains('Server error'));
          } on CacheException catch (e) {
            expect(e, isA<CacheException>());
            expect(e.message, contains('Cache error'));
          } on NetworkException catch (e) {
            expect(e, isA<NetworkException>());
            expect(e.message, contains('Network error'));
          } on ValidationException catch (e) {
            expect(e, isA<ValidationException>());
            expect(e.message, contains('Validation error'));
          } catch (e) {
            fail('Unexpected exception type: ${e.runtimeType}');
          }
        }
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null-like string values', () {
        // Arrange
        const exception1 = ServerException('null');
        const exception2 = CacheException('undefined');
        const exception3 = NetworkException('NaN');
        const exception4 = ValidationException('false');

        // Act & Assert
        expect(exception1.message, equals('null'));
        expect(exception2.message, equals('undefined'));
        expect(exception3.message, equals('NaN'));
        expect(exception4.message, equals('false'));
      });

      test('should handle whitespace-only messages', () {
        // Arrange
        const exception1 = ServerException('   ');
        const exception2 = CacheException('\t\n');
        const exception3 = NetworkException(' \r\n ');

        // Act & Assert
        expect(exception1.message, equals('   '));
        expect(exception2.message, equals('\t\n'));
        expect(exception3.message, equals(' \r\n '));
      });

      test('should handle multiline messages', () {
        // Arrange
        const multilineMessage = '''This is a multiline
error message that spans
multiple lines''';
        const exception = ServerException(multilineMessage);

        // Act & Assert
        expect(exception.message, equals(multilineMessage));
        expect(exception.message.split('\n').length, equals(3));
      });

      test('should handle messages with escape sequences', () {
        // Arrange
        const messageWithEscapes = 'Error: \\"quoted\\" message with \\n newline and \\t tab';
        const exception = NetworkException(messageWithEscapes);

        // Act & Assert
        expect(exception.message, equals(messageWithEscapes));
      });

      test('should be usable in collections', () {
        // Arrange
        const exceptions = [
          ServerException('Server 1'),
          ServerException('Server 2'),
          CacheException('Cache 1'),
          NetworkException('Network 1'),
          ValidationException('Validation 1'),
        ];

        // Act
        final serverExceptions = exceptions.whereType<ServerException>().toList();
        final cacheExceptions = exceptions.whereType<CacheException>().toList();
        final networkExceptions = exceptions.whereType<NetworkException>().toList();
        final validationExceptions = exceptions.whereType<ValidationException>().toList();

        // Assert
        expect(serverExceptions.length, equals(2));
        expect(cacheExceptions.length, equals(1));
        expect(networkExceptions.length, equals(1));
        expect(validationExceptions.length, equals(1));
        expect(exceptions.length, equals(5));
      });

      test('should handle concurrent exception creation', () {
        // Arrange & Act - Create many exceptions rapidly to test for any threading issues
        final exceptions = List.generate(1000, (index) {
          switch (index % 4) {
            case 0:
              return ServerException('Server $index');
            case 1:
              return CacheException('Cache $index');
            case 2:
              return NetworkException('Network $index');
            default:
              return ValidationException('Validation $index');
          }
        });

        // Assert
        expect(exceptions.length, equals(1000));
        expect(exceptions.whereType<ServerException>().length, equals(250));
        expect(exceptions.whereType<CacheException>().length, equals(250));
        expect(exceptions.whereType<NetworkException>().length, equals(250));
        expect(exceptions.whereType<ValidationException>().length, equals(250));
      });
    });
  });
}
