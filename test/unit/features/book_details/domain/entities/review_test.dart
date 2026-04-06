import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review Entity', () {
    const String testUserId = 'user123';
    const String testUserName = 'John Doe';
    const String testReviewText = 'Great book!';
    const double testRating = 4.5;
    final DateTime testCreatedAt = DateTime(2024, 1, 15);

    late Review testReview;

    setUp(() {
      testReview = Review(
        id: 'review123',
        bookId: 'book123',
        userId: testUserId,
        userName: testUserName,
        reviewText: testReviewText,
        rating: testRating,
        createdAt: testCreatedAt,
        updatedAt: testCreatedAt,
      );
    });

    group('isAuthor', () {
      test('should return true when current user matches review user', () {
        // Act
        final result = testReview.isAuthor(testUserId);

        // Assert
        expect(result, true);
      });

      test('should return false when current user does not match review user', () {
        // Act
        final result = testReview.isAuthor('differentUser');

        // Assert
        expect(result, false);
      });

      test('should return false when current user is null', () {
        // Act
        final result = testReview.isAuthor(null);

        // Assert
        expect(result, false);
      });
    });

    group('netHelpfulness', () {
      test('should return difference between helpful and unhelpful counts', () {
        // Arrange
        final reviewWithVotes = testReview.copyWith(
          helpfulCount: 10,
          unhelpfulCount: 3,
        );

        // Act
        final result = reviewWithVotes.netHelpfulness;

        // Assert
        expect(result, 7); // 10 - 3 = 7
      });

      test('should return zero when counts are equal', () {
        // Arrange
        final reviewWithVotes = testReview.copyWith(
          helpfulCount: 5,
          unhelpfulCount: 5,
        );

        // Act
        final result = reviewWithVotes.netHelpfulness;

        // Assert
        expect(result, 0);
      });

      test('should return negative when unhelpful count is greater', () {
        // Arrange
        final reviewWithVotes = testReview.copyWith(
          helpfulCount: 2,
          unhelpfulCount: 8,
        );

        // Act
        final result = reviewWithVotes.netHelpfulness;

        // Assert
        expect(result, -6);
      });
    });

    group('timeAgo', () {
      test('should return "Just now" for recent reviews', () {
        // Arrange
        final recentReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );

        // Act
        final result = recentReview.timeAgo;

        // Assert
        expect(result, 'Just now');
      });

      test('should return minutes ago for reviews less than 1 hour old', () {
        // Arrange
        final recentReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act
        final result = recentReview.timeAgo;

        // Assert
        expect(result, '30 minutes ago');
      });

      test('should return hours ago for reviews less than 1 day old', () {
        // Arrange
        final recentReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );

        // Act
        final result = recentReview.timeAgo;

        // Assert
        expect(result, '5 hours ago');
      });

      test('should return days ago for reviews less than 30 days old', () {
        // Arrange
        final recentReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        );

        // Act
        final result = recentReview.timeAgo;

        // Assert
        expect(result, '7 days ago');
      });

      test('should return months ago for reviews less than 12 months old', () {
        // Arrange
        final recentReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        );

        // Act
        final result = recentReview.timeAgo;

        // Assert
        expect(result, '2 months ago');
      });

      test('should return years ago for old reviews', () {
        // Arrange
        final oldReview = testReview.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 730)), // ~2 years
        );

        // Act
        final result = oldReview.timeAgo;

        // Assert
        expect(result, '2 years ago');
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Act
        final updatedReview = testReview.copyWith(
          reviewText: 'Updated review text',
          rating: 5.0,
          isEdited: true,
        );

        // Assert
        expect(updatedReview.id, testReview.id);
        expect(updatedReview.reviewText, 'Updated review text');
        expect(updatedReview.rating, 5.0);
        expect(updatedReview.isEdited, true);
        expect(updatedReview.userId, testReview.userId);
      });

      test('should clear current user vote when clearCurrentUserVote is true', () {
        // Arrange
        final reviewWithVote = testReview.copyWith(currentUserVote: 'helpful');

        // Act
        final clearedReview = reviewWithVote.copyWith(
          clearCurrentUserVote: true,
        );

        // Assert
        expect(clearedReview.currentUserVote, null);
      });

      test('should preserve current user vote when clearCurrentUserVote is false', () {
        // Arrange
        final reviewWithVote = testReview.copyWith(currentUserVote: 'helpful');

        // Act
        final preservedReview = reviewWithVote.copyWith(
          rating: 4.0,
        );

        // Assert
        expect(preservedReview.currentUserVote, 'helpful');
      });
    });

    group('props', () {
      test('should have equal props for identical reviews', () {
        // Arrange
        final review1 = Review(
          id: 'review123',
          bookId: 'book123',
          userId: testUserId,
          userName: testUserName,
          reviewText: testReviewText,
          rating: testRating,
          createdAt: testCreatedAt,
          updatedAt: testCreatedAt,
        );

        final review2 = Review(
          id: 'review123',
          bookId: 'book123',
          userId: testUserId,
          userName: testUserName,
          reviewText: testReviewText,
          rating: testRating,
          createdAt: testCreatedAt,
          updatedAt: testCreatedAt,
        );

        // Assert
        expect(review1, review2);
        expect(review1.props, review2.props);
      });

      test('should have different props for different reviews', () {
        // Arrange
        final review1 = testReview;
        final review2 = testReview.copyWith(rating: 3.0);

        // Assert
        expect(review1, isNot(review2));
        expect(review1.props, isNot(review2.props));
      });
    });
  });
}
