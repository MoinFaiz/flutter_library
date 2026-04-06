import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookRating Entity', () {
    const String testBookId = 'book123';
    const String testUserId = 'user123';
    const double testRating = 4.5;
    final DateTime testCreatedAt = DateTime(2024, 1, 15);

    late BookRating testBookRating;

    setUp(() {
      testBookRating = BookRating(
        id: 'rating123',
        bookId: testBookId,
        userId: testUserId,
        rating: testRating,
        createdAt: testCreatedAt,
        updatedAt: testCreatedAt,
      );
    });

    group('isValidRating', () {
      test('should return true for valid ratings within range', () {
        // Arrange
        final validRatings = [
          testBookRating.copyWith(rating: 0.0),
          testBookRating.copyWith(rating: 2.5),
          testBookRating.copyWith(rating: 5.0),
        ];

        // Act & Assert
        for (final rating in validRatings) {
          expect(rating.isValidRating, true, reason: 'Rating ${rating.rating} should be valid');
        }
      });

      test('should return false for ratings below 0', () {
        // Arrange
        final invalidRating = testBookRating.copyWith(rating: -0.5);

        // Act
        final result = invalidRating.isValidRating;

        // Assert
        expect(result, false);
      });

      test('should return false for ratings above 5', () {
        // Arrange
        final invalidRating = testBookRating.copyWith(rating: 5.5);

        // Act
        final result = invalidRating.isValidRating;

        // Assert
        expect(result, false);
      });

      test('should return true for edge case ratings', () {
        // Arrange
        final minRating = testBookRating.copyWith(rating: 0.0);
        final maxRating = testBookRating.copyWith(rating: 5.0);

        // Assert
        expect(minRating.isValidRating, true);
        expect(maxRating.isValidRating, true);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated rating', () {
        // Act
        final updatedRating = testBookRating.copyWith(rating: 3.5);

        // Assert
        expect(updatedRating.bookId, testBookId);
        expect(updatedRating.userId, testUserId);
        expect(updatedRating.rating, 3.5);
        expect(updatedRating.createdAt, testCreatedAt);
      });

      test('should create a copy with all fields updated', () {
        // Arrange
        final newDate = DateTime(2024, 2, 20);

        // Act
        final updatedRating = testBookRating.copyWith(
          rating: 4.0,
          createdAt: newDate,
          updatedAt: newDate,
        );

        // Assert
        expect(updatedRating.rating, 4.0);
        expect(updatedRating.createdAt, newDate);
      });

      test('should preserve original fields when not specified', () {
        // Act
        final copiedRating = testBookRating.copyWith();

        // Assert
        expect(copiedRating.bookId, testBookId);
        expect(copiedRating.userId, testUserId);
        expect(copiedRating.rating, testRating);
        expect(copiedRating.createdAt, testCreatedAt);
      });
    });

    group('props', () {
      test('should have equal props for identical ratings', () {
        // Arrange
        final rating1 = BookRating(
          id: 'rating123',
          bookId: testBookId,
          userId: testUserId,
          rating: testRating,
          createdAt: testCreatedAt,
          updatedAt: testCreatedAt,
        );

        final rating2 = BookRating(
          id: 'rating123',
          bookId: testBookId,
          userId: testUserId,
          rating: testRating,
          createdAt: testCreatedAt,
          updatedAt: testCreatedAt,
        );

        // Assert
        expect(rating1, rating2);
        expect(rating1.props, rating2.props);
      });

      test('should have different props for different ratings', () {
        // Arrange
        final rating1 = testBookRating;
        final rating2 = testBookRating.copyWith(rating: 3.0);

        // Assert
        expect(rating1, isNot(rating2));
        expect(rating1.props, isNot(rating2.props));
      });

      test('should have different props for different users', () {
        // Arrange
        final rating1 = testBookRating;
        final rating2 = BookRating(
          id: 'rating456',
          bookId: testBookId,
          userId: 'differentUser',
          rating: testRating,
          createdAt: testCreatedAt,
          updatedAt: testCreatedAt,
        );

        // Assert
        expect(rating1, isNot(rating2));
      });
    });
  });
}
