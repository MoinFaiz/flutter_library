import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for getting user's rating for a specific book
class GetUserRatingUseCase {
  final ReviewsRepository repository;

  GetUserRatingUseCase(this.repository);

  Future<Either<Failure, BookRating?>> call(String bookId) async {
    if (bookId.isEmpty) {
      return Left(ValidationFailure('Book ID cannot be empty'));
    }

    return await repository.getUserRating(bookId);
  }
}
