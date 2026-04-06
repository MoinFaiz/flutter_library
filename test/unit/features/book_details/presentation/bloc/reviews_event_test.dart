import 'package:flutter_library/features/book_details/presentation/bloc/reviews_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewsEvent', () {
    group('LoadReviewsEvent', () {
      test('should have correct props', () {
        const event1 = LoadReviewsEvent('book1');
        const event2 = LoadReviewsEvent('book1');
        const event3 = LoadReviewsEvent('book2');

        expect(event1.props, equals(['book1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('RefreshReviewsEvent', () {
      test('should have correct props', () {
        const event1 = RefreshReviewsEvent('book1');
        const event2 = RefreshReviewsEvent('book1');
        const event3 = RefreshReviewsEvent('book2');

        expect(event1.props, equals(['book1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('SubmitReviewEvent', () {
      test('should have correct props', () {
        const event1 = SubmitReviewEvent(
          bookId: 'book1',
          reviewText: 'Great!',
          rating: 4.5,
        );
        const event2 = SubmitReviewEvent(
          bookId: 'book1',
          reviewText: 'Great!',
          rating: 4.5,
        );
        const event3 = SubmitReviewEvent(
          bookId: 'book2',
          reviewText: 'Great!',
          rating: 4.5,
        );

        expect(event1.props, equals(['book1', 'Great!', 4.5]));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('UpdateReviewEvent', () {
      test('should have correct props', () {
        const event1 = UpdateReviewEvent(
          reviewId: 'review1',
          reviewText: 'Updated',
          rating: 5.0,
        );
        const event2 = UpdateReviewEvent(
          reviewId: 'review1',
          reviewText: 'Updated',
          rating: 5.0,
        );
        const event3 = UpdateReviewEvent(
          reviewId: 'review2',
          reviewText: 'Updated',
          rating: 5.0,
        );

        expect(event1.props, equals(['review1', 'Updated', 5.0]));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('DeleteReviewEvent', () {
      test('should have correct props', () {
        const event1 = DeleteReviewEvent('review1');
        const event2 = DeleteReviewEvent('review1');
        const event3 = DeleteReviewEvent('review2');

        expect(event1.props, equals(['review1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('SubmitRatingEvent', () {
      test('should have correct props', () {
        const event1 = SubmitRatingEvent(bookId: 'book1', rating: 4.5);
        const event2 = SubmitRatingEvent(bookId: 'book1', rating: 4.5);
        const event3 = SubmitRatingEvent(bookId: 'book1', rating: 5.0);

        expect(event1.props, equals(['book1', 4.5]));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('LoadUserRatingEvent', () {
      test('should have correct props', () {
        const event1 = LoadUserRatingEvent('book1');
        const event2 = LoadUserRatingEvent('book1');
        const event3 = LoadUserRatingEvent('book2');

        expect(event1.props, equals(['book1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('VoteHelpfulEvent', () {
      test('should have correct props', () {
        const event1 = VoteHelpfulEvent('review1');
        const event2 = VoteHelpfulEvent('review1');
        const event3 = VoteHelpfulEvent('review2');

        expect(event1.props, equals(['review1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('VoteUnhelpfulEvent', () {
      test('should have correct props', () {
        const event1 = VoteUnhelpfulEvent('review1');
        const event2 = VoteUnhelpfulEvent('review1');
        const event3 = VoteUnhelpfulEvent('review2');

        expect(event1.props, equals(['review1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('RemoveVoteEvent', () {
      test('should have correct props', () {
        const event1 = RemoveVoteEvent('review1');
        const event2 = RemoveVoteEvent('review1');
        const event3 = RemoveVoteEvent('review2');

        expect(event1.props, equals(['review1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('ReportReviewEvent', () {
      test('should have correct props', () {
        const event1 = ReportReviewEvent(reviewId: 'review1', reason: 'Spam');
        const event2 = ReportReviewEvent(reviewId: 'review1', reason: 'Spam');
        const event3 = ReportReviewEvent(reviewId: 'review1', reason: 'Offensive');

        expect(event1.props, equals(['review1', 'Spam']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('LoadUserReviewEvent', () {
      test('should have correct props', () {
        const event1 = LoadUserReviewEvent('book1');
        const event2 = LoadUserReviewEvent('book1');
        const event3 = LoadUserReviewEvent('book2');

        expect(event1.props, equals(['book1']));
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });

    group('ClearErrorEvent', () {
      test('should have empty props', () {
        const event1 = ClearErrorEvent();
        const event2 = ClearErrorEvent();

        expect(event1.props, equals([]));
        expect(event1, equals(event2));
      });
    });

    group('ClearSuccessEvent', () {
      test('should have empty props', () {
        const event1 = ClearSuccessEvent();
        const event2 = ClearSuccessEvent();

        expect(event1.props, equals([]));
        expect(event1, equals(event2));
      });
    });
  });
}
