import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('Book Entity Tests', () {
    final mockPricing = BookPricing(
      salePrice: 25.99,
      discountedSalePrice: 22.09, // 15% discount applied
      rentPrice: 5.99,
      discountedRentPrice: 5.39, // 10% discount applied
      percentageDiscountForSale: 0.15,
      percentageDiscountForRent: 0.10,
    );

    final mockAvailability = BookAvailability(
      totalCopies: 5,
      availableForRentCount: 3,
      availableForSaleCount: 2,
    );

    final mockMetadata = BookMetadata(
      isbn: '978-0123456789',
      publisher: 'Test Publisher',
      genres: ['Fiction', 'Adventure', 'Young Adult'],
      language: 'English',
      pageCount: 350,
      ageAppropriateness: AgeAppropriateness.youngAdult,
    );

    final mockBook = Book(
      id: 'book_1',
      title: 'Test Adventure',
      author: 'John Doe',
      imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
      rating: 4.5,
      pricing: mockPricing,
      availability: mockAvailability,
      metadata: mockMetadata,
      isFromFriend: false,
      isFavorite: true,
      description: 'A thrilling adventure story that captivates readers.',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 6, 1),
    );

    group('Constructor and Properties', () {
      test('should create Book with all required properties', () {
        expect(mockBook.id, 'book_1');
        expect(mockBook.title, 'Test Adventure');
        expect(mockBook.author, 'John Doe');
        expect(mockBook.imageUrls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
        expect(mockBook.rating, 4.5);
        expect(mockBook.pricing, mockPricing);
        expect(mockBook.availability, mockAvailability);
        expect(mockBook.metadata, mockMetadata);
        expect(mockBook.isFromFriend, false);
        expect(mockBook.isFavorite, true);
        expect(mockBook.description, 'A thrilling adventure story that captivates readers.');
        expect(mockBook.publishedYear, 2023);
        expect(mockBook.createdAt, DateTime(2023, 1, 1));
        expect(mockBook.updatedAt, DateTime(2023, 6, 1));
      });
    });

    group('Convenience Getters', () {
      test('primaryImageUrl should return first image URL', () {
        expect(mockBook.primaryImageUrl, 'https://example.com/image1.jpg');
      });

      test('primaryImageUrl should return empty string when no images', () {
        final bookWithoutImages = mockBook.copyWith(imageUrls: []);
        expect(bookWithoutImages.primaryImageUrl, '');
      });

      test('primaryGenre should return first genre from metadata', () {
        expect(mockBook.primaryGenre, 'Fiction');
      });

      test('genres should return all genres from metadata', () {
        expect(mockBook.genres, ['Fiction', 'Adventure', 'Young Adult']);
      });

      test('hasMultipleImages should return true when multiple images exist', () {
        expect(mockBook.hasMultipleImages, true);
      });

      test('hasMultipleImages should return false when single image exists', () {
        final singleImageBook = mockBook.copyWith(imageUrls: ['image1.jpg']);
        expect(singleImageBook.hasMultipleImages, false);
      });

      test('hasAnyImages should return true when images exist', () {
        expect(mockBook.hasAnyImages, true);
      });

      test('hasAnyImages should return false when no images exist', () {
        final noImageBook = mockBook.copyWith(imageUrls: []);
        expect(noImageBook.hasAnyImages, false);
      });
    });

    group('Pricing Convenience Getters', () {
      test('salePrice should return final sale price from pricing', () {
        expect(mockBook.salePrice, mockPricing.finalSalePrice);
      });

      test('rentPrice should return final rent price from pricing', () {
        expect(mockBook.rentPrice, mockPricing.finalRentPrice);
      });

      test('hasDiscount should return true when pricing has discounts', () {
        expect(mockBook.hasDiscount, true);
      });

      test('hasDiscount should return false when no discounts', () {
        final noPricingDiscount = BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        );
        final bookWithoutDiscount = mockBook.copyWith(pricing: noPricingDiscount);
        expect(bookWithoutDiscount.hasDiscount, false);
      });
    });

    group('Availability Convenience Getters', () {
      test('isAvailableForRent should return availability status', () {
        expect(mockBook.isAvailableForRent, true);
      });

      test('isAvailableForSale should return availability status', () {
        expect(mockBook.isAvailableForSale, true);
      });

      test('availabilityStatus should return status from availability', () {
        expect(mockBook.availabilityStatus, isA<String>());
      });
    });

    group('Business Logic Methods', () {
      test('isInPriceRange should delegate to pricing', () {
        expect(mockBook.isInPriceRange(20.0, 30.0), true);
        expect(mockBook.isInPriceRange(30.0, 40.0), false);
      });

      test('matchesGenre should perform case-insensitive genre matching', () {
        expect(mockBook.matchesGenre('fiction'), true);
        expect(mockBook.matchesGenre('ADVENTURE'), true);
        expect(mockBook.matchesGenre('young'), true);
        expect(mockBook.matchesGenre('Horror'), false);
      });

      test('isAppropriateForAge should check age appropriateness', () {
        expect(mockBook.isAppropriateForAge(AgeAppropriateness.youngAdult), true);
        expect(mockBook.isAppropriateForAge(AgeAppropriateness.adult), false);
      });

      test('isAppropriateForAge should always return true for allAges books', () {
        final allAgesMetadata = mockMetadata.copyWith(
          ageAppropriateness: AgeAppropriateness.allAges,
        );
        final allAgesBook = mockBook.copyWith(metadata: allAgesMetadata);
        
        expect(allAgesBook.isAppropriateForAge(AgeAppropriateness.children), true);
        expect(allAgesBook.isAppropriateForAge(AgeAppropriateness.youngAdult), true);
        expect(allAgesBook.isAppropriateForAge(AgeAppropriateness.adult), true);
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated properties', () {
        final updatedBook = mockBook.copyWith(
          title: 'Updated Title',
          rating: 5.0,
          isFavorite: false,
        );

        expect(updatedBook.title, 'Updated Title');
        expect(updatedBook.rating, 5.0);
        expect(updatedBook.isFavorite, false);
        // Other properties should remain unchanged
        expect(updatedBook.id, mockBook.id);
        expect(updatedBook.author, mockBook.author);
        expect(updatedBook.description, mockBook.description);
      });

      test('should return identical instance when no parameters provided', () {
        final copiedBook = mockBook.copyWith();
        
        expect(copiedBook.id, mockBook.id);
        expect(copiedBook.title, mockBook.title);
        expect(copiedBook.author, mockBook.author);
        expect(copiedBook.rating, mockBook.rating);
      });

      test('should allow updating complex properties', () {
        final newPricing = BookPricing(
          salePrice: 30.99,
          discountedSalePrice: 24.79, // 20% discount
          rentPrice: 7.99,
          discountedRentPrice: 6.79, // 15% discount
          percentageDiscountForSale: 0.20,
          percentageDiscountForRent: 0.15,
        );
        
        final updatedBook = mockBook.copyWith(pricing: newPricing);
        
        expect(updatedBook.pricing, newPricing);
        expect(updatedBook.salePrice, newPricing.finalSalePrice);
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final book1 = Book(
          id: 'book_1',
          title: 'Test Book',
          author: 'Test Author',
          imageUrls: ['image1.jpg'],
          rating: 4.0,
          pricing: mockPricing,
          availability: mockAvailability,
          metadata: mockMetadata,
          isFromFriend: false,
          isFavorite: false,
          description: 'Test description',
          publishedYear: 2023,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final book2 = Book(
          id: 'book_1',
          title: 'Test Book',
          author: 'Test Author',
          imageUrls: ['image1.jpg'],
          rating: 4.0,
          pricing: mockPricing,
          availability: mockAvailability,
          metadata: mockMetadata,
          isFromFriend: false,
          isFavorite: false,
          description: 'Test description',
          publishedYear: 2023,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        expect(book1, equals(book2));
        expect(book1.hashCode, equals(book2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final book1 = mockBook;
        final book2 = mockBook.copyWith(title: 'Different Title');

        expect(book1, isNot(equals(book2)));
        expect(book1.hashCode, isNot(equals(book2.hashCode)));
      });
    });

    group('Edge Cases', () {
      test('should handle empty image URLs list', () {
        final bookWithNoImages = mockBook.copyWith(imageUrls: []);
        
        expect(bookWithNoImages.primaryImageUrl, '');
        expect(bookWithNoImages.hasMultipleImages, false);
        expect(bookWithNoImages.hasAnyImages, false);
      });

      test('should handle single image URL', () {
        final bookWithSingleImage = mockBook.copyWith(imageUrls: ['single.jpg']);
        
        expect(bookWithSingleImage.primaryImageUrl, 'single.jpg');
        expect(bookWithSingleImage.hasMultipleImages, false);
        expect(bookWithSingleImage.hasAnyImages, true);
      });

      test('should handle null price range in isInPriceRange', () {
        expect(mockBook.isInPriceRange(null, 30.0), true);
        expect(mockBook.isInPriceRange(20.0, null), true);
        expect(mockBook.isInPriceRange(null, null), true);
      });

      test('should handle case-sensitive genre matching edge cases', () {
        expect(mockBook.matchesGenre(''), true); // Empty string matches any genre
        expect(mockBook.matchesGenre('fic'), true); // Partial match
        expect(mockBook.matchesGenre('FICTION'), true); // Case insensitive
      });
    });
  });
}
