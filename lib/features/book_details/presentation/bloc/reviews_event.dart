import 'package:equatable/equatable.dart';

/// Base class for review events
abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load reviews for a book
class LoadReviewsEvent extends ReviewsEvent {
  final String bookId;

  const LoadReviewsEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to refresh reviews
class RefreshReviewsEvent extends ReviewsEvent {
  final String bookId;

  const RefreshReviewsEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to submit a new review
class SubmitReviewEvent extends ReviewsEvent {
  final String bookId;
  final String reviewText;
  final double rating;

  const SubmitReviewEvent({
    required this.bookId,
    required this.reviewText,
    required this.rating,
  });

  @override
  List<Object?> get props => [bookId, reviewText, rating];
}

/// Event to update an existing review
class UpdateReviewEvent extends ReviewsEvent {
  final String reviewId;
  final String reviewText;
  final double rating;

  const UpdateReviewEvent({
    required this.reviewId,
    required this.reviewText,
    required this.rating,
  });

  @override
  List<Object?> get props => [reviewId, reviewText, rating];
}

/// Event to delete a review
class DeleteReviewEvent extends ReviewsEvent {
  final String reviewId;

  const DeleteReviewEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to submit or update rating without review
class SubmitRatingEvent extends ReviewsEvent {
  final String bookId;
  final double rating;

  const SubmitRatingEvent({
    required this.bookId,
    required this.rating,
  });

  @override
  List<Object?> get props => [bookId, rating];
}

/// Event to load user's rating
class LoadUserRatingEvent extends ReviewsEvent {
  final String bookId;

  const LoadUserRatingEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to vote helpful on a review
class VoteHelpfulEvent extends ReviewsEvent {
  final String reviewId;

  const VoteHelpfulEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to vote unhelpful on a review
class VoteUnhelpfulEvent extends ReviewsEvent {
  final String reviewId;

  const VoteUnhelpfulEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to remove vote from a review
class RemoveVoteEvent extends ReviewsEvent {
  final String reviewId;

  const RemoveVoteEvent(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to report a review
class ReportReviewEvent extends ReviewsEvent {
  final String reviewId;
  final String reason;

  const ReportReviewEvent({
    required this.reviewId,
    required this.reason,
  });

  @override
  List<Object?> get props => [reviewId, reason];
}

/// Event to load user's review for a book
class LoadUserReviewEvent extends ReviewsEvent {
  final String bookId;

  const LoadUserReviewEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to clear error messages
class ClearErrorEvent extends ReviewsEvent {
  const ClearErrorEvent();
}

/// Event to clear success messages
class ClearSuccessEvent extends ReviewsEvent {
  const ClearSuccessEvent();
}
