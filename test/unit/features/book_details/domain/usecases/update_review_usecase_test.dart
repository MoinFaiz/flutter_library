import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/update_review_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late UpdateReviewUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = UpdateReviewUseCase(mockRepository);
  });

  final testReview = Review(
    id: 'review1',
    bookId: 'book1',
    userId: 'user1',
    userName: 'John Doe',
    rating: 4.5,
    reviewText: 'Updated review text',
    createdAt: DateTime(2025, 10, 30),
    updatedAt: DateTime(2025, 10, 31),
    helpfulCount: 5,
    unhelpfulCount: 1,
    isEdited: true,
  );

  group('UpdateReviewUseCase', () {
    test('should update review when all inputs are valid', () async {
      // Arrange
      when(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).thenAnswer((_) async => Right(testReview));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: 'Updated review text',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(Right(testReview)));
      verify(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).called(1);
    });

    test('should trim review text before updating', () async {
      // Arrange
      when(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).thenAnswer((_) async => Right(testReview));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: '  Updated review text  ',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(Right(testReview)));
      verify(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).called(1);
    });

    test('should return ValidationFailure when reviewText is empty', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: '',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Review text cannot be empty'))));
      verifyNever(() => mockRepository.updateReview(
            reviewId: any(named: 'reviewId'),
            reviewText: any(named: 'reviewText'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ValidationFailure when reviewText is only whitespace', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: '   ',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Review text cannot be empty'))));
      verifyNever(() => mockRepository.updateReview(
            reviewId: any(named: 'reviewId'),
            reviewText: any(named: 'reviewText'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ValidationFailure when reviewText is too short', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: 'Short',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Review must be at least 10 characters long'))));
      verifyNever(() => mockRepository.updateReview(
            reviewId: any(named: 'reviewId'),
            reviewText: any(named: 'reviewText'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ValidationFailure when rating is negative', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: 'Updated review text',
        rating: -1.0,
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Rating must be between 0 and 5'))));
      verifyNever(() => mockRepository.updateReview(
            reviewId: any(named: 'reviewId'),
            reviewText: any(named: 'reviewText'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ValidationFailure when rating exceeds 5.0', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: 'Updated review text',
        rating: 6.0,
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Rating must be between 0 and 5'))));
      verifyNever(() => mockRepository.updateReview(
            reviewId: any(named: 'reviewId'),
            reviewText: any(named: 'reviewText'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to update')));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reviewText: 'Updated review text',
        rating: 4.5,
      );

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to update'))));
      verify(() => mockRepository.updateReview(
            reviewId: 'review1',
            reviewText: 'Updated review text',
            rating: 4.5,
          )).called(1);
    });
  });
}
