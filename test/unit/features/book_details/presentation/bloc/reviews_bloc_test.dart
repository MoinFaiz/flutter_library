import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/usecases/delete_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_reviews_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/report_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/update_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/vote_review_usecase.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockGetReviewsUseCase extends Mock implements GetReviewsUseCase {}
class MockSubmitReviewUseCase extends Mock implements SubmitReviewUseCase {}
class MockUpdateReviewUseCase extends Mock implements UpdateReviewUseCase {}
class MockDeleteReviewUseCase extends Mock implements DeleteReviewUseCase {}
class MockSubmitRatingUseCase extends Mock implements SubmitRatingUseCase {}
class MockGetUserRatingUseCase extends Mock implements GetUserRatingUseCase {}
class MockVoteReviewUseCase extends Mock implements VoteReviewUseCase {}
class MockReportReviewUseCase extends Mock implements ReportReviewUseCase {}
class MockGetUserReviewUseCase extends Mock implements GetUserReviewUseCase {}

void main() {
  late ReviewsBloc reviewsBloc;
  late MockGetReviewsUseCase mockGetReviewsUseCase;
  late MockSubmitReviewUseCase mockSubmitReviewUseCase;
  late MockUpdateReviewUseCase mockUpdateReviewUseCase;
  late MockDeleteReviewUseCase mockDeleteReviewUseCase;
  late MockSubmitRatingUseCase mockSubmitRatingUseCase;
  late MockGetUserRatingUseCase mockGetUserRatingUseCase;
  late MockVoteReviewUseCase mockVoteReviewUseCase;
  late MockReportReviewUseCase mockReportReviewUseCase;
  late MockGetUserReviewUseCase mockGetUserReviewUseCase;

  // Test data
  final tBookId = 'book1';
  final tReviewId = 'review1';
  final now = DateTime.now();
  
  final tReview = Review(
    id: 'review1',
    bookId: 'book1',
    userId: 'user1',
    userName: 'John Doe',
    reviewText: 'Great book!',
    rating: 4.5,
    helpfulCount: 10,
    unhelpfulCount: 2,
    createdAt: now,
    updatedAt: now,
  );

  final tUpdatedReview = Review(
    id: 'review1',
    bookId: 'book1',
    userId: 'user1',
    userName: 'John Doe',
    reviewText: 'Updated review',
    rating: 5.0,
    helpfulCount: 15,
    unhelpfulCount: 1,
    isEdited: true,
    createdAt: now,
    updatedAt: now,
  );

  final tReviews = [tReview];
  
  final tRating = BookRating(
    id: 'rating1',
    bookId: 'book1',
    userId: 'user1',
    rating: 4.0,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockGetReviewsUseCase = MockGetReviewsUseCase();
    mockSubmitReviewUseCase = MockSubmitReviewUseCase();
    mockUpdateReviewUseCase = MockUpdateReviewUseCase();
    mockDeleteReviewUseCase = MockDeleteReviewUseCase();
    mockSubmitRatingUseCase = MockSubmitRatingUseCase();
    mockGetUserRatingUseCase = MockGetUserRatingUseCase();
    mockVoteReviewUseCase = MockVoteReviewUseCase();
    mockReportReviewUseCase = MockReportReviewUseCase();
    mockGetUserReviewUseCase = MockGetUserReviewUseCase();

    reviewsBloc = ReviewsBloc(
      getReviewsUseCase: mockGetReviewsUseCase,
      submitReviewUseCase: mockSubmitReviewUseCase,
      updateReviewUseCase: mockUpdateReviewUseCase,
      deleteReviewUseCase: mockDeleteReviewUseCase,
      submitRatingUseCase: mockSubmitRatingUseCase,
      getUserRatingUseCase: mockGetUserRatingUseCase,
      voteReviewUseCase: mockVoteReviewUseCase,
      reportReviewUseCase: mockReportReviewUseCase,
      getUserReviewUseCase: mockGetUserReviewUseCase,
    );
  });

  tearDown(() {
    reviewsBloc.close();
  });

  test('initial state should be ReviewsInitial', () {
    expect(reviewsBloc.state, equals(const ReviewsInitial()));
  });

  group('LoadReviewsEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [ReviewsLoading, ReviewsLoaded] when reviews are loaded successfully',
      build: () {
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => Right(tReviews));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(LoadReviewsEvent(tBookId)),
      expect: () => [
        const ReviewsLoading(),
        ReviewsLoaded(reviews: tReviews),
      ],
      verify: (_) {
        verify(() => mockGetReviewsUseCase(tBookId)).called(1);
      },
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits [ReviewsLoading, ReviewsError] when loading fails',
      build: () {
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(LoadReviewsEvent(tBookId)),
      expect: () => [
        const ReviewsLoading(),
        const ReviewsError('Server error'),
      ],
    );
  });

  group('RefreshReviewsEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits updated ReviewsLoaded when refresh succeeds from loaded state',
      build: () {
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => Right(tReviews));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: []),
      act: (bloc) => bloc.add(RefreshReviewsEvent(tBookId)),
      expect: () => [
        const ReviewsLoaded(reviews: [], isRefreshing: true),
        ReviewsLoaded(reviews: tReviews, isRefreshing: false),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error message when refresh fails from loaded state',
      build: () {
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Refresh failed')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: []),
      act: (bloc) => bloc.add(RefreshReviewsEvent(tBookId)),
      expect: () => [
        const ReviewsLoaded(reviews: [], isRefreshing: true),
        const ReviewsLoaded(reviews: [], isRefreshing: false, errorMessage: 'Refresh failed'),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'triggers LoadReviewsEvent when not in ReviewsLoaded state',
      build: () {
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => Right(tReviews));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(RefreshReviewsEvent(tBookId)),
      expect: () => [
        const ReviewsLoading(),
        ReviewsLoaded(reviews: tReviews),
      ],
    );
  });

  group('SubmitReviewEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [SubmittingReview, ReviewsLoaded] when review is submitted successfully',
      build: () {
        when(() => mockSubmitReviewUseCase(
          bookId: tBookId,
          reviewText: 'Great book!',
          rating: 4.5,
        )).thenAnswer((_) async => Right(tReview));
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => Right(tReviews));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitReviewEvent(
        bookId: 'book1',
        reviewText: 'Great book!',
        rating: 4.5,
      )),
      expect: () => [
        const SubmittingReview(),
        ReviewsLoaded(
          reviews: tReviews,
          userReview: tReview,
          successMessage: 'Review submitted successfully!',
        ),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits [SubmittingReview, ReviewsError] when submission fails',
      build: () {
        when(() => mockSubmitReviewUseCase(
          bookId: tBookId,
          reviewText: 'Great book!',
          rating: 4.5,
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to submit')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitReviewEvent(
        bookId: 'book1',
        reviewText: 'Great book!',
        rating: 4.5,
      )),
      expect: () => [
        const SubmittingReview(),
        const ReviewsError('Failed to submit'),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits ReviewsError when reload after submission fails',
      build: () {
        when(() => mockSubmitReviewUseCase(
          bookId: tBookId,
          reviewText: 'Great book!',
          rating: 4.5,
        )).thenAnswer((_) async => Right(tReview));
        when(() => mockGetReviewsUseCase(tBookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Reload failed')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitReviewEvent(
        bookId: 'book1',
        reviewText: 'Great book!',
        rating: 4.5,
      )),
      expect: () => [
        const SubmittingReview(),
        const ReviewsError('Reload failed'),
      ],
    );
  });

  group('UpdateReviewEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [UpdatingReview, ReviewsLoaded] when review is updated successfully',
      build: () {
        when(() => mockUpdateReviewUseCase(
          reviewId: tReviewId,
          reviewText: 'Updated review',
          rating: 5.0,
        )).thenAnswer((_) async => Right(tUpdatedReview));
        when(() => mockGetReviewsUseCase('book1'))
            .thenAnswer((_) async => Right([tUpdatedReview]));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const UpdateReviewEvent(
        reviewId: 'review1',
        reviewText: 'Updated review',
        rating: 5.0,
      )),
      expect: () => [
        const UpdatingReview(),
        ReviewsLoaded(
          reviews: [tUpdatedReview],
          userReview: tUpdatedReview,
          successMessage: 'Review updated successfully!',
        ),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits [UpdatingReview, ReviewsError] when update fails',
      build: () {
        when(() => mockUpdateReviewUseCase(
          reviewId: tReviewId,
          reviewText: 'Updated review',
          rating: 5.0,
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Update failed')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const UpdateReviewEvent(
        reviewId: 'review1',
        reviewText: 'Updated review',
        rating: 5.0,
      )),
      expect: () => [
        const UpdatingReview(),
        const ReviewsError('Update failed'),
      ],
    );
  });

  group('DeleteReviewEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [DeletingReview, ReviewsLoaded] when review is deleted successfully',
      build: () {
        when(() => mockDeleteReviewUseCase(tReviewId))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetReviewsUseCase('book1'))
            .thenAnswer((_) async => const Right([]));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews, userReview: tReview),
      act: (bloc) => bloc.add(DeleteReviewEvent(tReviewId)),
      expect: () => [
        const DeletingReview(),
        const ReviewsLoaded(
          reviews: [],
          successMessage: 'Review deleted successfully!',
        ),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(DeleteReviewEvent(tReviewId)),
      expect: () => [],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error when deletion fails',
      build: () {
        when(() => mockDeleteReviewUseCase(tReviewId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Delete failed')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews, userReview: tReview),
      act: (bloc) => bloc.add(DeleteReviewEvent(tReviewId)),
      expect: () => [
        const DeletingReview(),
        const ReviewsError('Delete failed'),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits success with cleared user review when userReview is null',
      build: () {
        when(() => mockDeleteReviewUseCase(tReviewId))
            .thenAnswer((_) async => const Right(null));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(DeleteReviewEvent(tReviewId)),
      expect: () => [
        const DeletingReview(),
        ReviewsLoaded(
          reviews: tReviews,
          successMessage: 'Review deleted successfully!',
        ),
      ],
    );
  });

  group('SubmitRatingEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [SubmittingRating, RatingSubmitted] when not in ReviewsLoaded state',
      build: () {
        when(() => mockSubmitRatingUseCase(
          bookId: tBookId,
          rating: 4.0,
        )).thenAnswer((_) async => Right(tRating));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitRatingEvent(
        bookId: 'book1',
        rating: 4.0,
      )),
      expect: () => [
        const SubmittingRating(),
        RatingSubmitted(tRating),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits [SubmittingRating, RatingSubmitted] when not in ReviewsLoaded state after submission starts',
      build: () {
        when(() => mockSubmitRatingUseCase(
          bookId: tBookId,
          rating: 4.0,
        )).thenAnswer((_) async => Right(tRating));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(const SubmitRatingEvent(
        bookId: 'book1',
        rating: 4.0,
      )),
      expect: () => [
        const SubmittingRating(),
        RatingSubmitted(tRating),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error when rating submission fails',
      build: () {
        when(() => mockSubmitRatingUseCase(
          bookId: tBookId,
          rating: 4.0,
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Rating failed')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const SubmitRatingEvent(
        bookId: 'book1',
        rating: 4.0,
      )),
      expect: () => [
        const SubmittingRating(),
        const ReviewsError('Rating failed'),
      ],
    );
  });

  group('LoadUserRatingEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'updates ReviewsLoaded with user rating when successful',
      build: () {
        when(() => mockGetUserRatingUseCase(tBookId))
            .thenAnswer((_) async => Right(tRating));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(LoadUserRatingEvent(tBookId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews, userRating: tRating),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'clears user rating when loading fails and in ReviewsLoaded state',
      build: () {
        when(() => mockGetUserRatingUseCase(tBookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Not found')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews, userRating: tRating),
      act: (bloc) => bloc.add(LoadUserRatingEvent(tBookId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () {
        when(() => mockGetUserRatingUseCase(tBookId))
            .thenAnswer((_) async => Right(tRating));
        return reviewsBloc;
      },
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(LoadUserRatingEvent(tBookId)),
      expect: () => [],
    );
  });

  group('VoteHelpfulEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'updates review list with voted review when successful',
      build: () {
        when(() => mockVoteReviewUseCase.voteHelpful(tReviewId))
            .thenAnswer((_) async => Right(tUpdatedReview));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(VoteHelpfulEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: [tUpdatedReview]),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error message when vote fails',
      build: () {
        when(() => mockVoteReviewUseCase.voteHelpful(tReviewId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Vote failed')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(VoteHelpfulEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews, errorMessage: 'Vote failed'),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(VoteHelpfulEvent(tReviewId)),
      expect: () => [],
    );
  });

  group('VoteUnhelpfulEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'updates review list when vote unhelpful succeeds',
      build: () {
        when(() => mockVoteReviewUseCase.voteUnhelpful(tReviewId))
            .thenAnswer((_) async => Right(tUpdatedReview));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(VoteUnhelpfulEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: [tUpdatedReview]),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error message when vote unhelpful fails',
      build: () {
        when(() => mockVoteReviewUseCase.voteUnhelpful(tReviewId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Vote failed')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(VoteUnhelpfulEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews, errorMessage: 'Vote failed'),
      ],
    );
  });

  group('RemoveVoteEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'updates review list when remove vote succeeds',
      build: () {
        when(() => mockVoteReviewUseCase.removeVote(tReviewId))
            .thenAnswer((_) async => Right(tUpdatedReview));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(RemoveVoteEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: [tUpdatedReview]),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error message when remove vote fails',
      build: () {
        when(() => mockVoteReviewUseCase.removeVote(tReviewId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Remove vote failed')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(RemoveVoteEvent(tReviewId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews, errorMessage: 'Remove vote failed'),
      ],
    );
  });

  group('ReportReviewEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'emits [ReportingReview, ReviewReported] when not in ReviewsLoaded state',
      build: () {
        when(() => mockReportReviewUseCase(
          reviewId: tReviewId,
          reason: 'Spam',
        )).thenAnswer((_) async => const Right(null));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const ReportReviewEvent(
        reviewId: 'review1',
        reason: 'Spam',
      )),
      expect: () => [
        const ReportingReview(),
        const ReviewReported(),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits [ReportingReview, ReviewReported] when not in ReviewsLoaded state after reporting',
      build: () {
        when(() => mockReportReviewUseCase(
          reviewId: tReviewId,
          reason: 'Spam',
        )).thenAnswer((_) async => const Right(null));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(const ReportReviewEvent(
        reviewId: 'review1',
        reason: 'Spam',
      )),
      expect: () => [
        const ReportingReview(),
        const ReviewReported(),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'emits error when reporting fails',
      build: () {
        when(() => mockReportReviewUseCase(
          reviewId: tReviewId,
          reason: 'Spam',
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Report failed')));
        return reviewsBloc;
      },
      act: (bloc) => bloc.add(const ReportReviewEvent(
        reviewId: 'review1',
        reason: 'Spam',
      )),
      expect: () => [
        const ReportingReview(),
        const ReviewsError('Report failed'),
      ],
    );
  });

  group('LoadUserReviewEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'updates ReviewsLoaded with user review when successful',
      build: () {
        when(() => mockGetUserReviewUseCase(tBookId))
            .thenAnswer((_) async => Right(tReview));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews),
      act: (bloc) => bloc.add(LoadUserReviewEvent(tBookId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews, userReview: tReview),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'clears user review when loading fails',
      build: () {
        when(() => mockGetUserReviewUseCase(tBookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Not found')));
        return reviewsBloc;
      },
      seed: () => ReviewsLoaded(reviews: tReviews, userReview: tReview),
      act: (bloc) => bloc.add(LoadUserReviewEvent(tBookId)),
      expect: () => [
        ReviewsLoaded(reviews: tReviews),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () {
        when(() => mockGetUserReviewUseCase(tBookId))
            .thenAnswer((_) async => Right(tReview));
        return reviewsBloc;
      },
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(LoadUserReviewEvent(tBookId)),
      expect: () => [],
    );
  });

  group('ClearErrorEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'clears error message when in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsLoaded(
        reviews: [],
        errorMessage: 'Some error',
      ),
      act: (bloc) => bloc.add(const ClearErrorEvent()),
      expect: () => [
        const ReviewsLoaded(reviews: []),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(const ClearErrorEvent()),
      expect: () => [],
    );
  });

  group('ClearSuccessEvent', () {
    blocTest<ReviewsBloc, ReviewsState>(
      'clears success message when in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsLoaded(
        reviews: [],
        successMessage: 'Success!',
      ),
      act: (bloc) => bloc.add(const ClearSuccessEvent()),
      expect: () => [
        const ReviewsLoaded(reviews: []),
      ],
    );

    blocTest<ReviewsBloc, ReviewsState>(
      'does nothing when not in ReviewsLoaded state',
      build: () => reviewsBloc,
      seed: () => const ReviewsInitial(),
      act: (bloc) => bloc.add(const ClearSuccessEvent()),
      expect: () => [],
    );
  });
}
