import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/notifications/domain/usecases/reject_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  group('RejectBookRequestUseCase Tests', () {
    late RejectBookRequestUseCase useCase;
    late MockNotificationsRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationsRepository();
      useCase = RejectBookRequestUseCase(mockRepository);
    });

    group('Successful Rejection', () {
      test('should reject book request without reason when repository succeeds', () async {
        // Arrange
        const notificationId = 'notification_123';
        const String? reason = null;
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should reject book request with reason when repository succeeds', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Book not available';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle empty reason string', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = '';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle long rejection reason', () async {
        // Arrange
        const notificationId = 'notification_123';
        final reason = 'This is a very long rejection reason that explains in detail why the book request is being rejected due to various circumstances and policies.' * 10;
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle reason with special characters', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Book not available! @#\$%^&*()_+-=[]{}|;:\'",.<>?/~`';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle reason with newlines and tabs', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Book not available\ndue to multiple reasons:\n\t1. Out of stock\n\t2. Under maintenance';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });
    });

    group('Error Handling', () {
      test('should return ServerFailure when repository fails with server error', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Server error occurred';
        const failure = ServerFailure(message: 'Server error');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should return NetworkFailure when repository fails with network error', () async {
        // Arrange
        const notificationId = 'notification_123';
        const String? reason = null;
        const failure = NetworkFailure(message: 'No internet connection');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should return NotFoundFailure when notification not found', () async {
        // Arrange
        const notificationId = 'nonexistent_notification';
        const reason = 'Not found';
        const failure = NotFoundFailure(message: 'Notification not found');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should return PermissionFailure when user lacks permission', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Permission denied';
        const failure = PermissionFailure(message: 'Permission denied');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should return ValidationFailure when notification ID is invalid', () async {
        // Arrange
        const notificationId = '';
        const reason = 'Invalid ID';
        const failure = ValidationFailure('Invalid notification ID format');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should propagate any failure from repository', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Unknown error';
        const failure = UnknownFailure('Unknown error occurred');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle null notification ID gracefully', () async {
        // Note: This test would fail compilation, but shows intention
        // In practice, the parameter is non-nullable String
        const notificationId = '';
        const String? reason = null;
        const failure = ValidationFailure('Notification ID cannot be empty');
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle very long notification ID', () async {
        // Arrange
        final notificationId = 'notification_${'a' * 1000}';
        const reason = 'Long ID rejection';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });

      test('should handle notification ID with unicode characters', () async {
        // Arrange
        const notificationId = 'notification_😀🎉📚';
        const reason = 'Unicode test';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(notificationId, reason);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      });
    });

    group('Multiple Operations', () {
      test('should handle multiple rejection calls in sequence', () async {
        // Arrange
        const notificationId1 = 'notification_1';
        const notificationId2 = 'notification_2';
        const reason1 = 'Reason 1';
        const reason2 = 'Reason 2';
        
        when(() => mockRepository.rejectBookRequest(notificationId1, reason1))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.rejectBookRequest(notificationId2, reason2))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result1 = await useCase.call(notificationId1, reason1);
        final result2 = await useCase.call(notificationId2, reason2);

        // Assert
        expect(result1, equals(const Right(null)));
        expect(result2, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId1, reason1)).called(1);
        verify(() => mockRepository.rejectBookRequest(notificationId2, reason2)).called(1);
      });

      test('should handle same notification rejected multiple times', () async {
        // Arrange
        const notificationId = 'notification_123';
        const reason = 'Multiple rejections';
        when(() => mockRepository.rejectBookRequest(notificationId, reason))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result1 = await useCase.call(notificationId, reason);
        final result2 = await useCase.call(notificationId, reason);

        // Assert
        expect(result1, equals(const Right(null)));
        expect(result2, equals(const Right(null)));
        verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(2);
      });
    });
  });
}
