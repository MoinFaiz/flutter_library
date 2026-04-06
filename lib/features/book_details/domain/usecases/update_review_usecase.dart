import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for updating an existing review
class UpdateReviewUseCase {
  final ReviewsRepository repository;

  UpdateReviewUseCase(this.repository);

  Future<Either<Failure, Review>> call({
    required String reviewId,
    required String reviewText,
    required double rating,
  }) async {
    // Validate inputs
    if (reviewText.trim().isEmpty) {
      return Left(ValidationFailure('Review text cannot be empty'));
    }

    if (reviewText.trim().length < 10) {
      return Left(ValidationFailure('Review must be at least 10 characters long'));
    }

    if (rating < 0.0 || rating > 5.0) {
      return Left(ValidationFailure('Rating must be between 0 and 5'));
    }

    return await repository.updateReview(
      reviewId: reviewId,
      reviewText: reviewText.trim(),
      rating: rating,
    );
  }
}
