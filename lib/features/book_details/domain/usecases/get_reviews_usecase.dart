import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';

/// Use case for getting reviews for a book
class GetReviewsUseCase {
  final ReviewsRepository repository;

  GetReviewsUseCase({required this.repository});

  Future<Either<Failure, List<Review>>> call(String bookId) async {
    return await repository.getReviews(bookId);
  }
}
