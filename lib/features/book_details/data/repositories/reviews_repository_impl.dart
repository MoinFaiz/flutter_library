import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_local_datasource.dart';

/// Implementation of ReviewsRepository
class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;
  final ReviewsLocalDataSource localDataSource;

  ReviewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Review>>> getReviews(String bookId) async {
    try {
      // Try to get from cache first
      final cachedReviews = await localDataSource.getCachedReviews(bookId);
      if (cachedReviews.isNotEmpty) {
        return Right(cachedReviews.cast<Review>());
      }
      
      // If not in cache, fetch from remote
      final reviews = await remoteDataSource.getReviews(bookId);
      
      // Cache the reviews
      await localDataSource.cacheReviews(bookId, reviews);
      
      return Right(reviews);
    } on DioException catch (e) {
      // Handle specific HTTP status codes
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        switch (statusCode) {
          case 404:
            return const Left(ServerFailure(message: 'Reviews not found'));
          case 401:
            return const Left(ServerFailure(message: 'Unauthorized access'));
          case 500:
            return const Left(ServerFailure(message: 'Server error'));
        }
      }
      // For other DioExceptions (network issues, timeouts, etc.)
      String errorMessage = e.message ?? _formatErrorType(e.type);
      return Left(NetworkFailure(message: 'Failed to get reviews: $errorMessage'));
    } catch (e) {
      return Left(UnknownFailure('Failed to get reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> submitReview({
    required String bookId,
    required String reviewText,
    required double rating,
  }) async {
    try {
      final review = await remoteDataSource.submitReview(
        bookId: bookId,
        reviewText: reviewText,
        rating: rating,
      );
      
      // Invalidate cache for this book
      await localDataSource.clearCacheForBook(bookId);
      
      return Right(review);
    } on DioException catch (e) {
      return Left(NetworkFailure(message: 'Failed to submit review: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('Failed to submit review: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    required String reviewText,
    required double rating,
  }) async {
    try {
      final review = await remoteDataSource.updateReview(
        reviewId: reviewId,
        reviewText: reviewText,
        rating: rating,
      );
      
      // Invalidate cache for this book
      await localDataSource.clearCacheForBook(review.bookId);
      
      return Right(review);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure(message: 'Reviews not found'));
      }
      // Format error type nicely (e.g., connectionTimeout -> Connection timeout)
      String errorMessage = e.message ?? _formatErrorType(e.type);
      return Left(NetworkFailure(message: 'Failed to update review: $errorMessage'));
    } catch (e) {
      return Left(UnknownFailure('Failed to update review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      
      // Note: We can't easily invalidate cache without knowing bookId
      // In a real app, the delete endpoint would return bookId or we'd track it
      await localDataSource.clearCache();
      
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(ServerFailure(message: 'Unauthorized access'));
      }
      // Format error type nicely (e.g., sendTimeout -> Send timeout)
      String errorMessage = e.message ?? _formatErrorType(e.type);
      return Left(NetworkFailure(message: 'Failed to delete review: $errorMessage'));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete review: $e'));
    }
  }

  @override
  Future<Either<Failure, BookRating>> submitRating({
    required String bookId,
    required double rating,
  }) async {
    try {
      final bookRating = await remoteDataSource.submitRating(
        bookId: bookId,
        rating: rating,
      );
      
      return Right(bookRating);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to submit rating: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to submit rating: $e'));
    }
  }

  @override
  Future<Either<Failure, BookRating?>> getUserRating(String bookId) async {
    try {
      final rating = await remoteDataSource.getUserRating(bookId);
      return Right(rating);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to get user rating: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user rating: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> voteHelpful(String reviewId) async {
    try {
      final review = await remoteDataSource.voteHelpful(reviewId);
      
      // Update cache
      await localDataSource.clearCacheForBook(review.bookId);
      
      return Right(review);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to vote helpful: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to vote helpful: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> voteUnhelpful(String reviewId) async {
    try {
      final review = await remoteDataSource.voteUnhelpful(reviewId);
      
      // Update cache
      await localDataSource.clearCacheForBook(review.bookId);
      
      return Right(review);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to vote unhelpful: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to vote unhelpful: $e'));
    }
  }

  @override
  Future<Either<Failure, Review>> removeVote(String reviewId) async {
    try {
      final review = await remoteDataSource.removeVote(reviewId);
      
      // Update cache
      await localDataSource.clearCacheForBook(review.bookId);
      
      return Right(review);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to remove vote: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove vote: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      await remoteDataSource.reportReview(
        reviewId: reviewId,
        reason: reason,
      );
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to report review: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to report review: $e'));
    }
  }

  @override
  Future<Either<Failure, Review?>> getUserReview(String bookId) async {
    try {
      final review = await remoteDataSource.getUserReview(bookId);
      return Right(review);
    } on DioException catch (e) {
      return Left(ServerFailure(message: 'Failed to get user review: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user review: $e'));
    }
  }

  /// Format DioExceptionType to human-readable string
  /// e.g., connectionTimeout -> Connection timeout, sendTimeout -> Send timeout
  String _formatErrorType(DioExceptionType type) {
    final typeStr = type.toString().split('.').last;
    // Add space before capital letters
    final withSpaces = typeStr.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)!.toLowerCase()}',
    ).trim();
    // Capitalize only the first letter
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}
