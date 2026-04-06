import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';

/// Repository interface for book reviews and ratings
abstract class ReviewsRepository {
  /// Get reviews for a book
  Future<Either<Failure, List<Review>>> getReviews(String bookId);
  
  /// Submit a review for a book (create new)
  Future<Either<Failure, Review>> submitReview({
    required String bookId,
    required String reviewText,
    required double rating,
  });
  
  /// Update an existing review
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    required String reviewText,
    required double rating,
  });
  
  /// Delete a review (only by author)
  Future<Either<Failure, void>> deleteReview(String reviewId);

  /// Submit or update a rating without review
  Future<Either<Failure, BookRating>> submitRating({
    required String bookId,
    required double rating,
  });

  /// Get user's rating for a book (if exists)
  Future<Either<Failure, BookRating?>> getUserRating(String bookId);

  /// Vote on a review as helpful
  Future<Either<Failure, Review>> voteHelpful(String reviewId);

  /// Vote on a review as unhelpful
  Future<Either<Failure, Review>> voteUnhelpful(String reviewId);

  /// Remove vote from a review
  Future<Either<Failure, Review>> removeVote(String reviewId);

  /// Report a review as inappropriate
  Future<Either<Failure, void>> reportReview({
    required String reviewId,
    required String reason,
  });

  /// Check if user has already reviewed this book
  Future<Either<Failure, Review?>> getUserReview(String bookId);
}
