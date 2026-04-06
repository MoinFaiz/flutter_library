import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

class MockCartRepository extends Mock implements CartRepository {}

class MockBook extends Mock implements Book {}

void main() {
  late AddToCartUseCase useCase;
  late MockCartRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(CartItemType.rent);
  });

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = AddToCartUseCase(repository: mockRepository);
  });

  group('AddToCartUseCase', () {
    late Book mockBook;
    late CartItem mockCartItem;

    setUp(() {
      mockBook = Book(
        id: 'book1',
        title: 'Test Book',
        author: 'Test Author',
        imageUrls: ['https://example.com/image.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 20.0,
          rentPrice: 5.0,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 5,
          totalCopies: 10,
        ),
        metadata: const BookMetadata(
          isbn: '1234567890',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 350,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Test description',
        publishedYear: 2024,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      mockCartItem = CartItem(
        id: 'cart1',
        book: mockBook,
        type: CartItemType.rent,
        addedAt: DateTime.now(),
        rentalPeriodInDays: 14,
      );
    });

    test('should add item to cart with rental type', () async {
      // Arrange
      final params = AddToCartParams(
        bookId: 'book1',
        type: CartItemType.rent,
        rentalPeriodInDays: 14,
      );

      when(() => mockRepository.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => Right(mockCartItem));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(Right(mockCartItem)));
      verify(() => mockRepository.addToCart(
            bookId: 'book1',
            type: CartItemType.rent,
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('should add item to cart with purchase type', () async {
      // Arrange
      final purchaseItem = mockCartItem.copyWith(type: CartItemType.purchase);
      final params = AddToCartParams(
        bookId: 'book1',
        type: CartItemType.purchase,
      );

      when(() => mockRepository.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => Right(purchaseItem));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Right<Failure, CartItem>>());
      final cartItem = (result as Right).value;
      expect(cartItem.type, equals(CartItemType.purchase));
    });

    test('should use default rental period when not specified', () async {
      // Arrange
      final params = AddToCartParams(
        bookId: 'book1',
        type: CartItemType.rent,
      );

      when(() => mockRepository.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => Right(mockCartItem));

      // Act
      await useCase(params);

      // Assert
      verify(() => mockRepository.addToCart(
            bookId: 'book1',
            type: CartItemType.rent,
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final params = AddToCartParams(
        bookId: 'book1',
        type: CartItemType.rent,
      );
      const failure = ServerFailure(message: 'Failed to add to cart');

      when(() => mockRepository.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(const Left(failure)));
    });
  });
}
