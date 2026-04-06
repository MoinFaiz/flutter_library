import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_review_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late GetUserReviewUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = GetUserReviewUseCase(mockRepository);
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
    helpfulCount: 5,
    unhelpfulCount: 1,
  );

  group('GetUserReviewUseCase', () {
    test('should return user review when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.getUserReview('book1'))
          .thenAnswer((_) async => Right(testReview));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(Right(testReview)));
      verify(() => mockRepository.getUserReview('book1')).called(1);
    });

    test('should return null when user has no review', () async {
      // Arrange
      when(() => mockRepository.getUserReview('book1'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.getUserReview('book1')).called(1);
    });

    test('should return ValidationFailure when bookId is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Book ID cannot be empty'))));
      verifyNever(() => mockRepository.getUserReview(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getUserReview('book1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
      verify(() => mockRepository.getUserReview('book1')).called(1);
    });
  });
}
