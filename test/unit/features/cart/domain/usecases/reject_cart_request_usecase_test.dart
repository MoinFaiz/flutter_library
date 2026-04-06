import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late RejectCartRequestUseCase usecase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    usecase = RejectCartRequestUseCase(mockRepository);
  });

  group('RejectCartRequestUseCase', () {
    const testRequestId = 'request123';
    const testReason = 'Book is not available';

    test('should reject cart request without reason', () async {
      // Arrange
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should reject cart request with reason', () async {
      // Arrange
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId, reason: testReason);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: testReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails with server error',
        () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to reject request');
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when repository fails with network error',
        () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId, reason: testReason);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: testReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when request ID is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Invalid request ID');
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty string as reason', () async {
      // Arrange
      const emptyReason = '';
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId, reason: emptyReason);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: emptyReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle long rejection reason', () async {
      // Arrange
      const longReason = 'This is a very long rejection reason that explains '
          'in detail why the request cannot be accepted at this time. '
          'Multiple factors contribute to this decision.';
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId, reason: longReason);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: longReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass empty string request ID to repository', () async {
      // Arrange
      const emptyRequestId = '';
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(emptyRequestId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            emptyRequestId,
            reason: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle different request ID formats', () async {
      // Arrange
      const specialRequestId = 'req-123-abc-456';
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(specialRequestId, reason: testReason);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            specialRequestId,
            reason: testReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthenticationFailure when user is not authenticated',
        () async {
      // Arrange
      const failure = AuthenticationFailure(message: 'User not authenticated');
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId, reason: testReason);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: testReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when request is not found', () async {
      // Arrange
      const failure = NotFoundFailure(message: 'Request not found');
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: null,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method only once per invocation', () async {
      // Arrange
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testRequestId, reason: testReason);
      await usecase(testRequestId, reason: testReason);

      // Assert
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: testReason,
          )).called(2);
    });

    test('should handle rejection with special characters in reason', () async {
      // Arrange
      const specialReason = 'Book unavailable! @#\$%^&*()_+-=[]{}|;:,.<>?';
      when(() => mockRepository.rejectRequest(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId, reason: specialReason);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest(
            testRequestId,
            reason: specialReason,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
