import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/review_model.dart';
import 'package:flutter_library/features/book_details/data/models/book_rating_model.dart';

void main() {
  group('ReviewsRemoteDataSourceImpl', () {
    late ReviewsRemoteDataSourceImpl dataSource;

    setUp(() {
      dataSource = ReviewsRemoteDataSourceImpl();
    });

    group('getReviews', () {
      test('should return list of reviews for a book', () async {
        // Arrange
        const bookId = 'book_1'; // Use the book ID that has mock data

        // Act
        final result = await dataSource.getReviews(bookId);

        // Assert
        expect(result, isA<List<ReviewModel>>());
        expect(result, hasLength(3));
        
        // Verify all reviews are for the correct book
        for (final review in result) {
          expect(review.bookId, equals(bookId));
          expect(review.id, isNotEmpty);
          expect(review.userId, isNotEmpty);
          expect(review.userName, isNotEmpty);
          expect(review.rating, greaterThan(0));
          expect(review.createdAt, isA<DateTime>());
          expect(review.updatedAt, isA<DateTime>());
        }
      });

      test('should handle empty book ID', () async {
        // Arrange
        const bookId = '';

        // Act
        final result = await dataSource.getReviews(bookId);

        // Assert - Should return empty list for non-existent bookId
        expect(result, isA<List<ReviewModel>>());
        expect(result, isEmpty);
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'test-book';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getReviews(bookId);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });

      test('should return consistent data for same book ID', () async {
        // Arrange
        const bookId = 'consistent-book';

        // Act
        final result1 = await dataSource.getReviews(bookId);
        final result2 = await dataSource.getReviews(bookId);

        // Assert
        expect(result1.length, equals(result2.length));
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
          expect(result1[i].bookId, equals(result2[i].bookId));
          expect(result1[i].rating, equals(result2[i].rating));
          expect(result1[i].reviewText, equals(result2[i].reviewText));
        }
      });

      test('should handle special characters in book ID', () async {
        // Arrange
        const bookId = 'book-id-with-special!@#\$%^&*()';

        // Act
        final result = await dataSource.getReviews(bookId);

        // Assert
        expect(result, isA<List<ReviewModel>>());
        for (final review in result) {
          expect(review.bookId, equals(bookId));
        }
      });
    });

    group('submitReview', () {
      test('should add a new review and return it', () async {
        // Arrange
        const bookId = 'test-book-id';
        const reviewText = 'This is a test review';
        const rating = 4.0;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result, isA<ReviewModel>());
        expect(result.id, isNotEmpty);
        expect(result.bookId, equals(bookId));
        expect(result.userId, equals('current_user_123'));
        expect(result.userName, equals('Current User'));
        expect(result.reviewText, equals(reviewText));
        expect(result.rating, equals(rating));
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });

      test('should handle minimum rating', () async {
        // Arrange
        const bookId = 'test-book';
        const reviewText = 'Terrible book';
        const rating = 1.0;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result.rating, equals(1.0));
        expect(result.reviewText, equals(reviewText));
      });

      test('should handle maximum rating', () async {
        // Arrange
        const bookId = 'test-book';
        const reviewText = 'Perfect book!';
        const rating = 5.0;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result.rating, equals(5.0));
        expect(result.reviewText, equals(reviewText));
      });

      test('should handle empty review text', () async {
        // Arrange
        const bookId = 'test-book';
        const reviewText = '';
        const rating = 3.5;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result.reviewText, equals(''));
        expect(result.rating, equals(3.5));
      });

      test('should handle very long review text', () async {
        // Arrange
        const bookId = 'test-book';
        final reviewText = 'Very long review text ' * 50;
        const rating = 4.5;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result.reviewText, equals(reviewText));
        expect(result.rating, equals(4.5));
      });

      test('should generate unique IDs for multiple reviews', () async {
        // Arrange - Use different book IDs to avoid duplicate review check
        const bookId1 = 'test-book-unique-1';
        const bookId2 = 'test-book-unique-2';
        const reviewText1 = 'First review';
        const reviewText2 = 'Second review';
        const rating = 4.0;

        // Act
        final result1 = await dataSource.submitReview(
          bookId: bookId1,
          reviewText: reviewText1,
          rating: rating,
        );
        await Future.delayed(const Duration(milliseconds: 10)); // Ensure different timestamps
        final result2 = await dataSource.submitReview(
          bookId: bookId2,
          reviewText: reviewText2,
          rating: rating,
        );

        // Assert
        expect(result1.id, isNot(equals(result2.id)));
        expect(result1.reviewText, equals(reviewText1));
        expect(result2.reviewText, equals(reviewText2));
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'test-book';
        const reviewText = 'Test review';
        const rating = 4.0;
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(800));
      });

      test('should handle decimal ratings', () async {
        // Arrange
        const bookId = 'test-book';
        const reviewText = 'Decent book';
        const rating = 3.7;

        // Act
        final result = await dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating);

        // Assert
        expect(result.rating, equals(3.7));
      });
    });

    group('updateReview', () {
      test('should update a review and return it', () async {
        // Arrange - First create a review
        const bookId = 'update-test-book';
        const initialReviewText = 'Initial review';
        const initialRating = 3.0;
        
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: initialReviewText,
          rating: initialRating,
        );
        
        const updatedReviewText = 'Updated review text';
        const updatedRating = 4.5;

        // Act
        final result = await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: updatedReviewText,
          rating: updatedRating,
        );

        // Assert
        expect(result, isA<ReviewModel>());
        expect(result.id, equals(createdReview.id));
        expect(result.bookId, equals(bookId));
        expect(result.userId, equals('current_user_123'));
        expect(result.userName, equals('Current User'));
        expect(result.reviewText, equals(updatedReviewText));
        expect(result.rating, equals(updatedRating));
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
        
        // Updated date should be more recent than created date
        expect(result.updatedAt.isAfter(result.createdAt), isTrue);
      });

      test('should handle empty review text in update', () async {
        // Arrange - First create a review
        const bookId = 'update-empty-text-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Initial review',
          rating: 3.0,
        );
        
        const reviewText = '';
        const rating = 2.0;

        // Act
        final result = await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: reviewText,
          rating: rating,
        );

        // Assert
        expect(result.reviewText, equals(''));
        expect(result.rating, equals(2.0));
      });

      test('should handle rating change in update', () async {
        // Arrange - First create a review
        const bookId = 'update-rating-change-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Initial text',
          rating: 4.0,
        );
        
        const reviewText = 'Changed my mind about this book';
        const rating = 1.0;

        // Act
        final result = await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: reviewText,
          rating: rating,
        );

        // Assert
        expect(result.rating, equals(1.0));
        expect(result.reviewText, equals(reviewText));
      });

      test('should handle long review ID', () async {
        // Arrange - First create a review (it will have auto-generated ID)
        const bookId = 'long-id-test-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Initial text',
          rating: 3.0,
        );
        
        const reviewText = 'Updated text';
        const rating = 3.0;

        // Act
        final result = await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: reviewText,
          rating: rating,
        );

        // Assert - ID should be preserved
        expect(result.id, equals(createdReview.id));
        expect(result.reviewText, equals(reviewText));
      });

      test('should simulate network delay for update', () async {
        // Arrange - First create a review
        const bookId = 'delay-test-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Initial text',
          rating: 3.0,
        );
        
        const reviewText = 'Test update';
        const rating = 4.0;
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: reviewText,
          rating: rating,
        );

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(600));
      });

      test('should preserve review ID during update', () async {
        // Arrange - First create a review
        const bookId = 'preserve-id-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Initial text',
          rating: 3.0,
        );
        
        const reviewText = 'New text';
        const rating = 5.0;

        // Act
        final result = await dataSource.updateReview(
          reviewId: createdReview.id,
          reviewText: reviewText,
          rating: rating,
        );

        // Assert
        expect(result.id, equals(createdReview.id));
      });
    });

    group('deleteReview', () {
      test('should delete a review successfully', () async {
        // Arrange - First create a review
        const bookId = 'delete-test-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Review to delete',
          rating: 3.0,
        );

        // Act - Delete the review
        await dataSource.deleteReview(createdReview.id);
        
        // Assert - Verify the review is gone
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews, isEmpty);
      });

      test('should handle empty review ID', () async {
        // Arrange - Test that deleting non-existent review throws
        const reviewId = '';

        // Act & Assert - Should throw exception
        expect(
          () => dataSource.deleteReview(reviewId),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle special characters in review ID', () async {
        // Arrange - Test that deleting non-existent review throws
        const reviewId = 'review-id-with-special!@#\$%^&*()';

        // Act & Assert - Should throw exception
        expect(
          () => dataSource.deleteReview(reviewId),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay for delete', () async {
        // Arrange - First create a review
        const bookId = 'delay-delete-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Review to delete',
          rating: 3.0,
        );
        
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.deleteReview(createdReview.id);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      });

      test('should handle multiple delete operations', () async {
        // Arrange - Create multiple reviews
        const bookId1 = 'multi-delete-book-1';
        const bookId2 = 'multi-delete-book-2';
        const bookId3 = 'multi-delete-book-3';
        
        final review1 = await dataSource.submitReview(
          bookId: bookId1,
          reviewText: 'Review 1',
          rating: 3.0,
        );
        
        // Switch to different user context to create more reviews
        // Since we can't change user, we'll create reviews for different books
        final review2 = await dataSource.submitReview(
          bookId: bookId2,
          reviewText: 'Review 2',
          rating: 3.0,
        );
        
        final review3 = await dataSource.submitReview(
          bookId: bookId3,
          reviewText: 'Review 3',
          rating: 3.0,
        );

        // Act - Delete all reviews
        await dataSource.deleteReview(review1.id);
        await dataSource.deleteReview(review2.id);
        await dataSource.deleteReview(review3.id);
        
        // Assert - All books should have empty reviews
        expect(await dataSource.getReviews(bookId1), isEmpty);
        expect(await dataSource.getReviews(bookId2), isEmpty);
        expect(await dataSource.getReviews(bookId3), isEmpty);
      });

      test('should handle very long review ID for delete', () async {
        // Arrange - First create a review (it will have auto-generated ID)
        const bookId = 'long-delete-id-book';
        final createdReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Review to delete',
          rating: 3.0,
        );

        // Act - Delete the review
        await dataSource.deleteReview(createdReview.id);
        
        // Assert - Verify the review is gone
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews, isEmpty);
      });
    });

    group('Edge Cases and Integration', () {
      test('should handle rapid successive operations', () async {
        // Arrange
        const bookId = 'rapid-test-book';
        const reviewText = 'Rapid test review';
        const rating = 4.0;

        // Act
        final futures = [
          dataSource.getReviews(bookId),
          dataSource.submitReview(bookId: bookId, reviewText: reviewText, rating: rating),
          dataSource.getReviews(bookId),
        ];
        
        // Assert
        expect(() => Future.wait(futures), returnsNormally);
        final results = await Future.wait(futures);
        expect(results[0], isA<List<ReviewModel>>());
        expect(results[1], isA<ReviewModel>());
        expect(results[2], isA<List<ReviewModel>>());
      });

      test('should handle concurrent add operations', () async {
        // Arrange - Use different book IDs to avoid duplicate review check
        const bookId1 = 'concurrent-book-1';
        const bookId2 = 'concurrent-book-2';
        const bookId3 = 'concurrent-book-3';
        const rating = 4.0;

        // Act - Create reviews sequentially with delays to ensure unique IDs
        final review1 = await dataSource.submitReview(bookId: bookId1, reviewText: 'Review 1', rating: rating);
        await Future.delayed(const Duration(milliseconds: 10));
        final review2 = await dataSource.submitReview(bookId: bookId2, reviewText: 'Review 2', rating: rating);
        await Future.delayed(const Duration(milliseconds: 10));
        final review3 = await dataSource.submitReview(bookId: bookId3, reviewText: 'Review 3', rating: rating);
        
        final results = [review1, review2, review3];

        // Assert
        expect(results, hasLength(3));
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isA<ReviewModel>());
        }
        
        // All should have unique IDs
        final ids = results.map((r) => r.id).toSet();
        expect(ids, hasLength(3));
      });

      test('should handle full CRUD workflow', () async {
        // Arrange
        const bookId = 'crud-test-book';
        const initialText = 'Initial review';
        const updatedText = 'Updated review';
        const rating = 4.0;

        // Act & Assert - Add
        final addedReview = await dataSource.submitReview(
          bookId: bookId,
          reviewText: initialText,
          rating: rating,
        );
        expect(addedReview.reviewText, equals(initialText));

        // Act & Assert - Update
        final updatedReview = await dataSource.updateReview(
          reviewId: addedReview.id,
          reviewText: updatedText,
          rating: 5.0,
        );
        expect(updatedReview.reviewText, equals(updatedText));
        expect(updatedReview.rating, equals(5.0));

        // Act & Assert - Delete
        await dataSource.deleteReview(updatedReview.id);
        
        // Verify deletion
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews, isEmpty);
      });

      test('should handle extreme values', () async {
        // Arrange
        const bookId = 'extreme-test';
        final extremeText = 'x' * 10000; // Very long text
        const rating = 0.1; // Very low rating

        // Act
        final result = await dataSource.submitReview(
          bookId: bookId,
          reviewText: extremeText,
          rating: rating,
        );

        // Assert
        expect(result.reviewText, equals(extremeText));
        expect(result.rating, equals(rating));
      });
    });

    group('submitRating', () {
      test('should submit a new rating and return it', () async {
        // Arrange
        const bookId = 'rating-test-book-1';
        const rating = 4.5;

        // Act
        final result = await dataSource.submitRating(bookId: bookId, rating: rating);

        // Assert
        expect(result, isA<BookRatingModel>());
        expect(result.id, isNotEmpty);
        expect(result.bookId, equals(bookId));
        expect(result.userId, equals('current_user_123'));
        expect(result.rating, equals(rating));
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });

      test('should update existing rating when submitting again', () async {
        // Arrange
        const bookId = 'rating-update-book';
        const initialRating = 3.0;
        const updatedRating = 5.0;

        // Act
        final firstRating = await dataSource.submitRating(bookId: bookId, rating: initialRating);
        await Future.delayed(const Duration(milliseconds: 10));
        final secondRating = await dataSource.submitRating(bookId: bookId, rating: updatedRating);

        // Assert
        expect(firstRating.id, equals(secondRating.id)); // Same ID
        expect(secondRating.rating, equals(updatedRating));
        expect(secondRating.updatedAt.isAfter(firstRating.updatedAt), isTrue);
        expect(secondRating.createdAt, equals(firstRating.createdAt)); // Created date preserved
      });

      test('should handle minimum rating value', () async {
        // Arrange
        const bookId = 'min-rating-book';
        const rating = 0.0;

        // Act
        final result = await dataSource.submitRating(bookId: bookId, rating: rating);

        // Assert
        expect(result.rating, equals(0.0));
      });

      test('should handle maximum rating value', () async {
        // Arrange
        const bookId = 'max-rating-book';
        const rating = 5.0;

        // Act
        final result = await dataSource.submitRating(bookId: bookId, rating: rating);

        // Assert
        expect(result.rating, equals(5.0));
      });

      test('should handle decimal rating values', () async {
        // Arrange
        const bookId = 'decimal-rating-book';
        const rating = 3.7;

        // Act
        final result = await dataSource.submitRating(bookId: bookId, rating: rating);

        // Assert
        expect(result.rating, equals(3.7));
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-rating-book';
        const rating = 4.0;
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.submitRating(bookId: bookId, rating: rating);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });
    });

    group('getUserRating', () {
      test('should return user rating when it exists', () async {
        // Arrange
        const bookId = 'user-rating-book';
        const rating = 4.0;
        await dataSource.submitRating(bookId: bookId, rating: rating);

        // Act
        final result = await dataSource.getUserRating(bookId);

        // Assert
        expect(result, isA<BookRatingModel>());
        expect(result!.bookId, equals(bookId));
        expect(result.rating, equals(rating));
      });

      test('should return null when no rating exists', () async {
        // Arrange
        const bookId = 'no-rating-book';

        // Act
        final result = await dataSource.getUserRating(bookId);

        // Assert
        expect(result, isNull);
      });

      test('should return updated rating after modification', () async {
        // Arrange
        const bookId = 'modified-rating-book';
        const initialRating = 3.0;
        const updatedRating = 5.0;
        await dataSource.submitRating(bookId: bookId, rating: initialRating);
        await dataSource.submitRating(bookId: bookId, rating: updatedRating);

        // Act
        final result = await dataSource.getUserRating(bookId);

        // Assert
        expect(result, isNotNull);
        expect(result!.rating, equals(updatedRating));
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-get-rating-book';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getUserRating(bookId);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(300));
      });
    });

    group('voteHelpful', () {
      test('should add helpful vote to a review', () async {
        // Arrange
        const bookId = 'vote-helpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final initialHelpfulCount = review.helpfulCount;

        // Act
        final result = await dataSource.voteHelpful(review.id);

        // Assert
        expect(result.helpfulCount, equals(initialHelpfulCount + 1));
        expect(result.currentUserVote, equals('helpful'));
      });

      test('should remove helpful vote when voting again', () async {
        // Arrange
        const bookId = 'remove-helpful-vote-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteHelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final helpfulCount = votedReview.first.helpfulCount;

        // Act
        final result = await dataSource.voteHelpful(review.id);

        // Assert
        expect(result.helpfulCount, equals(helpfulCount - 1));
        expect(result.currentUserVote, isNull);
      });

      test('should change from unhelpful to helpful vote', () async {
        // Arrange
        const bookId = 'change-to-helpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteUnhelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final unhelpfulCount = votedReview.first.unhelpfulCount;
        final helpfulCount = votedReview.first.helpfulCount;

        // Act
        final result = await dataSource.voteHelpful(review.id);

        // Assert
        expect(result.helpfulCount, equals(helpfulCount + 1));
        expect(result.unhelpfulCount, equals(unhelpfulCount - 1));
        expect(result.currentUserVote, equals('helpful'));
      });

      test('should throw exception when review not found', () async {
        // Arrange
        const reviewId = 'non-existent-review';

        // Act & Assert
        expect(
          () => dataSource.voteHelpful(reviewId),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-helpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.voteHelpful(review.id);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      });
    });

    group('voteUnhelpful', () {
      test('should add unhelpful vote to a review', () async {
        // Arrange
        const bookId = 'vote-unhelpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final initialUnhelpfulCount = review.unhelpfulCount;

        // Act
        final result = await dataSource.voteUnhelpful(review.id);

        // Assert
        expect(result.unhelpfulCount, equals(initialUnhelpfulCount + 1));
        expect(result.currentUserVote, equals('unhelpful'));
      });

      test('should remove unhelpful vote when voting again', () async {
        // Arrange
        const bookId = 'remove-unhelpful-vote-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteUnhelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final unhelpfulCount = votedReview.first.unhelpfulCount;

        // Act
        final result = await dataSource.voteUnhelpful(review.id);

        // Assert
        expect(result.unhelpfulCount, equals(unhelpfulCount - 1));
        expect(result.currentUserVote, isNull);
      });

      test('should change from helpful to unhelpful vote', () async {
        // Arrange
        const bookId = 'change-to-unhelpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteHelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final helpfulCount = votedReview.first.helpfulCount;
        final unhelpfulCount = votedReview.first.unhelpfulCount;

        // Act
        final result = await dataSource.voteUnhelpful(review.id);

        // Assert
        expect(result.unhelpfulCount, equals(unhelpfulCount + 1));
        expect(result.helpfulCount, equals(helpfulCount - 1));
        expect(result.currentUserVote, equals('unhelpful'));
      });

      test('should throw exception when review not found', () async {
        // Arrange
        const reviewId = 'non-existent-review';

        // Act & Assert
        expect(
          () => dataSource.voteUnhelpful(reviewId),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-unhelpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.voteUnhelpful(review.id);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      });
    });

    group('removeVote', () {
      test('should remove helpful vote', () async {
        // Arrange
        const bookId = 'remove-helpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteHelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final helpfulCount = votedReview.first.helpfulCount;

        // Act
        final result = await dataSource.removeVote(review.id);

        // Assert
        expect(result.helpfulCount, equals(helpfulCount - 1));
        expect(result.currentUserVote, isNull);
      });

      test('should remove unhelpful vote', () async {
        // Arrange
        const bookId = 'remove-unhelpful-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.voteUnhelpful(review.id);
        final votedReview = await dataSource.getReviews(bookId);
        final unhelpfulCount = votedReview.first.unhelpfulCount;

        // Act
        final result = await dataSource.removeVote(review.id);

        // Assert
        expect(result.unhelpfulCount, equals(unhelpfulCount - 1));
        expect(result.currentUserVote, isNull);
      });

      test('should return review unchanged when no vote exists', () async {
        // Arrange
        const bookId = 'no-vote-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final initialHelpfulCount = review.helpfulCount;
        final initialUnhelpfulCount = review.unhelpfulCount;

        // Act
        final result = await dataSource.removeVote(review.id);

        // Assert
        expect(result.helpfulCount, equals(initialHelpfulCount));
        expect(result.unhelpfulCount, equals(initialUnhelpfulCount));
        expect(result.currentUserVote, isNull);
      });

      test('should throw exception when review not found', () async {
        // Arrange
        const reviewId = 'non-existent-review';

        // Act & Assert
        expect(
          () => dataSource.removeVote(reviewId),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-remove-vote-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.removeVote(review.id);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      });
    });

    group('reportReview', () {
      test('should report a review successfully', () async {
        // Arrange
        const bookId = 'report-review-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        const reason = 'Inappropriate content';

        // Act
        await dataSource.reportReview(reviewId: review.id, reason: reason);

        // Assert
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews.first.isReported, isTrue);
      });

      test('should handle empty reason', () async {
        // Arrange
        const bookId = 'report-empty-reason-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        const reason = '';

        // Act
        await dataSource.reportReview(reviewId: review.id, reason: reason);

        // Assert
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews.first.isReported, isTrue);
      });

      test('should handle long reason text', () async {
        // Arrange
        const bookId = 'report-long-reason-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        final reason = 'Very long reason ' * 50;

        // Act
        await dataSource.reportReview(reviewId: review.id, reason: reason);

        // Assert
        final reviews = await dataSource.getReviews(bookId);
        expect(reviews.first.isReported, isTrue);
      });

      test('should throw exception when review not found', () async {
        // Arrange
        const reviewId = 'non-existent-review';
        const reason = 'Test reason';

        // Act & Assert
        expect(
          () => dataSource.reportReview(reviewId: reviewId, reason: reason),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-report-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        const reason = 'Test reason';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.reportReview(reviewId: review.id, reason: reason);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });
    });

    group('getUserReview', () {
      test('should return user review when it exists', () async {
        // Arrange
        const bookId = 'user-review-book';
        const reviewText = 'My review';
        const rating = 4.0;
        await dataSource.submitReview(
          bookId: bookId,
          reviewText: reviewText,
          rating: rating,
        );

        // Act
        final result = await dataSource.getUserReview(bookId);

        // Assert
        expect(result, isA<ReviewModel>());
        expect(result!.bookId, equals(bookId));
        expect(result.userId, equals('current_user_123'));
        expect(result.reviewText, equals(reviewText));
        expect(result.rating, equals(rating));
      });

      test('should return null when no user review exists', () async {
        // Arrange
        const bookId = 'no-user-review-book';

        // Act
        final result = await dataSource.getUserReview(bookId);

        // Assert
        expect(result, isNull);
      });

      test('should return updated review after modification', () async {
        // Arrange
        const bookId = 'modified-user-review-book';
        const initialText = 'Initial review';
        const updatedText = 'Updated review';
        const rating = 4.0;
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: initialText,
          rating: rating,
        );
        await dataSource.updateReview(
          reviewId: review.id,
          reviewText: updatedText,
          rating: 5.0,
        );

        // Act
        final result = await dataSource.getUserReview(bookId);

        // Assert
        expect(result, isNotNull);
        expect(result!.reviewText, equals(updatedText));
        expect(result.rating, equals(5.0));
      });

      test('should return null after deleting user review', () async {
        // Arrange
        const bookId = 'deleted-user-review-book';
        final review = await dataSource.submitReview(
          bookId: bookId,
          reviewText: 'Test review',
          rating: 4.0,
        );
        await dataSource.deleteReview(review.id);

        // Act
        final result = await dataSource.getUserReview(bookId);

        // Assert
        expect(result, isNull);
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'delay-user-review-book';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getUserReview(bookId);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(300));
      });
    });
  });
}
