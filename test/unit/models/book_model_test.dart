import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

void main() {
  group('BookModel Tests', () {
    final testDateTime = DateTime(2023, 6, 1, 12, 0, 0);
    
    final testBookModel = BookModel(
      id: 'test-book-id',
      title: 'Test Book Title',
      author: 'Test Author',
      imageUrls: const ['image1.jpg', 'image2.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        discountedSalePrice: 24.99,
        rentPrice: 9.99,
        discountedRentPrice: 7.99,
        percentageDiscountForRent: 20.0,
        percentageDiscountForSale: 16.67,
        minimumCostToBuy: 15.0,
        maximumCostToBuy: 35.0,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 2,
        totalCopies: 5,
      ),
      metadata: const BookMetadata(
        isbn: '978-0-123456-78-9',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Mystery'],
        pageCount: 320,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: true,      description: 'A compelling test book description',
      publishedYear: 2023,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('Model Properties', () {
      test('should be a subclass of Book entity', () {
        expect(testBookModel, isA<BookModel>());
      });

      test('should have correct properties from parent entity', () {
        expect(testBookModel.id, equals('test-book-id'));
        expect(testBookModel.title, equals('Test Book Title'));
        expect(testBookModel.author, equals('Test Author'));
        expect(testBookModel.imageUrls, equals(['image1.jpg', 'image2.jpg']));
        expect(testBookModel.rating, equals(4.5));
        expect(testBookModel.isFromFriend, isTrue);
        expect(testBookModel.description, equals('A compelling test book description'));
        expect(testBookModel.publishedYear, equals(2023));
        expect(testBookModel.createdAt, equals(testDateTime));
        expect(testBookModel.updatedAt, equals(testDateTime));
      });

      test('should have correct pricing value object', () {
        expect(testBookModel.pricing.salePrice, equals(29.99));
        expect(testBookModel.pricing.discountedSalePrice, equals(24.99));
        expect(testBookModel.pricing.rentPrice, equals(9.99));
        expect(testBookModel.pricing.discountedRentPrice, equals(7.99));
      });

      test('should have correct availability value object', () {
        expect(testBookModel.availability.availableForRentCount, equals(3));
        expect(testBookModel.availability.availableForSaleCount, equals(2));
        expect(testBookModel.availability.totalCopies, equals(5));
      });

      test('should have correct metadata value object', () {
        expect(testBookModel.metadata.isbn, equals('978-0-123456-78-9'));
        expect(testBookModel.metadata.publisher, equals('Test Publisher'));
        expect(testBookModel.metadata.ageAppropriateness, equals(AgeAppropriateness.adult));
        expect(testBookModel.metadata.genres, equals(['Fiction', 'Mystery']));
        expect(testBookModel.metadata.pageCount, equals(320));
        expect(testBookModel.metadata.language, equals('English'));
        expect(testBookModel.metadata.edition, equals('1st Edition'));
      });
    });

    group('fromJson', () {
      test('should return a valid BookModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 'json-book-id',
          'title': 'JSON Book Title',
          'author': 'JSON Author',
          'imageUrls': ['json_image1.jpg', 'json_image2.jpg'],
          'rating': 3.8,
          'pricing': {
            'salePrice': 25.99,
            'discountedSalePrice': 20.99,
            'rentPrice': 8.99,
            'discountedRentPrice': 6.99,
            'percentageDiscountForRent': 22.2,
            'percentageDiscountForSale': 19.2,
            'minimumCostToBuy': 12.0,
            'maximumCostToBuy': 30.0,
          },
          'availability': {
            'availableForRentCount': 4,
            'availableForSaleCount': 1,
            'totalCopies': 6,
          },
          'metadata': {
            'isbn': '978-1-234567-89-0',
            'publisher': 'JSON Publisher',
            'ageAppropriateness': 'young_adult',
            'genres': ['Adventure', 'Fantasy'],
            'pageCount': 280,
            'language': 'English',
            'edition': '2nd Edition',
          },
          'isFromFriend': false,
          'isFavorite': true,
          'description': 'A fascinating JSON book description',
          'publishedYear': 2022,
          'createdAt': '2023-06-01T12:00:00.000Z',
          'updatedAt': '2023-06-01T12:00:00.000Z',
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.id, equals('json-book-id'));
        expect(result.title, equals('JSON Book Title'));
        expect(result.author, equals('JSON Author'));
        expect(result.imageUrls, equals(['json_image1.jpg', 'json_image2.jpg']));
        expect(result.rating, equals(3.8));
        expect(result.pricing.salePrice, equals(25.99));
        expect(result.pricing.discountedSalePrice, equals(20.99));
        expect(result.availability.availableForRentCount, equals(4));
        expect(result.availability.totalCopies, equals(6));
        expect(result.metadata.isbn, equals('978-1-234567-89-0'));
        expect(result.metadata.ageAppropriateness, equals(AgeAppropriateness.youngAdult));
        expect(result.metadata.genres, equals(['Adventure', 'Fantasy']));
        expect(result.isFromFriend, isFalse);
        expect(result.description, equals('A fascinating JSON book description'));
        expect(result.publishedYear, equals(2022));
      });

      test('should handle minimal JSON with defaults', () {
        // Arrange
        final json = {
          'id': 'minimal-book-id',
          'title': 'Minimal Book',
          'author': 'Minimal Author',
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.id, equals('minimal-book-id'));
        expect(result.title, equals('Minimal Book'));
        expect(result.author, equals('Minimal Author'));
        expect(result.imageUrls, isEmpty);
        expect(result.rating, equals(0.0));
        expect(result.pricing.salePrice, equals(0.0));
        expect(result.pricing.rentPrice, equals(0.0));
        expect(result.availability.totalCopies, equals(1));
        expect(result.metadata.genres, equals(['Unknown']));
        expect(result.metadata.language, equals('English'));
        expect(result.metadata.ageAppropriateness, equals(AgeAppropriateness.allAges));
        expect(result.isFromFriend, isFalse);
        expect(result.description, isEmpty);
        expect(result.publishedYear, equals(DateTime.now().year));
      });

      test('should handle null pricing gracefully', () {
        // Arrange
        final json = {
          'id': 'no-pricing-book',
          'title': 'No Pricing Book',
          'author': 'Author',
          'pricing': null,
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.pricing.salePrice, equals(0.0));
        expect(result.pricing.rentPrice, equals(0.0));
        expect(result.pricing.discountedSalePrice, isNull);
        expect(result.pricing.discountedRentPrice, isNull);
      });

      test('should handle null availability gracefully', () {
        // Arrange
        final json = {
          'id': 'no-availability-book',
          'title': 'No Availability Book',
          'author': 'Author',
          'availability': null,
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.availability.availableForRentCount, equals(0));
        expect(result.availability.availableForSaleCount, equals(0));
        expect(result.availability.totalCopies, equals(1));
      });

      test('should handle null metadata gracefully', () {
        // Arrange
        final json = {
          'id': 'no-metadata-book',
          'title': 'No Metadata Book',
          'author': 'Author',
          'metadata': null,
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.metadata.isbn, isNull);
        expect(result.metadata.publisher, isNull);
        expect(result.metadata.ageAppropriateness, equals(AgeAppropriateness.allAges));
        expect(result.metadata.genres, equals(['Unknown']));
        expect(result.metadata.pageCount, equals(0));
        expect(result.metadata.language, equals('English'));
        expect(result.metadata.edition, isNull);
      });

      test('should handle different age appropriateness values', () {
        for (final ageType in AgeAppropriateness.values) {
          // Arrange
          final json = {
            'id': 'age-test-book',
            'title': 'Age Test Book',
            'author': 'Test Author',
            'metadata': {
              'ageAppropriateness': ageType.name,
            },
          };

          // Act
          final result = BookModel.fromJson(json);

          // Assert
          expect(result.metadata.ageAppropriateness, equals(ageType));
        }
      });

      test('should handle alternative age appropriateness formats', () {
        // Arrange
        final testCases = [
          {'input': 'young_adult', 'expected': AgeAppropriateness.youngAdult},
          {'input': 'youngadult', 'expected': AgeAppropriateness.youngAdult},
          {'input': 'all_ages', 'expected': AgeAppropriateness.allAges},
          {'input': 'allages', 'expected': AgeAppropriateness.allAges},
          {'input': 'CHILDREN', 'expected': AgeAppropriateness.children},
          {'input': 'Adult', 'expected': AgeAppropriateness.adult},
          {'input': 'unknown', 'expected': AgeAppropriateness.allAges},
          {'input': null, 'expected': AgeAppropriateness.allAges},
        ];

        for (final testCase in testCases) {
          // Act
          final json = {
            'id': 'age-format-test',
            'title': 'Age Format Test',
            'author': 'Test Author',
            'metadata': {
              'ageAppropriateness': testCase['input'],
            },
          };
          final result = BookModel.fromJson(json);

          // Assert
          expect(result.metadata.ageAppropriateness, equals(testCase['expected']));
        }
      });

      test('should handle empty imageUrls list', () {
        // Arrange
        final json = {
          'id': 'no-images-book',
          'title': 'No Images Book',
          'author': 'Author',
          'imageUrls': <String>[],
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.imageUrls, isEmpty);
      });

      test('should handle empty genres list', () {
        // Arrange
        final json = {
          'id': 'no-genres-book',
          'title': 'No Genres Book',
          'author': 'Author',
          'metadata': {
            'genres': <String>[],
          },
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.metadata.genres, isEmpty);
      });

      test('should handle invalid date strings gracefully', () {
        // Arrange
        final json = {
          'id': 'invalid-date-book',
          'title': 'Invalid Date Book',
          'author': 'Author',
          'createdAt': 'invalid-date',
          'updatedAt': 'invalid-date',
        };

        // Act & Assert
        expect(() => BookModel.fromJson(json), throwsFormatException);
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = testBookModel.toJson();

        // Assert
        expect(result['id'], equals('test-book-id'));
        expect(result['title'], equals('Test Book Title'));
        expect(result['author'], equals('Test Author'));
        expect(result['imageUrls'], equals(['image1.jpg', 'image2.jpg']));
        expect(result['rating'], equals(4.5));
        expect(result['isFromFriend'], isTrue);
        expect(result['isFavorite'], isFalse);
        expect(result['description'], equals('A compelling test book description'));
        expect(result['publishedYear'], equals(2023));
        expect(result['createdAt'], equals(testDateTime.toIso8601String()));
        expect(result['updatedAt'], equals(testDateTime.toIso8601String()));
      });

      test('should serialize pricing correctly', () {
        // Act
        final result = testBookModel.toJson();
        final pricing = result['pricing'] as Map<String, dynamic>;

        // Assert
        expect(pricing['salePrice'], equals(29.99));
        expect(pricing['discountedSalePrice'], equals(24.99));
        expect(pricing['rentPrice'], equals(9.99));
        expect(pricing['discountedRentPrice'], equals(7.99));
        expect(pricing['percentageDiscountForRent'], equals(20.0));
        expect(pricing['percentageDiscountForSale'], equals(16.67));
        expect(pricing['minimumCostToBuy'], equals(15.0));
        expect(pricing['maximumCostToBuy'], equals(35.0));
      });

      test('should serialize availability correctly', () {
        // Act
        final result = testBookModel.toJson();
        final availability = result['availability'] as Map<String, dynamic>;

        // Assert
        expect(availability['availableForRentCount'], equals(3));
        expect(availability['availableForSaleCount'], equals(2));
        expect(availability['totalCopies'], equals(5));
      });

      test('should serialize metadata correctly', () {
        // Act
        final result = testBookModel.toJson();
        final metadata = result['metadata'] as Map<String, dynamic>;

        // Assert
        expect(metadata['isbn'], equals('978-0-123456-78-9'));
        expect(metadata['publisher'], equals('Test Publisher'));
        expect(metadata['ageAppropriateness'], equals('adult'));
        expect(metadata['genres'], equals(['Fiction', 'Mystery']));
        expect(metadata['pageCount'], equals(320));
        expect(metadata['language'], equals('English'));
        expect(metadata['edition'], equals('1st Edition'));
      });

      test('should handle null values in serialization', () {
        // Arrange
        final bookWithNulls = BookModel(
          id: 'null-test-book',
          title: 'Null Test Book',
          author: 'Test Author',
          imageUrls: const [],
          rating: 0.0,
          pricing: const BookPricing(
            salePrice: 20.0,
            rentPrice: 5.0,
          ),
          availability: const BookAvailability(
            availableForRentCount: 1,
            availableForSaleCount: 1,
            totalCopies: 2,
          ),
          metadata: const BookMetadata(
            ageAppropriateness: AgeAppropriateness.allAges,
            genres: ['Test'],
            pageCount: 100,
            language: 'English',
          ),
          isFromFriend: false,          description: '',
          publishedYear: 2023,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final result = bookWithNulls.toJson();

        // Assert
        final pricing = result['pricing'] as Map<String, dynamic>;
        final metadata = result['metadata'] as Map<String, dynamic>;
        
        expect(pricing['discountedSalePrice'], isNull);
        expect(pricing['discountedRentPrice'], isNull);
        expect(metadata['isbn'], isNull);
        expect(metadata['publisher'], isNull);
        expect(metadata['edition'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create BookModel from Book entity', () {
        // Arrange
        final bookEntity = Book(
          id: 'entity-book-id',
          title: 'Entity Book Title',
          author: 'Entity Author',
          imageUrls: const ['entity_image.jpg'],
          rating: 3.5,
          pricing: const BookPricing(
            salePrice: 19.99,
            rentPrice: 6.99,
          ),
          availability: const BookAvailability(
            availableForRentCount: 2,
            availableForSaleCount: 3,
            totalCopies: 5,
          ),
          metadata: const BookMetadata(
            ageAppropriateness: AgeAppropriateness.children,
            genres: ['Children', 'Educational'],
            pageCount: 150,
            language: 'English',
          ),
          isFromFriend: true,
          isFavorite: false,
          description: 'An educational children book',
          publishedYear: 2021,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final result = BookModel.fromEntity(bookEntity);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.id, equals('entity-book-id'));
        expect(result.title, equals('Entity Book Title'));
        expect(result.author, equals('Entity Author'));
        expect(result.imageUrls, equals(['entity_image.jpg']));
        expect(result.rating, equals(3.5));
        expect(result.pricing.salePrice, equals(19.99));
        expect(result.availability.totalCopies, equals(5));
        expect(result.metadata.ageAppropriateness, equals(AgeAppropriateness.children));
        expect(result.isFromFriend, isTrue);
        expect(result.description, equals('An educational children book'));
        expect(result.publishedYear, equals(2021));
        expect(result.createdAt, equals(testDateTime));
        expect(result.updatedAt, equals(testDateTime));
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through JSON round trip', () {
        // Act
        final json = testBookModel.toJson();
        final reconstructed = BookModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(testBookModel.id));
        expect(reconstructed.title, equals(testBookModel.title));
        expect(reconstructed.author, equals(testBookModel.author));
        expect(reconstructed.imageUrls, equals(testBookModel.imageUrls));
        expect(reconstructed.rating, equals(testBookModel.rating));
        expect(reconstructed.pricing.salePrice, equals(testBookModel.pricing.salePrice));
        expect(reconstructed.availability.totalCopies, equals(testBookModel.availability.totalCopies));
        expect(reconstructed.metadata.isbn, equals(testBookModel.metadata.isbn));
        expect(reconstructed.metadata.ageAppropriateness, equals(testBookModel.metadata.ageAppropriateness));
        expect(reconstructed.isFromFriend, equals(testBookModel.isFromFriend));
        expect(reconstructed.description, equals(testBookModel.description));
        expect(reconstructed.publishedYear, equals(testBookModel.publishedYear));
        expect(reconstructed.createdAt, equals(testBookModel.createdAt));
        expect(reconstructed.updatedAt, equals(testBookModel.updatedAt));
      });
    });

    group('Edge Cases', () {
      test('should handle extremely large numbers', () {
        // Arrange
        final json = {
          'id': 'large-numbers-book',
          'title': 'Large Numbers Book',
          'author': 'Author',
          'rating': 999999.99,
          'pricing': {
            'salePrice': 999999.99,
            'rentPrice': 999999.99,
          },
          'publishedYear': 9999,
          'metadata': {
            'pageCount': 999999,
          },
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.rating, equals(999999.99));
        expect(result.pricing.salePrice, equals(999999.99));
        expect(result.publishedYear, equals(9999));
        expect(result.metadata.pageCount, equals(999999));
      });

      test('should handle special characters in strings', () {
        // Arrange
        final json = {
          'id': 'special-chars-book',
          'title': 'Title with Ã©Ã±Ã±Ã´Ã±s & symbols!@#\$%^&*()',
          'author': 'Ã‘Ã¡mÃ© wÃ¯th spÃ«cÃ¬Ã¢l chÃ¤rs',
          'description': 'Description with unicode: ä½ å¥½ä¸–ç•Œ ðŸŒ ðŸ“š',
          'metadata': {
            'publisher': 'PÃ¼blÃ®shÃ©r Ã‘amÃ«',
            'edition': '1Ã¨re Ã©dition',
          },
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.title, equals('Title with Ã©Ã±Ã±Ã´Ã±s & symbols!@#\$%^&*()'));
        expect(result.author, equals('Ã‘Ã¡mÃ© wÃ¯th spÃ«cÃ¬Ã¢l chÃ¤rs'));
        expect(result.description, equals('Description with unicode: ä½ å¥½ä¸–ç•Œ ðŸŒ ðŸ“š'));
        expect(result.metadata.publisher, equals('PÃ¼blÃ®shÃ©r Ã‘amÃ«'));
        expect(result.metadata.edition, equals('1Ã¨re Ã©dition'));
      });

      test('should handle empty strings', () {
        // Arrange
        final json = {
          'id': '',
          'title': '',
          'author': '',
          'description': '',
          'metadata': {
            'isbn': '',
            'publisher': '',
            'edition': '',
            'language': '',
          },
        };

        // Act
        final result = BookModel.fromJson(json);

        // Assert
        expect(result.id, isEmpty);
        expect(result.title, isEmpty);
        expect(result.author, isEmpty);
        expect(result.description, isEmpty);
        expect(result.metadata.isbn, isEmpty);
        expect(result.metadata.publisher, isEmpty);
        expect(result.metadata.edition, isEmpty);
        expect(result.metadata.language, isEmpty);
      });
    });
  });
}
