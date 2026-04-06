import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/error/failures.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should have default message when no message provided', () {
        // Arrange & Act
        const failure = ServerFailure();

        // Assert
        expect(failure.message, equals('Server error occurred'));
        expect(failure.props, ['Server error occurred']);
      });

      test('should use custom message when provided', () {
        // Arrange & Act
        const customMessage = 'Custom server error';
        const failure = ServerFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
        expect(failure.props, [customMessage]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = ServerFailure(message: 'Same message');
        const failure2 = ServerFailure(message: 'Same message');

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should not be equal when messages are different', () {
        // Arrange
        const failure1 = ServerFailure(message: 'Message 1');
        const failure2 = ServerFailure(message: 'Message 2');

        // Act & Assert
        expect(failure1, isNot(equals(failure2)));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = ServerFailure();

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('CacheFailure', () {
      test('should have correct message', () {
        // Arrange
        const message = 'Cache error occurred';
        const failure = CacheFailure(message);

        // Act & Assert
        expect(failure.message, equals(message));
        expect(failure.props, [message]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const message = 'Cache error';
        const failure1 = CacheFailure(message);
        const failure2 = CacheFailure(message);

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = CacheFailure('Test message');

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('NetworkFailure', () {
      test('should have default message when no message provided', () {
        // Arrange & Act
        const failure = NetworkFailure();

        // Assert
        expect(failure.message, equals('No internet connection'));
        expect(failure.props, ['No internet connection']);
      });

      test('should use custom message when provided', () {
        // Arrange & Act
        const customMessage = 'Custom network error';
        const failure = NetworkFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
        expect(failure.props, [customMessage]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = NetworkFailure(message: 'Same message');
        const failure2 = NetworkFailure(message: 'Same message');

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = NetworkFailure();

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('ValidationFailure', () {
      test('should have correct message', () {
        // Arrange
        const message = 'Validation error';
        const failure = ValidationFailure(message);

        // Act & Assert
        expect(failure.message, equals(message));
        expect(failure.props, [message]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const message = 'Validation failed';
        const failure1 = ValidationFailure(message);
        const failure2 = ValidationFailure(message);

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = ValidationFailure('Test message');

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('UnknownFailure', () {
      test('should have correct message', () {
        // Arrange
        const message = 'Unknown error occurred';
        const failure = UnknownFailure(message);

        // Act & Assert
        expect(failure.message, equals(message));
        expect(failure.props, [message]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const message = 'Unknown error';
        const failure1 = UnknownFailure(message);
        const failure2 = UnknownFailure(message);

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = UnknownFailure('Test message');

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('AuthenticationFailure', () {
      test('should have default message when no message provided', () {
        // Arrange & Act
        const failure = AuthenticationFailure();

        // Assert
        expect(failure.message, equals('Authentication failed'));
        expect(failure.props, ['Authentication failed']);
      });

      test('should use custom message when provided', () {
        // Arrange & Act
        const customMessage = 'Custom auth error';
        const failure = AuthenticationFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
        expect(failure.props, [customMessage]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = AuthenticationFailure(message: 'Same message');
        const failure2 = AuthenticationFailure(message: 'Same message');

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = AuthenticationFailure();

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('NotFoundFailure', () {
      test('should have default message when no message provided', () {
        // Arrange & Act
        const failure = NotFoundFailure();

        // Assert
        expect(failure.message, equals('Resource not found'));
        expect(failure.props, ['Resource not found']);
      });

      test('should use custom message when provided', () {
        // Arrange & Act
        const customMessage = 'Custom not found error';
        const failure = NotFoundFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
        expect(failure.props, [customMessage]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = NotFoundFailure(message: 'Same message');
        const failure2 = NotFoundFailure(message: 'Same message');

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = NotFoundFailure();

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('PermissionFailure', () {
      test('should have default message when no message provided', () {
        // Arrange & Act
        const failure = PermissionFailure();

        // Assert
        expect(failure.message, equals('Permission denied'));
        expect(failure.props, ['Permission denied']);
      });

      test('should use custom message when provided', () {
        // Arrange & Act
        const customMessage = 'Custom permission error';
        const failure = PermissionFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
        expect(failure.props, [customMessage]);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = PermissionFailure(message: 'Same message');
        const failure2 = PermissionFailure(message: 'Same message');

        // Act & Assert
        expect(failure1, equals(failure2));
      });

      test('should extend Failure', () {
        // Arrange
        const failure = PermissionFailure();

        // Act & Assert
        expect(failure, isA<Failure>());
      });
    });

    group('Failure base class', () {
      test('should support toString method', () {
        // Arrange
        const failure = ServerFailure(message: 'Test error');

        // Act
        final result = failure.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should have props containing message', () {
        // Arrange
        const message = 'Test failure message';
        const failure = ValidationFailure(message);

        // Act & Assert
        expect(failure.props, [message]);
        expect(failure.props, isA<List<Object>>());
      });

      test('should test base class behavior directly', () {
        // Create a test implementation to access base class behavior
        final testFailure = _TestFailure('Test message');
        
        // Act & Assert
        expect(testFailure.props, ['Test message']);
        expect(testFailure.message, equals('Test message'));
        expect(testFailure.props, isA<List<Object>>());
      });
    });

    group('Failure type differentiation', () {
      test('should be able to distinguish between different failure types', () {
        // Arrange
        const serverFailure = ServerFailure();
        const cacheFailure = CacheFailure('Cache error');
        const networkFailure = NetworkFailure();
        const validationFailure = ValidationFailure('Validation error');
        const unknownFailure = UnknownFailure('Unknown error');
        const authFailure = AuthenticationFailure();
        const notFoundFailure = NotFoundFailure();
        const permissionFailure = PermissionFailure();

        // Act & Assert - All failures should be different types
        final failureTypes = [
          serverFailure.runtimeType,
          cacheFailure.runtimeType,
          networkFailure.runtimeType,
          validationFailure.runtimeType,
          unknownFailure.runtimeType,
          authFailure.runtimeType,
          notFoundFailure.runtimeType,
          permissionFailure.runtimeType,
        ];

        // Check that all types are unique
        expect(failureTypes.toSet().length, equals(failureTypes.length));
        
        // But all should be Failure
        expect(serverFailure, isA<Failure>());
        expect(cacheFailure, isA<Failure>());
        expect(networkFailure, isA<Failure>());
        expect(validationFailure, isA<Failure>());
        expect(unknownFailure, isA<Failure>());
        expect(authFailure, isA<Failure>());
        expect(notFoundFailure, isA<Failure>());
        expect(permissionFailure, isA<Failure>());
      });

      test('should not be equal between different failure types even with same message', () {
        // Arrange
        const message = 'Same error message';
        const cacheFailure = CacheFailure(message);
        const validationFailure = ValidationFailure(message);
        const unknownFailure = UnknownFailure(message);

        // Act & Assert - All failures should be different even with same message
        expect(cacheFailure, isNot(equals(validationFailure)));
        expect(cacheFailure, isNot(equals(unknownFailure)));
        expect(validationFailure, isNot(equals(unknownFailure)));
      });
    });

    group('Failure polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<Failure> failures = [
          const ServerFailure(),
          const CacheFailure('Cache error'),
          const NetworkFailure(),
          const ValidationFailure('Validation error'),
          const UnknownFailure('Unknown error'),
          const AuthenticationFailure(),
          const NotFoundFailure(),
          const PermissionFailure(),
        ];

        // Act & Assert
        expect(failures.length, equals(8));
        expect(failures[0], isA<ServerFailure>());
        expect(failures[1], isA<CacheFailure>());
        expect(failures[2], isA<NetworkFailure>());
        expect(failures[3], isA<ValidationFailure>());
        expect(failures[4], isA<UnknownFailure>());
        expect(failures[5], isA<AuthenticationFailure>());
        expect(failures[6], isA<NotFoundFailure>());
        expect(failures[7], isA<PermissionFailure>());
        
        // Check that all have messages
        for (final failure in failures) {
          expect(failure.message, isNotEmpty);
        }
      });
    });

    group('Failure const constructors', () {
      test('should support const constructor for all failure types', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const serverFailure1 = ServerFailure(message: 'test');
        const serverFailure2 = ServerFailure(message: 'test');
        const networkFailure1 = NetworkFailure(message: 'test');
        const networkFailure2 = NetworkFailure(message: 'test');

        // Assert - Should be the same instance due to const optimization
        expect(identical(serverFailure1, serverFailure2), isTrue);
        expect(identical(networkFailure1, networkFailure2), isTrue);
      });
    });
  });
}

/// Test implementation of Failure to access base class behavior
class _TestFailure extends Failure {
  const _TestFailure(super.message);
}
