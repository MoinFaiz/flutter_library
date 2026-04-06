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

    test('should reject book request successfully without reason', () async {
      // Arrange
      const notificationId = '123';
      when(() => mockRepository.rejectBookRequest(notificationId, null))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId, null);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.rejectBookRequest(notificationId, null)).called(1);
    });

    test('should reject book request successfully with reason', () async {
      // Arrange
      const notificationId = '123';
      const reason = 'Book not available';
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId, reason);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const notificationId = '123';
      const reason = 'Not available';
      const failure = ServerFailure(message: 'Failed to reject request');
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(notificationId, reason);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, contains('Failed to reject request')),
        (_) => fail('Expected failure but got success'),
      );
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      const notificationId = 'test-notification-id';
      const reason = 'Custom rejection reason';
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call(notificationId, reason);

      // Assert
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty notification id', () async {
      // Arrange
      const notificationId = '';
      const reason = 'Some reason';
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId, reason);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
    });

    test('should handle empty reason string', () async {
      // Arrange
      const notificationId = '123';
      const reason = '';
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId, reason);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      const notificationId = '123';
      const reason = 'Some reason';
      when(() => mockRepository.rejectBookRequest(notificationId, reason))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase.call(notificationId, reason), throwsException);
      verify(() => mockRepository.rejectBookRequest(notificationId, reason)).called(1);
    });
  });
}
