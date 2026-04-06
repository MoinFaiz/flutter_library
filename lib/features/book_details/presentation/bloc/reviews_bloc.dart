import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_reviews_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/update_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/delete_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/vote_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/report_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_review_usecase.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';

/// BLoC for managing review and rating operations
class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetReviewsUseCase getReviewsUseCase;
  final SubmitReviewUseCase submitReviewUseCase;
  final UpdateReviewUseCase updateReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final SubmitRatingUseCase submitRatingUseCase;
  final GetUserRatingUseCase getUserRatingUseCase;
  final VoteReviewUseCase voteReviewUseCase;
  final ReportReviewUseCase reportReviewUseCase;
  final GetUserReviewUseCase getUserReviewUseCase;

  ReviewsBloc({
    required this.getReviewsUseCase,
    required this.submitReviewUseCase,
    required this.updateReviewUseCase,
    required this.deleteReviewUseCase,
    required this.submitRatingUseCase,
    required this.getUserRatingUseCase,
    required this.voteReviewUseCase,
    required this.reportReviewUseCase,
    required this.getUserReviewUseCase,
  }) : super(const ReviewsInitial()) {
    on<LoadReviewsEvent>(_onLoadReviews);
    on<RefreshReviewsEvent>(_onRefreshReviews);
    on<SubmitReviewEvent>(_onSubmitReview);
    on<UpdateReviewEvent>(_onUpdateReview);
    on<DeleteReviewEvent>(_onDeleteReview);
    on<SubmitRatingEvent>(_onSubmitRating);
    on<LoadUserRatingEvent>(_onLoadUserRating);
    on<VoteHelpfulEvent>(_onVoteHelpful);
    on<VoteUnhelpfulEvent>(_onVoteUnhelpful);
    on<RemoveVoteEvent>(_onRemoveVote);
    on<ReportReviewEvent>(_onReportReview);
    on<LoadUserReviewEvent>(_onLoadUserReview);
    on<ClearErrorEvent>(_onClearError);
    on<ClearSuccessEvent>(_onClearSuccess);
  }

  Future<void> _onLoadReviews(
    LoadReviewsEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(const ReviewsLoading());

    final result = await getReviewsUseCase(event.bookId);

    result.fold(
      (failure) => emit(ReviewsError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews: reviews)),
    );
  }

  Future<void> _onRefreshReviews(
    RefreshReviewsEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is ReviewsLoaded) {
      final currentState = state as ReviewsLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      final result = await getReviewsUseCase(event.bookId);

      result.fold(
        (failure) => emit(currentState.copyWith(
          isRefreshing: false,
          errorMessage: failure.message,
        )),
        (reviews) => emit(currentState.copyWith(
          reviews: reviews,
          isRefreshing: false,
        )),
      );
    } else {
      add(LoadReviewsEvent(event.bookId));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(const SubmittingReview());

    final result = await submitReviewUseCase(
      bookId: event.bookId,
      reviewText: event.reviewText,
      rating: event.rating,
    );

    await result.fold(
      (failure) async => emit(ReviewsError(failure.message)),
      (review) async {
        // Reload reviews after successful submission
        final reviewsResult = await getReviewsUseCase(event.bookId);
        
        reviewsResult.fold(
          (failure) => emit(ReviewsError(failure.message)),
          (reviews) => emit(ReviewsLoaded(
            reviews: reviews,
            userReview: review,
            successMessage: 'Review submitted successfully!',
          )),
        );
      },
    );
  }

  Future<void> _onUpdateReview(
    UpdateReviewEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(const UpdatingReview());

    final result = await updateReviewUseCase(
      reviewId: event.reviewId,
      reviewText: event.reviewText,
      rating: event.rating,
    );

    await result.fold(
      (failure) async => emit(ReviewsError(failure.message)),
      (review) async {
        // Reload reviews after successful update
        final reviewsResult = await getReviewsUseCase(review.bookId);
        
        reviewsResult.fold(
          (failure) => emit(ReviewsError(failure.message)),
          (reviews) => emit(ReviewsLoaded(
            reviews: reviews,
            userReview: review,
            successMessage: 'Review updated successfully!',
          )),
        );
      },
    );
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is! ReviewsLoaded) return;

    final currentState = state as ReviewsLoaded;
    emit(const DeletingReview());

    final result = await deleteReviewUseCase(event.reviewId);

    await result.fold(
      (failure) async => emit(ReviewsError(failure.message)),
      (_) async {
        // Reload reviews after successful deletion
        if (currentState.userReview != null) {
          final reviewsResult = await getReviewsUseCase(currentState.userReview!.bookId);
          
          reviewsResult.fold(
            (failure) => emit(ReviewsError(failure.message)),
            (reviews) => emit(ReviewsLoaded(
              reviews: reviews,
              successMessage: 'Review deleted successfully!',
            )),
          );
        } else {
          emit(currentState.copyWith(
            successMessage: 'Review deleted successfully!',
            clearUserReview: true,
          ));
        }
      },
    );
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(const SubmittingRating());

    final result = await submitRatingUseCase(
      bookId: event.bookId,
      rating: event.rating,
    );

    result.fold(
      (failure) => emit(ReviewsError(failure.message)),
      (rating) {
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(
            userRating: rating,
            successMessage: 'Rating submitted successfully!',
          ));
        } else {
          emit(RatingSubmitted(rating));
        }
      },
    );
  }

  Future<void> _onLoadUserRating(
    LoadUserRatingEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    final result = await getUserRatingUseCase(event.bookId);

    result.fold(
      (failure) {
        // Don't emit error for missing rating, just continue
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(clearUserRating: true));
        }
      },
      (rating) {
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(userRating: rating));
        }
      },
    );
  }

  Future<void> _onVoteHelpful(
    VoteHelpfulEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is! ReviewsLoaded) return;

    final currentState = state as ReviewsLoaded;
    
    final result = await voteReviewUseCase.voteHelpful(event.reviewId);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedReview) {
        // Update the review in the list
        final updatedReviews = currentState.reviews.map((review) {
          return review.id == updatedReview.id ? updatedReview : review;
        }).toList();

        emit(currentState.copyWith(reviews: updatedReviews));
      },
    );
  }

  Future<void> _onVoteUnhelpful(
    VoteUnhelpfulEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is! ReviewsLoaded) return;

    final currentState = state as ReviewsLoaded;
    
    final result = await voteReviewUseCase.voteUnhelpful(event.reviewId);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedReview) {
        // Update the review in the list
        final updatedReviews = currentState.reviews.map((review) {
          return review.id == updatedReview.id ? updatedReview : review;
        }).toList();

        emit(currentState.copyWith(reviews: updatedReviews));
      },
    );
  }

  Future<void> _onRemoveVote(
    RemoveVoteEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state is! ReviewsLoaded) return;

    final currentState = state as ReviewsLoaded;
    
    final result = await voteReviewUseCase.removeVote(event.reviewId);

    result.fold(
      (failure) => emit(currentState.copyWith(errorMessage: failure.message)),
      (updatedReview) {
        // Update the review in the list
        final updatedReviews = currentState.reviews.map((review) {
          return review.id == updatedReview.id ? updatedReview : review;
        }).toList();

        emit(currentState.copyWith(reviews: updatedReviews));
      },
    );
  }

  Future<void> _onReportReview(
    ReportReviewEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(const ReportingReview());

    final result = await reportReviewUseCase(
      reviewId: event.reviewId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(ReviewsError(failure.message)),
      (_) {
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(
            successMessage: 'Review reported successfully. Thank you for your feedback!',
          ));
        } else {
          emit(const ReviewReported());
        }
      },
    );
  }

  Future<void> _onLoadUserReview(
    LoadUserReviewEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    final result = await getUserReviewUseCase(event.bookId);

    result.fold(
      (failure) {
        // Don't emit error for missing review, just continue
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(clearUserReview: true));
        }
      },
      (review) {
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          emit(currentState.copyWith(userReview: review));
        }
      },
    );
  }

  void _onClearError(
    ClearErrorEvent event,
    Emitter<ReviewsState> emit,
  ) {
    if (state is ReviewsLoaded) {
      final currentState = state as ReviewsLoaded;
      emit(currentState.copyWith(clearError: true));
    }
  }

  void _onClearSuccess(
    ClearSuccessEvent event,
    Emitter<ReviewsState> emit,
  ) {
    if (state is ReviewsLoaded) {
      final currentState = state as ReviewsLoaded;
      emit(currentState.copyWith(clearSuccess: true));
    }
  }
}
