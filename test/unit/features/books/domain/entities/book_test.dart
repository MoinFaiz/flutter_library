import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

void main() {
  late Book testBook;
  late BookPricing testPricing;
  late BookAvailability testAvailability;
  late BookMetadata testMetadata;

  setUp(() {
    testPricing = const BookPricing(
      salePrice: 100.0,
      rentPrice: 10.0,
      discountedSalePrice: 90.0,
      discountedRentPrice: 9.5,
    );

    testAvailability = const BookAvailability(
      totalCopies: 10,
      availableForSaleCount: 5,
      availableForRentCount: 3,
    );

    testMetadata = const BookMetadata(
      isbn: '978-3-16-148410-0',
      publisher: 'Test Publisher',
      pageCount: 300,
      language: 'English',
      genres: ['Fiction', 'Adventure'],
      ageAppropriateness: AgeAppropriateness.allAges,
    );

    testBook = Book(
      id: 'book-123',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/image1.jpg'],
      rating: 4.5,
      pricing: testPricing,
      availability: testAvailability,
      metadata: testMetadata,
      isFromFriend: false,
      isFavorite: false,
      description: 'A test book description',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );
  });

  group('Book Entity Tests', () {
    group('Constructor', () {
      test('should create a book with all required fields', () {
        expect(testBook.id, equals('book-123'));
        expect(testBook.title, equals('Test Book'));
        expect(testBook.author, equals('Test Author'));
        expect(testBook.imageUrls, isNotEmpty);
        expect(testBook.rating, equals(4.5));
        expect(testBook.pricing, equals(testPricing));
        expect(testBook.availability, equals(testAvailability));
        expect(testBook.metadata, equals(testMetadata));
      });

      test('should create book with multiple images', () {
        final book = testBook.copyWith(
          imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
        );

        expect(book.imageUrls.length, equals(3));
      });
    });

    group('Convenience Getters', () {
      test('primaryImageUrl should return first image', () {
        expect(testBook.primaryImageUrl, equals('https://example.com/image1.jpg'));
      });

      test('primaryImageUrl should return empty string when no images', () {
        final book = testBook.copyWith(imageUrls: []);
        expect(book.primaryImageUrl, equals(''));
      });

      test('primaryGenre should return first genre', () {
        expect(testBook.primaryGenre, equals('Fiction'));
      });

      test('genres should return all genres', () {
        expect(testBook.genres, equals(['Fiction', 'Adventure']));
      });

      test('hasMultipleImages should return false for single image', () {
        expect(testBook.hasMultipleImages, isFalse);
      });

      test('hasMultipleImages should return true for multiple images', () {
        final book = testBook.copyWith(
          imageUrls: ['image1.jpg', 'image2.jpg'],
        );
        expect(book.hasMultipleImages, isTrue);
      });

      test('hasAnyImages should return true when images exist', () {
        expect(testBook.hasAnyImages, isTrue);
      });

      test('hasAnyImages should return false when no images', () {
        final book = testBook.copyWith(imageUrls: []);
        expect(book.hasAnyImages, isFalse);
      });
    });

    group('Pricing Convenience Getters', () {
      test('salePrice should return final sale price', () {
        expect(testBook.salePrice, equals(testPricing.finalSalePrice));
      });

      test('rentPrice should return final rent price', () {
        expect(testBook.rentPrice, equals(testPricing.finalRentPrice));
      });

      test('hasDiscount should return true when pricing has discount', () {
        expect(testBook.hasDiscount, equals(testPricing.hasSaleDiscount || testPricing.hasRentDiscount));
      });
    });

    group('Availability Convenience Getters', () {
      test('isAvailableForRent should return availability status', () {
        expect(testBook.isAvailableForRent, equals(testAvailability.hasRentAvailable));
      });

      test('isAvailableForSale should return availability status', () {
        expect(testBook.isAvailableForSale, equals(testAvailability.hasSaleAvailable));
      });

      test('availabilityStatus should return status string', () {
        expect(testBook.availabilityStatus, equals(testAvailability.availabilityStatus));
      });
    });

    group('Business Logic Methods', () {
      test('isInPriceRange should return true for valid range', () {
        final result = testBook.isInPriceRange(50.0, 150.0);
        expect(result, isTrue);
      });

      test('isInPriceRange should return false for out of range', () {
        final result = testBook.isInPriceRange(200.0, 300.0);
        expect(result, isFalse);
      });

      test('isInPriceRange should handle null min price', () {
        final result = testBook.isInPriceRange(null, 150.0);
        expect(result, isTrue);
      });

      test('isInPriceRange should handle null max price', () {
        final result = testBook.isInPriceRange(50.0, null);
        expect(result, isTrue);
      });

      test('matchesGenre should return true for matching genre', () {
        expect(testBook.matchesGenre('Fiction'), isTrue);
        expect(testBook.matchesGenre('fiction'), isTrue); // Case insensitive
      });

      test('matchesGenre should return false for non-matching genre', () {
        expect(testBook.matchesGenre('Mystery'), isFalse);
      });

      test('matchesGenre should handle partial matches', () {
        expect(testBook.matchesGenre('Fic'), isTrue);
        expect(testBook.matchesGenre('Adven'), isTrue);
      });

      test('isAppropriateForAge should return true for matching age', () {
        expect(testBook.isAppropriateForAge(AgeAppropriateness.allAges), isTrue);
      });

      test('isAppropriateForAge should return true for allAges books', () {
        final book = testBook.copyWith(
          metadata: testMetadata.copyWith(
            ageAppropriateness: AgeAppropriateness.allAges,
          ),
        );
        expect(book.isAppropriateForAge(AgeAppropriateness.youngAdult), isTrue);
      });

      test('isAppropriateForAge should return false for non-matching age', () {
        final book = testBook.copyWith(
          metadata: testMetadata.copyWith(
            ageAppropriateness: AgeAppropriateness.adult,
          ),
        );
        expect(book.isAppropriateForAge(AgeAppropriateness.children), isFalse);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated title', () {
        final updatedBook = testBook.copyWith(title: 'New Title');
        
        expect(updatedBook.title, equals('New Title'));
        expect(updatedBook.id, equals(testBook.id));
        expect(updatedBook.author, equals(testBook.author));
      });

      test('should create a copy with updated rating', () {
        final updatedBook = testBook.copyWith(rating: 5.0);
        
        expect(updatedBook.rating, equals(5.0));
        expect(updatedBook.title, equals(testBook.title));
      });

      test('should create a copy with updated isFavorite', () {
        final updatedBook = testBook.copyWith(isFavorite: true);
        
        expect(updatedBook.isFavorite, isTrue);
        expect(testBook.isFavorite, isFalse);
      });

      test('should create a copy with updated pricing', () {
        final newPricing = const BookPricing(
          salePrice: 200.0,
          rentPrice: 20.0,
        );
        final updatedBook = testBook.copyWith(pricing: newPricing);
        
        expect(updatedBook.pricing, equals(newPricing));
        expect(updatedBook.salePrice, equals(200.0));
      });

      test('should not modify original book', () {
        final originalTitle = testBook.title;
        testBook.copyWith(title: 'New Title');
        
        expect(testBook.title, equals(originalTitle));
      });

      test('should create a copy with multiple updated fields', () {
        final updatedBook = testBook.copyWith(
          title: 'New Title',
          author: 'New Author',
          rating: 5.0,
          isFavorite: true,
        );
        
        expect(updatedBook.title, equals('New Title'));
        expect(updatedBook.author, equals('New Author'));
        expect(updatedBook.rating, equals(5.0));
        expect(updatedBook.isFavorite, isTrue);
      });
    });

    group('Equatable', () {
      test('should be equal for same values', () {
        final book1 = testBook;
        final book2 = testBook.copyWith();
        
        expect(book1, equals(book2));
      });

      test('should not be equal for different ids', () {
        final book1 = testBook;
        final book2 = testBook.copyWith(id: 'different-id');
        
        expect(book1, isNot(equals(book2)));
      });

      test('should not be equal for different titles', () {
        final book1 = testBook;
        final book2 = testBook.copyWith(title: 'Different Title');
        
        expect(book1, isNot(equals(book2)));
      });

      test('should not be equal for different ratings', () {
        final book1 = testBook;
        final book2 = testBook.copyWith(rating: 3.0);
        
        expect(book1, isNot(equals(book2)));
      });

      test('should not be equal for different isFavorite', () {
        final book1 = testBook;
        final book2 = testBook.copyWith(isFavorite: true);
        
        expect(book1, isNot(equals(book2)));
      });
    });

    group('Edge Cases', () {
      test('should handle empty image URLs list', () {
        final book = testBook.copyWith(imageUrls: []);
        
        expect(book.imageUrls, isEmpty);
        expect(book.primaryImageUrl, equals(''));
        expect(book.hasAnyImages, isFalse);
      });

      test('should handle zero rating', () {
        final book = testBook.copyWith(rating: 0.0);
        expect(book.rating, equals(0.0));
      });

      test('should handle maximum rating', () {
        final book = testBook.copyWith(rating: 5.0);
        expect(book.rating, equals(5.0));
      });

      test('should handle very long description', () {
        final longDescription = 'A' * 10000;
        final book = testBook.copyWith(description: longDescription);
        
        expect(book.description.length, equals(10000));
      });

      test('should handle empty description', () {
        final book = testBook.copyWith(description: '');
        expect(book.description, equals(''));
      });

      test('should handle old published years', () {
        final book = testBook.copyWith(publishedYear: 1500);
        expect(book.publishedYear, equals(1500));
      });

      test('should handle future published years', () {
        final book = testBook.copyWith(publishedYear: 2050);
        expect(book.publishedYear, equals(2050));
      });

      test('should handle special characters in title and author', () {
        final book = testBook.copyWith(
          title: 'Test & Title (Special)',
          author: "O'Connor-Smith",
        );
        
        expect(book.title, contains('&'));
        expect(book.author, contains("'"));
      });

      test('should handle unicode characters', () {
        final book = testBook.copyWith(
          title: 'Über die Brücke',
          author: 'José García',
        );
        
        expect(book.title, contains('Ü'));
        expect(book.author, contains('é'));
      });
    });

    group('Props', () {
      test('should include all fields in props', () {
        expect(testBook.props.length, equals(14));
        expect(testBook.props, contains(testBook.id));
        expect(testBook.props, contains(testBook.title));
        expect(testBook.props, contains(testBook.author));
        expect(testBook.props, contains(testBook.rating));
        expect(testBook.props, contains(testBook.pricing));
        expect(testBook.props, contains(testBook.availability));
        expect(testBook.props, contains(testBook.metadata));
      });
    });
  });
}
