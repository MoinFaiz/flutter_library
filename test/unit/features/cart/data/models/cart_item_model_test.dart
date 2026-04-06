import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper function to create book JSON
  Map<String, dynamic> createBookJson() {
    return {
      'id': 'book1',
      'title': 'Test Book',
      'author': 'Test Author',
      'imageUrls': ['https://example.com/image.jpg'],
      'rating': 4.5,
      'pricing': {
        'salePrice': 29.99,
        'rentPrice': 9.99,
      },
      'availability': {
        'availableForRentCount': 1,
        'availableForSaleCount': 1,
        'totalCopies': 1,
      },
      'metadata': {
        'genres': ['Fiction'],
        'pageCount': 200,
        'language': 'English',
        'ageAppropriateness': 'adult',
      },
      'isFromFriend': false,
      'isFavorite': false,
      'description': 'Test Description',
      'publishedYear': 2025,
      'createdAt': '2025-01-01T00:00:00.000',
      'updatedAt': '2025-01-01T00:00:00.000',
    };
  }

  group('CartItemModel', () {
    final testBookModel = BookModel(
      id: 'book1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: const ['https://example.com/image.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 9.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 1,
        availableForSaleCount: 1,
        totalCopies: 1,
      ),
      metadata: const BookMetadata(
        genres: ['Fiction'],
        pageCount: 200,
        language: 'English',
        ageAppropriateness: AgeAppropriateness.adult,
      ),
      isFromFriend: false,      description: 'Test Description',
      publishedYear: 2025,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    final testCartItemModel = CartItemModel(
      id: 'cart1',
      book: testBookModel.toEntity(),
      type: CartItemType.rent,
      addedAt: DateTime(2025, 10, 31, 12, 0),
      rentalPeriodInDays: 14,
      requestId: 'req1',
    );

    test('should be a subclass of CartItem', () {
      expect(testCartItemModel, isA<CartItem>());
    });

    test('fromJson should create instance from JSON', () {
      final json = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'rent',
        'added_at': '2025-10-31T12:00:00.000',
        'rental_period_in_days': 14,
        'request_id': 'req1',
      };

      final model = CartItemModel.fromJson(json);

      expect(model.id, 'cart1');
      expect(model.book.id, 'book1');
      expect(model.book.title, 'Test Book');
      expect(model.type, CartItemType.rent);
      expect(model.rentalPeriodInDays, 14);
      expect(model.requestId, 'req1');
    });

    test('fromJson should handle different type strings', () {
      final rentJson = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'rental',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(rentJson);
      expect(model.type, CartItemType.rent);
    });

    test('fromJson should handle purchase type', () {
      final purchaseJson = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'purchase',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(purchaseJson);
      expect(model.type, CartItemType.purchase);
    });

    test('fromJson should handle buy as purchase type', () {
      final buyJson = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'buy',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(buyJson);
      expect(model.type, CartItemType.purchase);
    });

    test('fromJson should default to rent for unknown type', () {
      final unknownJson = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'unknown',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(unknownJson);
      expect(model.type, CartItemType.rent);
    });

    test('fromJson should default rental period to 14 if not provided', () {
      final json = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'rent',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(json);
      expect(model.rentalPeriodInDays, 14);
    });

    test('fromJson should handle null request_id', () {
      final json = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'rent',
        'added_at': '2025-10-31T12:00:00.000',
        'request_id': null,
      };

      final model = CartItemModel.fromJson(json);
      expect(model.requestId, null);
    });

    test('toJson should convert to JSON correctly', () {
      final json = testCartItemModel.toJson();

      expect(json['id'], 'cart1');
      expect(json['book']['id'], 'book1');
      expect(json['type'], 'rent');
      expect(json['added_at'], '2025-10-31T12:00:00.000');
      expect(json['rental_period_in_days'], 14);
      expect(json['request_id'], 'req1');
    });

    test('toJson should handle purchase type', () {
      final purchaseItem = CartItemModel(
        id: 'cart1',
        book: testBookModel.toEntity(),
        type: CartItemType.purchase,
        addedAt: DateTime(2025, 10, 31, 12, 0),
      );

      final json = purchaseItem.toJson();
      expect(json['type'], 'purchase');
    });

    test('toJson should handle null requestId', () {
      final itemWithoutRequest = CartItemModel(
        id: 'cart1',
        book: testBookModel.toEntity(),
        type: CartItemType.rent,
        addedAt: DateTime(2025, 10, 31, 12, 0),
      );

      final json = itemWithoutRequest.toJson();
      expect(json['request_id'], null);
    });

    test('fromEntity should create model from entity', () {
      final entity = CartItem(
        id: 'cart1',
        book: testBookModel.toEntity(),
        type: CartItemType.rent,
        addedAt: DateTime(2025, 10, 31, 12, 0),
        rentalPeriodInDays: 21,
        requestId: 'req1',
      );

      final model = CartItemModel.fromEntity(entity);

      expect(model.id, 'cart1');
      expect(model.book, testBookModel);
      expect(model.type, CartItemType.rent);
      expect(model.rentalPeriodInDays, 21);
      expect(model.requestId, 'req1');
    });

    test('should handle JSON serialization round trip', () {
      final json = testCartItemModel.toJson();
      final model = CartItemModel.fromJson(json);

      expect(model.id, testCartItemModel.id);
      expect(model.book.id, testCartItemModel.book.id);
      expect(model.type, testCartItemModel.type);
      expect(model.rentalPeriodInDays, testCartItemModel.rentalPeriodInDays);
      expect(model.requestId, testCartItemModel.requestId);
    });

    test('should handle type case insensitivity', () {
      final json = {
        'id': 'cart1',
        'book': createBookJson(),
        'type': 'RENT',
        'added_at': '2025-10-31T12:00:00.000',
      };

      final model = CartItemModel.fromJson(json);
      expect(model.type, CartItemType.rent);
    });
  });
}
