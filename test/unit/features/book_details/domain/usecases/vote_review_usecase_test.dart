import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/vote_review_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late VoteReviewUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = VoteReviewUseCase(mockRepository);
  });

  final testReview = Review(
    id: 'review1',
    bookId: 'book1',
    userId: 'user1',
    userName: 'John Doe',
    rating: 4.5,
    reviewText: 'Great book!',
    createdAt: DateTime(2025, 10, 31),
    updatedAt: DateTime(2025, 10, 31),
    helpfulCount: 6,
    unhelpfulCount: 1,
    currentUserVote: 'helpful',
  );

  group('VoteReviewUseCase - voteHelpful', () {
    test('should vote helpful when reviewId is valid', () async {
      // Arrange
      when(() => mockRepository.voteHelpful('review1'))
          .thenAnswer((_) async => Right(testReview));

      // Act
      final result = await useCase.voteHelpful('review1');

      // Assert
      expect(result, equals(Right(testReview)));
      verify(() => mockRepository.voteHelpful('review1')).called(1);
    });

    test('should return ValidationFailure when reviewId is empty', () async {
      // Act
      final result = await useCase.voteHelpful('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Review ID cannot be empty'))));
      verifyNever(() => mockRepository.voteHelpful(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.voteHelpful('review1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to vote')));

      // Act
      final result = await useCase.voteHelpful('review1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to vote'))));
      verify(() => mockRepository.voteHelpful('review1')).called(1);
    });
  });

  group('VoteReviewUseCase - voteUnhelpful', () {
    test('should vote unhelpful when reviewId is valid', () async {
      // Arrange
      final unhelpfulReview = Review(
        id: 'review1',
        bookId: 'book1',
        userId: 'user1',
        userName: 'John Doe',
        rating: 4.5,
        reviewText: 'Great book!',
        createdAt: DateTime(2025, 10, 31),
        updatedAt: DateTime(2025, 10, 31),
        helpfulCount: 5,
        unhelpfulCount: 2,
        currentUserVote: 'unhelpful',
      );
      when(() => mockRepository.voteUnhelpful('review1'))
          .thenAnswer((_) async => Right(unhelpfulReview));

      // Act
      final result = await useCase.voteUnhelpful('review1');

      // Assert
      expect(result, equals(Right(unhelpfulReview)));
      verify(() => mockRepository.voteUnhelpful('review1')).called(1);
    });

    test('should return ValidationFailure when reviewId is empty', () async {
      // Act
      final result = await useCase.voteUnhelpful('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Review ID cannot be empty'))));
      verifyNever(() => mockRepository.voteUnhelpful(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.voteUnhelpful('review1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to vote')));

      // Act
      final result = await useCase.voteUnhelpful('review1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to vote'))));
      verify(() => mockRepository.voteUnhelpful('review1')).called(1);
    });
  });

  group('VoteReviewUseCase - removeVote', () {
    test('should remove vote when reviewId is valid', () async {
      // Arrange
      final removedVoteReview = Review(
        id: 'review1',
        bookId: 'book1',
        userId: 'user1',
        userName: 'John Doe',
        rating: 4.5,
        reviewText: 'Great book!',
        createdAt: DateTime(2025, 10, 31),
        updatedAt: DateTime(2025, 10, 31),
        helpfulCount: 5,
        unhelpfulCount: 1,
      );
      when(() => mockRepository.removeVote('review1'))
          .thenAnswer((_) async => Right(removedVoteReview));

      // Act
      final result = await useCase.removeVote('review1');

      // Assert
      expect(result, equals(Right(removedVoteReview)));
      verify(() => mockRepository.removeVote('review1')).called(1);
    });

    test('should return ValidationFailure when reviewId is empty', () async {
      // Act
      final result = await useCase.removeVote('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Review ID cannot be empty'))));
      verifyNever(() => mockRepository.removeVote(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.removeVote('review1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to remove vote')));

      // Act
      final result = await useCase.removeVote('review1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to remove vote'))));
      verify(() => mockRepository.removeVote('review1')).called(1);
    });
  });
}
