import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for voting on a review
class VoteReviewUseCase {
  final ReviewsRepository repository;

  VoteReviewUseCase(this.repository);

  Future<Either<Failure, Review>> voteHelpful(String reviewId) async {
    if (reviewId.isEmpty) {
      return Left(ValidationFailure('Review ID cannot be empty'));
    }

    return await repository.voteHelpful(reviewId);
  }

  Future<Either<Failure, Review>> voteUnhelpful(String reviewId) async {
    if (reviewId.isEmpty) {
      return Left(ValidationFailure('Review ID cannot be empty'));
    }

    return await repository.voteUnhelpful(reviewId);
  }

  Future<Either<Failure, Review>> removeVote(String reviewId) async {
    if (reviewId.isEmpty) {
      return Left(ValidationFailure('Review ID cannot be empty'));
    }

    return await repository.removeVote(reviewId);
  }
}
