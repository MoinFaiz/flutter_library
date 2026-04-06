import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_items_usecase.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late GetCartItemsUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = GetCartItemsUseCase(repository: mockRepository);
  });

  group('GetCartItemsUseCase', () {
    final mockCartItems = <CartItem>[];

    test('should get cart items from repository', () async {
      // Arrange
      when(() => mockRepository.getCartItems())
          .thenAnswer((_) async => Right(mockCartItems));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(Right(mockCartItems)));
      verify(() => mockRepository.getCartItems()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(() => mockRepository.getCartItems())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.getCartItems()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return network failure when network error occurs', () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.getCartItems())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Left<Failure, List<CartItem>>>());
      expect((result as Left).value, equals(failure));
    });
  });
}
