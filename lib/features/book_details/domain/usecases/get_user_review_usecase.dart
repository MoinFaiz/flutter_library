import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for getting user's review for a specific book
class GetUserReviewUseCase {
  final ReviewsRepository repository;

  GetUserReviewUseCase(this.repository);

  Future<Either<Failure, Review?>> call(String bookId) async {
    if (bookId.isEmpty) {
      return Left(ValidationFailure('Book ID cannot be empty'));
    }

    return await repository.getUserReview(bookId);
  }
}
