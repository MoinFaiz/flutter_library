import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('CartItem Entity Tests', () {
    late Book mockBook;
    late CartItem testCartItem;

    setUp(() {
      mockBook = Book(
        id: '1',
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

      testCartItem = CartItem(
        id: 'cart1',
        book: mockBook,
        type: CartItemType.rent,
        addedAt: DateTime(2024, 1, 15),
        rentalPeriodInDays: 14,
      );
    });

    test('should create CartItem with correct properties', () {
      expect(testCartItem.id, equals('cart1'));
      expect(testCartItem.book, equals(mockBook));
      expect(testCartItem.type, equals(CartItemType.rent));
      expect(testCartItem.rentalPeriodInDays, equals(14));
    });

    test('should return correct price for rental item', () {
      expect(testCartItem.price, equals(5.0));
      expect(testCartItem.isRental, isTrue);
      expect(testCartItem.isPurchase, isFalse);
    });

    test('should return correct price for purchase item', () {
      final purchaseItem = testCartItem.copyWith(type: CartItemType.purchase);
      expect(purchaseItem.price, equals(20.0));
      expect(purchaseItem.isRental, isFalse);
      expect(purchaseItem.isPurchase, isTrue);
    });

    test('should indicate no request sent initially', () {
      expect(testCartItem.hasRequestSent, isFalse);
      expect(testCartItem.requestId, isNull);
    });

    test('should indicate request sent when requestId is set', () {
      final itemWithRequest = testCartItem.copyWith(requestId: 'req123');
      expect(itemWithRequest.hasRequestSent, isTrue);
      expect(itemWithRequest.requestId, equals('req123'));
    });

    test('should support value equality', () {
      final sameItem = CartItem(
        id: 'cart1',
        book: mockBook,
        type: CartItemType.rent,
        addedAt: DateTime(2024, 1, 15),
        rentalPeriodInDays: 14,
      );

      expect(testCartItem, equals(sameItem));
    });

    test('should not equal different cart item', () {
      final differentItem = testCartItem.copyWith(id: 'cart2');
      expect(testCartItem, isNot(equals(differentItem)));
    });

    test('copyWith should preserve unchanged properties', () {
      final copied = testCartItem.copyWith(rentalPeriodInDays: 21);
      
      expect(copied.id, equals(testCartItem.id));
      expect(copied.book, equals(testCartItem.book));
      expect(copied.type, equals(testCartItem.type));
      expect(copied.rentalPeriodInDays, equals(21));
    });

    test('should have default rental period of 14 days', () {
      final defaultItem = CartItem(
        id: 'cart1',
        book: mockBook,
        type: CartItemType.rent,
        addedAt: DateTime.now(),
      );

      expect(defaultItem.rentalPeriodInDays, equals(14));
    });
  });
}
