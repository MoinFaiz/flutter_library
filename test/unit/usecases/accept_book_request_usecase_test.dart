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

    test('should accept book request successfully', () async {
      // Arrange
      const notificationId = '123';
      when(() => mockRepository.acceptBookRequest(notificationId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const notificationId = '123';
      const failure = ServerFailure(message: 'Failed to accept request');
      when(() => mockRepository.acceptBookRequest(notificationId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(notificationId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, contains('Failed to accept request')),
        (_) => fail('Expected failure but got success'),
      );
      verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
    });

    test('should call repository with correct notification id', () async {
      // Arrange
      const notificationId = 'test-notification-id';
      when(() => mockRepository.acceptBookRequest(notificationId))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call(notificationId);

      // Assert
      verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty notification id', () async {
      // Arrange
      const notificationId = '';
      when(() => mockRepository.acceptBookRequest(notificationId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(notificationId);

      // Assert
      expect(result, isA<Right>());
      verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
    });

    test('should handle repository throwing exception', () async {
      // Arrange
      const notificationId = '123';
      when(() => mockRepository.acceptBookRequest(notificationId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase.call(notificationId), throwsException);
      verify(() => mockRepository.acceptBookRequest(notificationId)).called(1);
    });
  });
}
