import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late CartLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = CartLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('CartLocalDataSourceImpl', () {
    final testBook = BookModel(
      id: 'book1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: const ['https://example.com/image.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 9.99,
        minimumCostToBuy: 29.99,
        maximumCostToBuy: 29.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 5,
        availableForSaleCount: 3,
        totalCopies: 8,
      ),
      metadata: BookMetadata(
        isbn: '978-1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: const ['Fiction'],
        pageCount: 300,
        language: 'English',
        edition: '1st',
      ),
      isFromFriend: false,      description: 'Test description',
      publishedYear: 2024,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    final testBook2 = BookModel(
      id: 'book2',
      title: 'Test Book 2',
      author: 'Test Author 2',
      imageUrls: const ['https://example.com/image2.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 7.99,
        minimumCostToBuy: 19.99,
        maximumCostToBuy: 19.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 2,
        totalCopies: 5,
      ),
      metadata: BookMetadata(
        isbn: '978-0987654321',
        publisher: 'Test Publisher 2',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: const ['Science'],
        pageCount: 250,
        language: 'English',
        edition: '2nd',
      ),
      isFromFriend: false,      description: 'Test description 2',
      publishedYear: 2024,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    final testCartItem = CartItemModel(
      id: 'cart1',
      book: testBook.toEntity(),
      type: CartItemType.purchase,
      addedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    final testCartItem2 = CartItemModel(
      id: 'cart2',
      book: testBook2.toEntity(),
      type: CartItemType.rent,
      addedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      rentalPeriodInDays: 14,
    );

    group('getCachedCartItems', () {
      test('should return list of CartItemModel when cache exists', () async {
        // Arrange
        final items = [testCartItem];
        final jsonString = json.encode(items.map((e) => e.toJson()).toList());
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedCartItems();

        // Assert
        expect(result, isA<List<CartItemModel>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals('cart1'));
        expect(result.first.book.title, equals('Test Book'));
        verify(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey)).called(1);
      });

      test('should return empty list when cache is null', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedCartItems();

        // Assert
        expect(result, isA<List<CartItemModel>>());
        expect(result, isEmpty);
        verify(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey)).called(1);
      });

      test('should throw FormatException when cache contains invalid JSON', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenReturn('invalid json');

        // Act & Assert
        expect(
          () => dataSource.getCachedCartItems(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle multiple cart items', () async {
        // Arrange
        final items = [testCartItem, testCartItem2];
        final jsonString = json.encode(items.map((e) => e.toJson()).toList());
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedCartItems();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('cart1'));
        expect(result[1].id, equals('cart2'));
        expect(result[1].type, equals(CartItemType.rent));
        expect(result[1].rentalPeriodInDays, equals(14));
      });

      test('should parse cart items with all fields correctly', () async {
        // Arrange
        final items = [testCartItem];
        final jsonString = json.encode(items.map((e) => e.toJson()).toList());
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedCartItems();

        // Assert
        final item = result.first;
        expect(item.id, equals('cart1'));
        expect(item.book.id, equals('book1'));
        expect(item.book.title, equals('Test Book'));
        expect(item.book.author, equals('Test Author'));
        expect(item.book.imageUrls.first, equals('https://example.com/image.jpg'));
        expect(item.type, equals(CartItemType.purchase));
        expect(item.price, equals(29.99));
      });
    });

    group('cacheCartItems', () {
      test('should cache cart items successfully', () async {
        // Arrange
        final items = [testCartItem, testCartItem2];
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheCartItems(items);

        // Assert
        verify(() => mockSharedPreferences.setString(
          CartLocalDataSourceImpl.cartCacheKey,
          any(),
        )).called(1);
      });

      test('should cache empty list successfully', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheCartItems([]);

        // Assert
        verify(() => mockSharedPreferences.setString(
          CartLocalDataSourceImpl.cartCacheKey,
          '[]',
        )).called(1);
      });

      test('should serialize cart items correctly', () async {
        // Arrange
        final items = [testCartItem];
        String? cachedData;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedData = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheCartItems(items);

        // Assert
        expect(cachedData, isNotNull);
        expect(cachedData, contains('"id":"cart1"'));
        expect(cachedData, contains('"title":"Test Book"'));
        expect(cachedData, contains('"type":"purchase"'));
      });

      test('should handle large lists of cart items', () async {
        // Arrange
        final items = List.generate(
          100,
          (index) {
            final book = BookModel(
              id: 'book$index',
              title: 'Test Book $index',
              author: 'Test Author $index',
              imageUrls: ['https://example.com/image$index.jpg'],
              rating: 4.5,
              pricing: BookPricing(
                salePrice: 29.99 + index,
                rentPrice: 9.99 + index,
                minimumCostToBuy: 29.99 + index,
                maximumCostToBuy: 29.99 + index,
              ),
              availability: const BookAvailability(
                availableForRentCount: 5,
                availableForSaleCount: 3,
                totalCopies: 8,
              ),
              metadata: BookMetadata(
                isbn: '978-$index',
                publisher: 'Test Publisher',
                ageAppropriateness: AgeAppropriateness.adult,
                genres: const ['Fiction'],
                pageCount: 300,
                language: 'English',
                edition: '1st',
              ),
              isFromFriend: false,              description: 'Test description',
              publishedYear: 2024,
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            );

            return CartItemModel(
              id: 'cart$index',
              book: book.toEntity(),
              type: index % 2 == 0 ? CartItemType.purchase : CartItemType.rent,
              addedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
              rentalPeriodInDays: index % 2 == 1 ? 14 : 14,
            );
          },
        );
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheCartItems(items);

        // Assert
        verify(() => mockSharedPreferences.setString(
          CartLocalDataSourceImpl.cartCacheKey,
          any(),
        )).called(1);
      });
    });

    group('clearCache', () {
      test('should clear cache successfully', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(CartLocalDataSourceImpl.cartCacheKey))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearCache();

        // Assert
        verify(() => mockSharedPreferences.remove(CartLocalDataSourceImpl.cartCacheKey)).called(1);
      });

      test('should complete even if remove returns false', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(CartLocalDataSourceImpl.cartCacheKey))
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(() => dataSource.clearCache(), returnsNormally);
        verify(() => mockSharedPreferences.remove(CartLocalDataSourceImpl.cartCacheKey)).called(1);
      });
    });

    group('Integration tests', () {
      test('should cache and retrieve same cart items', () async {
        // Arrange
        final items = [testCartItem, testCartItem2];
        String? cachedData;
        
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedData = invocation.positionalArguments[1] as String;
          return true;
        });
        
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenAnswer((_) => cachedData);

        // Act
        await dataSource.cacheCartItems(items);
        final result = await dataSource.getCachedCartItems();

        // Assert
        expect(result.length, equals(items.length));
        expect(result[0].id, equals(items[0].id));
        expect(result[1].id, equals(items[1].id));
      });

      test('should return empty list after clearing cache', () async {
        // Arrange
        final items = [testCartItem];
        String? cachedData = 'some data';
        
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedData = invocation.positionalArguments[1] as String;
          return true;
        });
        
        when(() => mockSharedPreferences.remove(CartLocalDataSourceImpl.cartCacheKey))
            .thenAnswer((_) async {
          cachedData = null;
          return true;
        });
        
        when(() => mockSharedPreferences.getString(CartLocalDataSourceImpl.cartCacheKey))
            .thenAnswer((_) => cachedData);

        // Act
        await dataSource.cacheCartItems(items);
        await dataSource.clearCache();
        final result = await dataSource.getCachedCartItems();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
