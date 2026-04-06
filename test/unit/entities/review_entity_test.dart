import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';

void main() {
  group('Review Entity', () {
    const tId = 'review_123';
    const tBookId = 'book_456';
    const tUserId = 'user_789';
    const tUserName = 'John Doe';
    const tReviewText = 'This is an excellent book with great character development.';
    const tRating = 4.5;
    final tCreatedAt = DateTime(2023, 5, 15, 10, 30);
    final tUpdatedAt = DateTime(2023, 5, 20, 14, 45);

    final tReview = Review(
      id: tId,
      bookId: tBookId,
      userId: tUserId,
      userName: tUserName,
      reviewText: tReviewText,
      rating: tRating,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    group('constructor', () {
      test('should create Review with all required fields', () {
        // act & assert
        expect(tReview.id, equals(tId));
        expect(tReview.bookId, equals(tBookId));
        expect(tReview.userId, equals(tUserId));
        expect(tReview.userName, equals(tUserName));
        expect(tReview.reviewText, equals(tReviewText));
        expect(tReview.rating, equals(tRating));
        expect(tReview.createdAt, equals(tCreatedAt));
        expect(tReview.updatedAt, equals(tUpdatedAt));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final review1 = tReview;
        final review2 = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review1, equals(review2));
        expect(review1.hashCode, equals(review2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final review1 = tReview;
        final review2 = Review(
          id: 'different_id',
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review1, isNot(equals(review2)));
        expect(review1.hashCode, isNot(equals(review2.hashCode)));
      });

      test('should not be equal when rating differs', () {
        // arrange
        final review1 = tReview;
        final review2 = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: 3.0,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review1, isNot(equals(review2)));
      });

      test('should not be equal when reviewText differs', () {
        // arrange
        final review1 = tReview;
        final review2 = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: 'Different review text',
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review1, isNot(equals(review2)));
      });
    });

    group('props', () {
      test('should return correct list of properties', () {
        // act
        final props = tReview.props;

        // assert
        expect(props, equals([
          tId,
          tBookId,
          tUserId,
          tUserName,
          null, // userAvatarUrl
          tReviewText,
          tRating,
          0, // helpfulCount
          0, // unhelpfulCount
          false, // isReported
          false, // isEdited
          tCreatedAt,
          tUpdatedAt,
          null, // currentUserVote
        ]));
      });
    });

    group('rating validation', () {
      test('should handle minimum rating (0.0)', () {
        // arrange
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: 0.0,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.rating, equals(0.0));
      });

      test('should handle maximum rating (5.0)', () {
        // arrange
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: 5.0,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.rating, equals(5.0));
      });

      test('should handle decimal ratings', () {
        final ratings = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];

        for (final rating in ratings) {
          final review = Review(
            id: tId,
            bookId: tBookId,
            userId: tUserId,
            userName: tUserName,
            reviewText: tReviewText,
            rating: rating,
            createdAt: tCreatedAt,
            updatedAt: tUpdatedAt,
          );

          expect(review.rating, equals(rating));
        }
      });

      test('should handle negative ratings (edge case)', () {
        // arrange
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: -1.0,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.rating, equals(-1.0));
      });

      test('should handle ratings above 5.0 (edge case)', () {
        // arrange
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: 10.0,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.rating, equals(10.0));
      });
    });

    group('edge cases', () {
      test('should handle empty review text', () {
        // arrange
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: '',
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.reviewText, isEmpty);
      });

      test('should handle very long review text', () {
        // arrange
        final longReviewText = 'A' * 10000; // 10k characters
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: longReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.reviewText, equals(longReviewText));
        expect(review.reviewText.length, equals(10000));
      });

      test('should handle special characters in review text', () {
        // arrange
        const specialReviewText = 'Review with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*() 😀🎉';
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: specialReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.reviewText, equals(specialReviewText));
      });

      test('should handle special characters in user name', () {
        // arrange
        const specialUserName = 'João José María';
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: specialUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.userName, equals(specialUserName));
      });

      test('should handle same createdAt and updatedAt dates', () {
        // arrange
        final sameDate = DateTime(2023, 5, 15, 10, 30);
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: sameDate,
          updatedAt: sameDate,
        );

        // assert
        expect(review.createdAt, equals(review.updatedAt));
      });

      test('should handle updatedAt before createdAt (edge case)', () {
        // arrange
        final createdAt = DateTime(2023, 5, 15, 10, 30);
        final updatedAt = DateTime(2023, 5, 10, 10, 30); // 5 days earlier
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // assert
        expect(review.createdAt, equals(createdAt));
        expect(review.updatedAt, equals(updatedAt));
        expect(review.updatedAt.isBefore(review.createdAt), isTrue);
      });

      test('should handle empty string IDs', () {
        // arrange
        final review = Review(
          id: '',
          bookId: '',
          userId: '',
          userName: tUserName,
          reviewText: tReviewText,
          rating: tRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.id, isEmpty);
        expect(review.bookId, isEmpty);
        expect(review.userId, isEmpty);
      });

      test('should handle precision in double rating', () {
        // arrange
        const preciseRating = 4.123456789;
        final review = Review(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          userName: tUserName,
          reviewText: tReviewText,
          rating: preciseRating,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(review.rating, equals(preciseRating));
      });
    });
  });
}
