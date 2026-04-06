import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testReview = Review(
    id: 'review1',
    bookId: 'book1',
    userId: 'user1',
    userName: 'John Doe',
    rating: 4.5,
    reviewText: 'Great book!',
    createdAt: DateTime(2025, 10, 31),
    updatedAt: DateTime(2025, 10, 31),
  );

  final testRating = BookRating(
    id: 'rating1',
    bookId: 'book1',
    userId: 'user1',
    rating: 4.5,
    createdAt: DateTime(2025, 10, 31),
    updatedAt: DateTime(2025, 10, 31),
  );

  group('ReviewsState', () {
    group('ReviewsInitial', () {
      test('should have empty props', () {
        const state1 = ReviewsInitial();
        const state2 = ReviewsInitial();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewsLoading', () {
      test('should have empty props', () {
        const state1 = ReviewsLoading();
        const state2 = ReviewsLoading();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewsLoaded', () {
      test('should have correct props', () {
        final state1 = ReviewsLoaded(reviews: [testReview]);
        final state2 = ReviewsLoaded(reviews: [testReview]);
        final state3 = ReviewsLoaded(reviews: []);

        expect(state1.props, equals([[testReview], null, null, false, null, null]));
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('should support copyWith', () {
        final state = ReviewsLoaded(reviews: [testReview]);
        final updatedState = state.copyWith(
          userReview: testReview,
          userRating: testRating,
          successMessage: 'Success!',
        );

        expect(updatedState.reviews, equals([testReview]));
        expect(updatedState.userReview, equals(testReview));
        expect(updatedState.userRating, equals(testRating));
        expect(updatedState.successMessage, equals('Success!'));
      });

      test('should clear user review when clearUserReview is true', () {
        final state = ReviewsLoaded(
          reviews: [testReview],
          userReview: testReview,
        );
        final updatedState = state.copyWith(clearUserReview: true);

        expect(updatedState.userReview, isNull);
      });

      test('should clear user rating when clearUserRating is true', () {
        final state = ReviewsLoaded(
          reviews: [testReview],
          userRating: testRating,
        );
        final updatedState = state.copyWith(clearUserRating: true);

        expect(updatedState.userRating, isNull);
      });

      test('should clear success message when clearSuccess is true', () {
        final state = ReviewsLoaded(
          reviews: [testReview],
          successMessage: 'Success!',
        );
        final updatedState = state.copyWith(clearSuccess: true);

        expect(updatedState.successMessage, isNull);
      });

      test('should clear error message when clearError is true', () {
        final state = ReviewsLoaded(
          reviews: [testReview],
          errorMessage: 'Error!',
        );
        final updatedState = state.copyWith(clearError: true);

        expect(updatedState.errorMessage, isNull);
      });
    });

    group('ReviewsError', () {
      test('should have correct props', () {
        const state1 = ReviewsError('Error message');
        const state2 = ReviewsError('Error message');
        const state3 = ReviewsError('Different error');

        expect(state1.props, equals(['Error message']));
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('SubmittingReview', () {
      test('should have empty props', () {
        const state1 = SubmittingReview();
        const state2 = SubmittingReview();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewSubmitted', () {
      test('should have correct props', () {
        final state1 = ReviewSubmitted(testReview);
        final state2 = ReviewSubmitted(testReview);

        expect(state1.props, equals([testReview]));
        expect(state1, equals(state2));
      });
    });

    group('UpdatingReview', () {
      test('should have empty props', () {
        const state1 = UpdatingReview();
        const state2 = UpdatingReview();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewUpdated', () {
      test('should have correct props', () {
        final state1 = ReviewUpdated(testReview);
        final state2 = ReviewUpdated(testReview);

        expect(state1.props, equals([testReview]));
        expect(state1, equals(state2));
      });
    });

    group('DeletingReview', () {
      test('should have empty props', () {
        const state1 = DeletingReview();
        const state2 = DeletingReview();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewDeleted', () {
      test('should have empty props', () {
        const state1 = ReviewDeleted();
        const state2 = ReviewDeleted();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('SubmittingRating', () {
      test('should have empty props', () {
        const state1 = SubmittingRating();
        const state2 = SubmittingRating();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('RatingSubmitted', () {
      test('should have correct props', () {
        final state1 = RatingSubmitted(testRating);
        final state2 = RatingSubmitted(testRating);

        expect(state1.props, equals([testRating]));
        expect(state1, equals(state2));
      });
    });

    group('Voting', () {
      test('should have empty props', () {
        const state1 = Voting();
        const state2 = Voting();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('VoteSuccess', () {
      test('should have correct props', () {
        final state1 = VoteSuccess(testReview);
        final state2 = VoteSuccess(testReview);

        expect(state1.props, equals([testReview]));
        expect(state1, equals(state2));
      });
    });

    group('ReportingReview', () {
      test('should have empty props', () {
        const state1 = ReportingReview();
        const state2 = ReportingReview();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });

    group('ReviewReported', () {
      test('should have empty props', () {
        const state1 = ReviewReported();
        const state2 = ReviewReported();

        expect(state1.props, equals([]));
        expect(state1, equals(state2));
      });
    });
  });
}
