import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for deleting a review
class DeleteReviewUseCase {
  final ReviewsRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(String reviewId) async {
    if (reviewId.isEmpty) {
      return Left(ValidationFailure('Review ID cannot be empty'));
    }

    return await repository.deleteReview(reviewId);
  }
}
