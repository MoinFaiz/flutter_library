import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late AcceptCartRequestUseCase usecase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    usecase = AcceptCartRequestUseCase(mockRepository);
  });

  group('AcceptCartRequestUseCase', () {
    const testRequestId = 'request123';

    test('should accept cart request successfully', () async {
      // Arrange
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails with server error',
        () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to accept request');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when repository fails with network error',
        () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when request ID is invalid', () async {
      // Arrange
      const failure = ValidationFailure('Invalid request ID');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass empty string request ID to repository', () async {
      // Arrange
      const emptyRequestId = '';
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(emptyRequestId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.acceptRequest(emptyRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle different request ID formats', () async {
      // Arrange
      const specialRequestId = 'req-123-abc-456';
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(specialRequestId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.acceptRequest(specialRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthenticationFailure when user is not authenticated',
        () async {
      // Arrange
      const failure = AuthenticationFailure(message: 'User not authenticated');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when request is not found', () async {
      // Arrange
      const failure = NotFoundFailure(message: 'Request not found');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testRequestId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest(testRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository method only once per invocation', () async {
      // Arrange
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await usecase(testRequestId);
      await usecase(testRequestId);

      // Assert
      verify(() => mockRepository.acceptRequest(testRequestId)).called(2);
    });
  });
}
