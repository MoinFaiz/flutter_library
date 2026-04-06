import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/book_details/data/repositories/reviews_repository_impl.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/review_model.dart';
import 'package:flutter_library/features/book_details/data/models/book_rating_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockReviewsRemoteDataSource extends Mock implements ReviewsRemoteDataSource {}
class MockReviewsLocalDataSource extends Mock implements ReviewsLocalDataSource {}

void main() {
  group('ReviewsRepositoryImpl', () {
    late ReviewsRepositoryImpl repository;
    late MockReviewsRemoteDataSource mockRemoteDataSource;
    late MockReviewsLocalDataSource mockLocalDataSource;

    setUp(() {
      mockRemoteDataSource = MockReviewsRemoteDataSource();
      mockLocalDataSource = MockReviewsLocalDataSource();
      repository = ReviewsRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
      );
    });

    const tBookId = 'test_book_id';
    const tReviewText = 'Great book!';
    const tRating = 4.5;
    
    final tReviewModel = ReviewModel(
      id: 'review_1',
      bookId: tBookId,
      userId: 'user_1',
      userName: 'John Doe',
      reviewText: tReviewText,
      rating: tRating,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final tReviewsList = [tReviewModel];

    group('getReviews', () {
      test('should return cached reviews when available', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedReviews(tBookId))
            .thenAnswer((_) async => tReviewsList);

        // act
        final result = await repository.getReviews(tBookId);

        // assert
        verify(() => mockLocalDataSource.getCachedReviews(tBookId));
        verifyNever(() => mockRemoteDataSource.getReviews(any()));
        expect(result, isA<Right<Failure, List<Review>>>());
        result.fold(
          (failure) => fail('Expected success'),
          (reviews) => expect(reviews, equals(tReviewsList)),
        );
      });

      test('should fetch from remote when cache is empty and cache the result', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedReviews(tBookId))
            .thenAnswer((_) async => <ReviewModel>[]);
        when(() => mockRemoteDataSource.getReviews(tBookId))
            .thenAnswer((_) async => tReviewsList);
        when(() => mockLocalDataSource.cacheReviews(tBookId, tReviewsList))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.getReviews(tBookId);

        // assert
        verify(() => mockLocalDataSource.getCachedReviews(tBookId));
        verify(() => mockRemoteDataSource.getReviews(tBookId));
        verify(() => mockLocalDataSource.cacheReviews(tBookId, tReviewsList));
        expect(result, isA<Right<Failure, List<Review>>>());
        result.fold(
          (failure) => fail('Expected success'),
          (reviews) => expect(reviews, equals(tReviewsList)),
        );
      });

      test('should return NetworkFailure when DioException occurs', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedReviews(tBookId))
            .thenAnswer((_) async => <ReviewModel>[]);
        when(() => mockRemoteDataSource.getReviews(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.getReviews(tBookId);

        // assert
        expect(result, isA<Left<Failure, List<Review>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (reviews) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedReviews(tBookId))
            .thenAnswer((_) async => <ReviewModel>[]);
        when(() => mockRemoteDataSource.getReviews(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.getReviews(tBookId);

        // assert
        expect(result, isA<Left<Failure, List<Review>>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (reviews) => fail('Expected failure'),
        );
      });
    });

    group('submitReview', () {
      test('should submit review successfully and clear cache', () async {
        // arrange
        when(() => mockRemoteDataSource.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        )).thenAnswer((_) async => tReviewModel);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        );

        // assert
        verify(() => mockRemoteDataSource.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        ));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, isA<Right<Failure, Review>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, equals(tReviewModel)),
        );
      });

      test('should return NetworkFailure when DioException occurs during submit', () async {
        // arrange
        when(() => mockRemoteDataSource.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        );

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (review) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs during submit', () async {
        // arrange
        when(() => mockRemoteDataSource.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        )).thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.submitReview(
          bookId: tBookId,
          reviewText: tReviewText,
          rating: tRating,
        );

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });

    group('updateReview', () {
      const tReviewId = 'review_1';
      const tUpdatedText = 'Updated review text';
      const tUpdatedRating = 3.5;
      
      test('should update review successfully and clear cache', () async {
        // arrange
        final updatedReview = tReviewModel.copyWith(
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
          updatedAt: DateTime(2023, 1, 2),
        );
        
        when(() => mockRemoteDataSource.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        )).thenAnswer((_) async => updatedReview);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        );

        // assert
        verify(() => mockRemoteDataSource.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        ));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, isA<Right<Failure, Review>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) {
            expect(review.reviewText, equals(tUpdatedText));
            expect(review.rating, equals(tUpdatedRating));
          },
        );
      });

      test('should return NetworkFailure when DioException occurs during update', () async {
        // arrange
        when(() => mockRemoteDataSource.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            ));

        // act
        final result = await repository.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        );

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('Connection timeout'));
          },
          (review) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure for 404 error during update', () async {
        // arrange
        when(() => mockRemoteDataSource.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 404,
                statusMessage: 'Review not found',
              ),
            ));

        // act
        final result = await repository.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        );

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Reviews not found'));
          },
          (review) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs during update', () async {
        // arrange
        when(() => mockRemoteDataSource.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        )).thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.updateReview(
          reviewId: tReviewId,
          reviewText: tUpdatedText,
          rating: tUpdatedRating,
        );

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });

    group('deleteReview', () {
      const tReviewId = 'review_1';
      
      test('should delete review successfully and clear cache', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteReview(tReviewId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // act
        final result = await repository.deleteReview(tReviewId);

        // assert
        verify(() => mockRemoteDataSource.deleteReview(tReviewId));
        verify(() => mockLocalDataSource.clearCache());
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected success'),
          (_) => {}, // void result, just verify success
        );
      });

      test('should return NetworkFailure when DioException occurs during delete', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteReview(tReviewId))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            ));

        // act
        final result = await repository.deleteReview(tReviewId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('Connection timeout'));
          },
          (result) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure for 401 error during delete', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteReview(tReviewId))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                statusMessage: 'Unauthorized',
              ),
            ));

        // act
        final result = await repository.deleteReview(tReviewId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Unauthorized access'));
          },
          (result) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs during delete', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteReview(tReviewId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.deleteReview(tReviewId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (result) => fail('Expected failure'),
        );
      });
    });

    group('Error Handling', () {
      test('should handle different DioException types correctly', () async {
        // Test different error scenarios
        final errorTypes = [
          (DioExceptionType.connectionTimeout, NetworkFailure),
          (DioExceptionType.sendTimeout, NetworkFailure),
          (DioExceptionType.receiveTimeout, NetworkFailure),
          (DioExceptionType.cancel, NetworkFailure),
          (DioExceptionType.unknown, NetworkFailure),
        ];

        for (final (exceptionType, expectedFailureType) in errorTypes) {
          when(() => mockLocalDataSource.getCachedReviews(tBookId))
              .thenAnswer((_) async => <ReviewModel>[]);
          when(() => mockRemoteDataSource.getReviews(tBookId))
              .thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                type: exceptionType,
              ));

          final result = await repository.getReviews(tBookId);

          expect(result, isA<Left<Failure, List<Review>>>());
          result.fold(
            (failure) => expect(failure.runtimeType, equals(expectedFailureType)),
            (reviews) => fail('Expected failure for $exceptionType'),
          );
        }
      });

      test('should handle server response codes correctly', () async {
        final statusCodes = [
          (404, 'Reviews not found'),
          (401, 'Unauthorized access'),
          (500, 'Server error'),
        ];

        for (final (statusCode, expectedMessage) in statusCodes) {
          when(() => mockLocalDataSource.getCachedReviews(tBookId))
              .thenAnswer((_) async => <ReviewModel>[]);
          when(() => mockRemoteDataSource.getReviews(tBookId))
              .thenThrow(DioException(
                requestOptions: RequestOptions(path: ''),
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: RequestOptions(path: ''),
                  statusCode: statusCode,
                  statusMessage: 'Error',
                ),
              ));

          final result = await repository.getReviews(tBookId);

          expect(result, isA<Left<Failure, List<Review>>>());
          result.fold(
            (failure) {
              expect(failure, isA<ServerFailure>());
              expect(failure.message, contains(expectedMessage));
            },
            (reviews) => fail('Expected failure for status code $statusCode'),
          );
        }
      });
    });

    group('submitRating', () {
      final tBookRatingModel = BookRatingModel(
        id: 'rating_1',
        bookId: tBookId,
        userId: 'user_1',
        rating: 4.5,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      test('should submit rating successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.submitRating(
          bookId: tBookId,
          rating: tRating,
        )).thenAnswer((_) async => tBookRatingModel);

        // act
        final result = await repository.submitRating(
          bookId: tBookId,
          rating: tRating,
        );

        // assert
        verify(() => mockRemoteDataSource.submitRating(
          bookId: tBookId,
          rating: tRating,
        ));
        expect(result, isA<Right<Failure, BookRating>>());
        result.fold(
          (failure) => fail('Expected success'),
          (rating) => expect(rating, equals(tBookRatingModel)),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.submitRating(
          bookId: tBookId,
          rating: tRating,
        )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.submitRating(
          bookId: tBookId,
          rating: tRating,
        );

        // assert
        expect(result, isA<Left<Failure, BookRating>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (rating) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.submitRating(
          bookId: tBookId,
          rating: tRating,
        )).thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.submitRating(
          bookId: tBookId,
          rating: tRating,
        );

        // assert
        expect(result, isA<Left<Failure, BookRating>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (rating) => fail('Expected failure'),
        );
      });
    });

    group('getUserRating', () {
      final tBookRatingModel = BookRatingModel(
        id: 'rating_1',
        bookId: tBookId,
        userId: 'user_1',
        rating: 4.5,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      test('should get user rating successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserRating(tBookId))
            .thenAnswer((_) async => tBookRatingModel);

        // act
        final result = await repository.getUserRating(tBookId);

        // assert
        verify(() => mockRemoteDataSource.getUserRating(tBookId));
        expect(result, isA<Right<Failure, BookRating?>>());
        result.fold(
          (failure) => fail('Expected success'),
          (rating) => expect(rating, equals(tBookRatingModel)),
        );
      });

      test('should return null when no rating exists', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserRating(tBookId))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getUserRating(tBookId);

        // assert
        verify(() => mockRemoteDataSource.getUserRating(tBookId));
        expect(result, isA<Right<Failure, BookRating?>>());
        result.fold(
          (failure) => fail('Expected success'),
          (rating) => expect(rating, isNull),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserRating(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.getUserRating(tBookId);

        // assert
        expect(result, isA<Left<Failure, BookRating?>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (rating) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserRating(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.getUserRating(tBookId);

        // assert
        expect(result, isA<Left<Failure, BookRating?>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (rating) => fail('Expected failure'),
        );
      });
    });

    group('voteHelpful', () {
      const tReviewId = 'review_1';

      test('should vote helpful successfully and clear cache', () async {
        // arrange
        when(() => mockRemoteDataSource.voteHelpful(tReviewId))
            .thenAnswer((_) async => tReviewModel);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.voteHelpful(tReviewId);

        // assert
        verify(() => mockRemoteDataSource.voteHelpful(tReviewId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, isA<Right<Failure, Review>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, equals(tReviewModel)),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.voteHelpful(tReviewId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.voteHelpful(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.voteHelpful(tReviewId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.voteHelpful(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });

    group('voteUnhelpful', () {
      const tReviewId = 'review_1';

      test('should vote unhelpful successfully and clear cache', () async {
        // arrange
        when(() => mockRemoteDataSource.voteUnhelpful(tReviewId))
            .thenAnswer((_) async => tReviewModel);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.voteUnhelpful(tReviewId);

        // assert
        verify(() => mockRemoteDataSource.voteUnhelpful(tReviewId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, isA<Right<Failure, Review>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, equals(tReviewModel)),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.voteUnhelpful(tReviewId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.voteUnhelpful(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.voteUnhelpful(tReviewId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.voteUnhelpful(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });

    group('removeVote', () {
      const tReviewId = 'review_1';

      test('should remove vote successfully and clear cache', () async {
        // arrange
        when(() => mockRemoteDataSource.removeVote(tReviewId))
            .thenAnswer((_) async => tReviewModel);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.removeVote(tReviewId);

        // assert
        verify(() => mockRemoteDataSource.removeVote(tReviewId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, isA<Right<Failure, Review>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, equals(tReviewModel)),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.removeVote(tReviewId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.removeVote(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.removeVote(tReviewId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.removeVote(tReviewId);

        // assert
        expect(result, isA<Left<Failure, Review>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });

    group('reportReview', () {
      const tReviewId = 'review_1';
      const tReason = 'Inappropriate content';

      test('should report review successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        )).thenAnswer((_) async => {});

        // act
        final result = await repository.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        );

        // assert
        verify(() => mockRemoteDataSource.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        ));
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected success'),
          (_) {},
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        );

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (result) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        )).thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.reportReview(
          reviewId: tReviewId,
          reason: tReason,
        );

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (result) => fail('Expected failure'),
        );
      });
    });

    group('getUserReview', () {
      test('should get user review successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserReview(tBookId))
            .thenAnswer((_) async => tReviewModel);

        // act
        final result = await repository.getUserReview(tBookId);

        // assert
        verify(() => mockRemoteDataSource.getUserReview(tBookId));
        expect(result, isA<Right<Failure, Review?>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, equals(tReviewModel)),
        );
      });

      test('should return null when no user review exists', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserReview(tBookId))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getUserReview(tBookId);

        // assert
        verify(() => mockRemoteDataSource.getUserReview(tBookId));
        expect(result, isA<Right<Failure, Review?>>());
        result.fold(
          (failure) => fail('Expected success'),
          (review) => expect(review, isNull),
        );
      });

      test('should return ServerFailure when DioException occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserReview(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.getUserReview(tBookId);

        // assert
        expect(result, isA<Left<Failure, Review?>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });

      test('should return ServerFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserReview(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.getUserReview(tBookId);

        // assert
        expect(result, isA<Left<Failure, Review?>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (review) => fail('Expected failure'),
        );
      });
    });
  });
}
