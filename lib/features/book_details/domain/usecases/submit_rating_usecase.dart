import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for submitting or updating a book rating without a review
class SubmitRatingUseCase {
  final ReviewsRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<Either<Failure, BookRating>> call({
    required String bookId,
    required double rating,
  }) async {
    if (rating < 0.0 || rating > 5.0) {
      return Left(ValidationFailure('Rating must be between 0 and 5'));
    }

    return await repository.submitRating(
      bookId: bookId,
      rating: rating,
    );
  }
}
