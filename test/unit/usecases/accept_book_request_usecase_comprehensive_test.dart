import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/notifications/domain/usecases/accept_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  group('AcceptBookRequestUseCase Tests', () {
    late AcceptBookRequestUseCase useCase;
    late MockNotificationsRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationsRepository();
      useCase = AcceptBookRequestUseCase(mockRepository);
    });

    group('Successful Acceptance', () {
      test('should accept book request when repository succeeds', () async {
        // Arrange
        const notificationId = 'notification_123';
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should handle empty notification ID', () async {
        // Arrange
        const notificationId = '';
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should handle notification ID with special characters', () async {
        // Arrange
        const notificationId = 'notification_123-abc@domain.com';
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should handle very long notification ID', () async {
        // Arrange
        final notificationId = 'notification_${'a' * 1000}';
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });
    });

    group('Error Handling', () {
      test('should return ServerFailure when repository fails with server error', () async {
        // Arrange
        const notificationId = 'notification_123';
        const failure = ServerFailure(message: 'Server error');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should return NetworkFailure when repository fails with network error', () async {
        // Arrange
        const notificationId = 'notification_123';
        const failure = NetworkFailure(message: 'No internet connection');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should return NotFoundFailure when notification not found', () async {
        // Arrange
        const notificationId = 'nonexistent_notification';
        const failure = NotFoundFailure(message: 'Notification not found');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should return PermissionFailure when user lacks permission', () async {
        // Arrange
        const notificationId = 'notification_123';
        const failure = PermissionFailure(message: 'Permission denied');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should return ValidationFailure when notification ID is invalid', () async {
        // Arrange
        const notificationId = 'invalid_id';
        const failure = ValidationFailure('Invalid notification ID format');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });

      test('should propagate any failure from repository', () async {
        // Arrange
        const notificationId = 'notification_123';
        const failure = UnknownFailure('Unknown error occurred');
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      });
    });

    group('Multiple Calls', () {
      test('should handle multiple consecutive calls', () async {
        // Arrange
        const notificationId1 = 'notification_1';
        const notificationId2 = 'notification_2';
        when(() => mockRepository.acceptBookRequest(notificationId1))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.acceptBookRequest(notificationId2))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result1 = await useCase.call(notificationId1);
        final result2 = await useCase.call(notificationId2);

        // Assert
        expect(result1, equals(const Right(null)));
        expect(result2, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId1)).called(1);
        verify(() => mockRepository.acceptBookRequest(notificationId2)).called(1);
      });

      test('should handle same notification ID called multiple times', () async {
        // Arrange
        const notificationId = 'notification_123';
        when(() => mockRepository.acceptBookRequest(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result1 = await useCase.call(notificationId);
        final result2 = await useCase.call(notificationId);

        // Assert
        expect(result1, equals(const Right(null)));
        expect(result2, equals(const Right(null)));
        verify(() => mockRepository.acceptBookRequest(notificationId)).called(2);
      });
    });
  });
}
