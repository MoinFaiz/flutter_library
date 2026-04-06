import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for reporting inappropriate reviews
class ReportReviewUseCase {
  final ReviewsRepository repository;

  ReportReviewUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String reviewId,
    required String reason,
  }) async {
    if (reviewId.isEmpty) {
      return Left(ValidationFailure('Review ID cannot be empty'));
    }

    if (reason.trim().isEmpty) {
      return Left(ValidationFailure('Please provide a reason for reporting'));
    }

    if (reason.trim().length < 10) {
      return Left(ValidationFailure('Reason must be at least 10 characters long'));
    }

    return await repository.reportReview(
      reviewId: reviewId,
      reason: reason.trim(),
    );
  }
}
