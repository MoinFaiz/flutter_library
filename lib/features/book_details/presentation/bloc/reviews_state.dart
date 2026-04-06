import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';

/// Base class for review states
abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

/// Loading state
class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

/// Reviews loaded successfully
class ReviewsLoaded extends ReviewsState {
  final List<Review> reviews;
  final Review? userReview;
  final BookRating? userRating;
  final bool isRefreshing;
  final String? successMessage;
  final String? errorMessage;

  const ReviewsLoaded({
    required this.reviews,
    this.userReview,
    this.userRating,
    this.isRefreshing = false,
    this.successMessage,
    this.errorMessage,
  });

  ReviewsLoaded copyWith({
    List<Review>? reviews,
    Review? userReview,
    BookRating? userRating,
    bool? isRefreshing,
    String? successMessage,
    String? errorMessage,
    bool clearUserReview = false,
    bool clearUserRating = false,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      userReview: clearUserReview ? null : (userReview ?? this.userReview),
      userRating: clearUserRating ? null : (userRating ?? this.userRating),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    userReview,
    userRating,
    isRefreshing,
    successMessage,
    errorMessage,
  ];
}

/// Error state
class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Submitting review state
class SubmittingReview extends ReviewsState {
  const SubmittingReview();
}

/// Review submitted successfully
class ReviewSubmitted extends ReviewsState {
  final Review review;

  const ReviewSubmitted(this.review);

  @override
  List<Object?> get props => [review];
}

/// Updating review state
class UpdatingReview extends ReviewsState {
  const UpdatingReview();
}

/// Review updated successfully
class ReviewUpdated extends ReviewsState {
  final Review review;

  const ReviewUpdated(this.review);

  @override
  List<Object?> get props => [review];
}

/// Deleting review state
class DeletingReview extends ReviewsState {
  const DeletingReview();
}

/// Review deleted successfully
class ReviewDeleted extends ReviewsState {
  const ReviewDeleted();
}

/// Submitting rating state
class SubmittingRating extends ReviewsState {
  const SubmittingRating();
}

/// Rating submitted successfully
class RatingSubmitted extends ReviewsState {
  final BookRating rating;

  const RatingSubmitted(this.rating);

  @override
  List<Object?> get props => [rating];
}

/// Voting state
class Voting extends ReviewsState {
  const Voting();
}

/// Vote successful
class VoteSuccess extends ReviewsState {
  final Review review;

  const VoteSuccess(this.review);

  @override
  List<Object?> get props => [review];
}

/// Reporting review state
class ReportingReview extends ReviewsState {
  const ReportingReview();
}

/// Review reported successfully
class ReviewReported extends ReviewsState {
  const ReviewReported();
}
