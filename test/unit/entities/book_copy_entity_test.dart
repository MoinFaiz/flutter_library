import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

void main() {
  group('BookCopy Entity', () {
    const tId = 'copy_123';
    const tBookId = 'book_456';
    const tUserId = 'user_789';
    const tImageUrls = ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'];
    const tCondition = BookCondition.veryGood;
    const tIsForSale = true;
    const tIsForRent = false;
    const tIsForDonate = true;
    const tExpectedPrice = 25.99;
    const tRentPrice = 5.99;
    const tNotes = 'This book is in excellent condition with minimal wear.';
    final tUploadDate = DateTime(2023, 5, 15, 10, 30);
    final tUpdatedAt = DateTime(2023, 5, 20, 14, 45);

    final tBookCopy = BookCopy(
      id: tId,
      bookId: tBookId,
      userId: tUserId,
      imageUrls: tImageUrls,
      condition: tCondition,
      isForSale: tIsForSale,
      isForRent: tIsForRent,
      isForDonate: tIsForDonate,
      expectedPrice: tExpectedPrice,
      rentPrice: tRentPrice,
      notes: tNotes,
      uploadDate: tUploadDate,
      updatedAt: tUpdatedAt,
    );

    group('constructor', () {
      test('should create BookCopy with all fields', () {
        // act & assert
        expect(tBookCopy.id, equals(tId));
        expect(tBookCopy.bookId, equals(tBookId));
        expect(tBookCopy.userId, equals(tUserId));
        expect(tBookCopy.imageUrls, equals(tImageUrls));
        expect(tBookCopy.condition, equals(tCondition));
        expect(tBookCopy.isForSale, equals(tIsForSale));
        expect(tBookCopy.isForRent, equals(tIsForRent));
        expect(tBookCopy.isForDonate, equals(tIsForDonate));
        expect(tBookCopy.expectedPrice, equals(tExpectedPrice));
        expect(tBookCopy.rentPrice, equals(tRentPrice));
        expect(tBookCopy.notes, equals(tNotes));
        expect(tBookCopy.uploadDate, equals(tUploadDate));
        expect(tBookCopy.updatedAt, equals(tUpdatedAt));
      });

      test('should create BookCopy with required fields only', () {
        // arrange
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        // assert
        expect(bookCopy.id, isNull);
        expect(bookCopy.bookId, isNull);
        expect(bookCopy.userId, isNull);
        expect(bookCopy.imageUrls, equals(tImageUrls));
        expect(bookCopy.condition, equals(BookCondition.good));
        expect(bookCopy.isForSale, isFalse);
        expect(bookCopy.isForRent, isFalse);
        expect(bookCopy.isForDonate, isTrue);
        expect(bookCopy.expectedPrice, isNull);
        expect(bookCopy.rentPrice, isNull);
        expect(bookCopy.notes, isNull);
        expect(bookCopy.uploadDate, isNull);
        expect(bookCopy.updatedAt, isNull);
      });
    });

    group('isAvailable getter', () {
      test('should return true when isForSale is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isAvailable, isTrue);
      });

      test('should return true when isForRent is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
        );

        expect(bookCopy.isAvailable, isTrue);
      });

      test('should return true when isForDonate is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.isAvailable, isTrue);
      });

      test('should return true when multiple availability options are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: true,
        );

        expect(bookCopy.isAvailable, isTrue);
      });

      test('should return false when all availability options are false', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isAvailable, isFalse);
      });
    });

    group('availabilityType getter', () {
      test('should return "Sale, Rent & Donate" when all are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: true,
        );

        expect(bookCopy.availabilityType, equals('Sale, Rent & Donate'));
      });

      test('should return "Sale & Rent" when sale and rent are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
        );

        expect(bookCopy.availabilityType, equals('Sale & Rent'));
      });

      test('should return "Sale & Donate" when sale and donate are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.availabilityType, equals('Sale & Donate'));
      });

      test('should return "Rent & Donate" when rent and donate are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: true,
        );

        expect(bookCopy.availabilityType, equals('Rent & Donate'));
      });

      test('should return "For Sale" when only sale is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.availabilityType, equals('For Sale'));
      });

      test('should return "For Rent" when only rent is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
        );

        expect(bookCopy.availabilityType, equals('For Rent'));
      });

      test('should return "For Donate" when only donate is true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.availabilityType, equals('For Donate'));
      });

      test('should return "Not Available" when all are false', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.availabilityType, equals('Not Available'));
      });
    });

    group('isValid getter', () {
      test('should return true when has images and at least one availability option', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isValid, isTrue);
      });

      test('should return false when imageUrls is empty', () {
        const bookCopy = BookCopy(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isValid, isFalse);
      });

      test('should return false when no availability options are true', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isValid, isFalse);
      });

      test('should return false when imageUrls is empty and no availability options', () {
        const bookCopy = BookCopy(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.isValid, isFalse);
      });
    });

    group('hasPricing getter', () {
      test('should return true when isForSale is true and expectedPrice is set', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 25.99,
        );

        expect(bookCopy.hasPricing, isTrue);
      });

      test('should return true when isForRent is true and rentPrice is set', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
          rentPrice: 5.99,
        );

        expect(bookCopy.hasPricing, isTrue);
      });

      test('should return true when both sale and rent have prices', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 25.99,
          rentPrice: 5.99,
        );

        expect(bookCopy.hasPricing, isTrue);
      });

      test('should return false when isForSale is true but expectedPrice is null', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );

        expect(bookCopy.hasPricing, isFalse);
      });

      test('should return false when isForRent is true but rentPrice is null', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
        );

        expect(bookCopy.hasPricing, isFalse);
      });

      test('should return false when only donate is available', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.hasPricing, isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // arrange
        const newId = 'new_copy_123';
        const newCondition = BookCondition.new_;
        const newIsForSale = false;
        final newUploadDate = DateTime(2023, 6, 1);

        // act
        final result = tBookCopy.copyWith(
          id: newId,
          condition: newCondition,
          isForSale: newIsForSale,
          uploadDate: newUploadDate,
        );

        // assert
        expect(result.id, equals(newId));
        expect(result.condition, equals(newCondition));
        expect(result.isForSale, equals(newIsForSale));
        expect(result.uploadDate, equals(newUploadDate));
        // Check unchanged fields
        expect(result.bookId, equals(tBookId));
        expect(result.userId, equals(tUserId));
        expect(result.imageUrls, equals(tImageUrls));
        expect(result.isForRent, equals(tIsForRent));
        expect(result.isForDonate, equals(tIsForDonate));
        expect(result.expectedPrice, equals(tExpectedPrice));
        expect(result.rentPrice, equals(tRentPrice));
        expect(result.notes, equals(tNotes));
        expect(result.updatedAt, equals(tUpdatedAt));
      });

      test('should return copy when no fields are updated', () {
        // act
        final result = tBookCopy.copyWith();

        // assert
        expect(result, equals(tBookCopy));
        expect(result, isNot(same(tBookCopy))); // Different instance
      });

      test('should preserve original values when null is passed', () {
        // act
        final result = tBookCopy.copyWith(
          id: null,
          expectedPrice: null,
          notes: null,
        );

        // assert
        expect(result.id, equals(tBookCopy.id));
        expect(result.expectedPrice, equals(tBookCopy.expectedPrice));
        expect(result.notes, equals(tBookCopy.notes));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final bookCopy1 = tBookCopy;
        final bookCopy2 = BookCopy(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          imageUrls: tImageUrls,
          condition: tCondition,
          isForSale: tIsForSale,
          isForRent: tIsForRent,
          isForDonate: tIsForDonate,
          expectedPrice: tExpectedPrice,
          rentPrice: tRentPrice,
          notes: tNotes,
          uploadDate: tUploadDate,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(bookCopy1, equals(bookCopy2));
        expect(bookCopy1.hashCode, equals(bookCopy2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final bookCopy1 = tBookCopy;
        final bookCopy2 = tBookCopy.copyWith(id: 'different_id');

        // assert
        expect(bookCopy1, isNot(equals(bookCopy2)));
        expect(bookCopy1.hashCode, isNot(equals(bookCopy2.hashCode)));
      });
    });

    group('props', () {
      test('should return correct list of properties', () {
        // act
        final props = tBookCopy.props;

        // assert
        expect(props, equals([
          tId,
          tBookId,
          tUserId,
          tImageUrls,
          tCondition,
          tIsForSale,
          tIsForRent,
          tIsForDonate,
          tExpectedPrice,
          tRentPrice,
          tNotes,
          tUploadDate,
          tUpdatedAt,
        ]));
      });
    });

    group('BookCondition enum', () {
      test('should have all expected conditions', () {
        final conditions = BookCondition.values;

        expect(conditions, contains(BookCondition.new_));
        expect(conditions, contains(BookCondition.likeNew));
        expect(conditions, contains(BookCondition.veryGood));
        expect(conditions, contains(BookCondition.good));
        expect(conditions, contains(BookCondition.acceptable));
        expect(conditions, contains(BookCondition.poor));
      });

      test('should have correct displayName for all conditions', () {
        final expectedDisplayNames = {
          BookCondition.new_: 'New',
          BookCondition.likeNew: 'Like New',
          BookCondition.veryGood: 'Very Good',
          BookCondition.good: 'Good',
          BookCondition.acceptable: 'Acceptable',
          BookCondition.poor: 'Poor',
        };

        expectedDisplayNames.forEach((condition, expectedName) {
          expect(condition.displayName, equals(expectedName));
        });
      });

      test('should have correct description for all conditions', () {
        final expectedDescriptions = {
          BookCondition.new_: 'Brand new, unused book',
          BookCondition.likeNew: 'Nearly new with minimal wear',
          BookCondition.veryGood: 'Some wear but still in great condition',
          BookCondition.good: 'Normal wear with some signs of use',
          BookCondition.acceptable: 'Significant wear but still readable',
          BookCondition.poor: 'Heavy wear, may have damage',
        };

        expectedDescriptions.forEach((condition, expectedDescription) {
          expect(condition.description, equals(expectedDescription));
        });
      });
    });

    group('edge cases', () {
      test('should handle empty imageUrls list', () {
        const bookCopy = BookCopy(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.imageUrls, isEmpty);
        expect(bookCopy.isValid, isFalse);
      });

      test('should handle very long notes', () {
        final longNotes = 'A' * 10000;
        final bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
          notes: longNotes,
        );

        expect(bookCopy.notes, equals(longNotes));
        expect(bookCopy.notes!.length, equals(10000));
      });

      test('should handle zero prices', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 0.0,
          rentPrice: 0.0,
        );

        expect(bookCopy.expectedPrice, equals(0.0));
        expect(bookCopy.rentPrice, equals(0.0));
        expect(bookCopy.hasPricing, isTrue); // Zero is still a valid price
      });

      test('should handle negative prices', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: -5.0,
          rentPrice: -2.0,
        );

        expect(bookCopy.expectedPrice, equals(-5.0));
        expect(bookCopy.rentPrice, equals(-2.0));
        expect(bookCopy.hasPricing, isTrue);
      });

      test('should handle very large prices', () {
        const bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 999999.99,
          rentPrice: 999999.99,
        );

        expect(bookCopy.expectedPrice, equals(999999.99));
        expect(bookCopy.rentPrice, equals(999999.99));
        expect(bookCopy.hasPricing, isTrue);
      });

      test('should handle many image URLs', () {
        final manyImages = List.generate(100, (i) => 'https://example.com/image$i.jpg');
        final bookCopy = BookCopy(
          imageUrls: manyImages,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );

        expect(bookCopy.imageUrls, equals(manyImages));
        expect(bookCopy.imageUrls.length, equals(100));
        expect(bookCopy.isValid, isTrue);
      });

      test('should handle special characters in notes', () {
        const specialNotes = 'Notes with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*() 😀🎉';
        final bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
          notes: specialNotes,
        );

        expect(bookCopy.notes, equals(specialNotes));
      });

      test('should handle future and past dates', () {
        final futureDate = DateTime(2100, 12, 31);
        final pastDate = DateTime(1900, 1, 1);
        
        final bookCopy = BookCopy(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
          uploadDate: pastDate,
          updatedAt: futureDate,
        );

        expect(bookCopy.uploadDate, equals(pastDate));
        expect(bookCopy.updatedAt, equals(futureDate));
      });
    });
  });
}
