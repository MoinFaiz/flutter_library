import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_rating_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late SubmitRatingUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = SubmitRatingUseCase(mockRepository);
  });

  final testRating = BookRating(
    id: 'rating1',
    bookId: 'book1',
    userId: 'user1',
    rating: 4.5,
    createdAt: DateTime(2025, 10, 31),
    updatedAt: DateTime(2025, 10, 31),
  );

  group('SubmitRatingUseCase', () {
    test('should submit rating when inputs are valid', () async {
      // Arrange
      when(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 4.5,
          )).thenAnswer((_) async => Right(testRating));

      // Act
      final result = await useCase(bookId: 'book1', rating: 4.5);

      // Assert
      expect(result, equals(Right(testRating)));
      verify(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 4.5,
          )).called(1);
    });

    test('should accept rating of 0.0', () async {
      // Arrange
      final zeroRating = BookRating(
        id: 'rating2',
        bookId: 'book1',
        userId: 'user1',
        rating: 0.0,
        createdAt: DateTime(2025, 10, 31),
        updatedAt: DateTime(2025, 10, 31),
      );
      when(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 0.0,
          )).thenAnswer((_) async => Right(zeroRating));

      // Act
      final result = await useCase(bookId: 'book1', rating: 0.0);

      // Assert
      expect(result, equals(Right(zeroRating)));
      verify(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 0.0,
          )).called(1);
    });

    test('should accept rating of 5.0', () async {
      // Arrange
      final maxRating = BookRating(
        id: 'rating3',
        bookId: 'book1',
        userId: 'user1',
        rating: 5.0,
        createdAt: DateTime(2025, 10, 31),
        updatedAt: DateTime(2025, 10, 31),
      );
      when(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 5.0,
          )).thenAnswer((_) async => Right(maxRating));

      // Act
      final result = await useCase(bookId: 'book1', rating: 5.0);

      // Assert
      expect(result, equals(Right(maxRating)));
      verify(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 5.0,
          )).called(1);
    });

    test('should return ValidationFailure when rating is negative', () async {
      // Act
      final result = await useCase(bookId: 'book1', rating: -1.0);

      // Assert
      expect(result, equals(Left(ValidationFailure('Rating must be between 0 and 5'))));
      verifyNever(() => mockRepository.submitRating(
            bookId: any(named: 'bookId'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ValidationFailure when rating exceeds 5.0', () async {
      // Act
      final result = await useCase(bookId: 'book1', rating: 5.5);

      // Assert
      expect(result, equals(Left(ValidationFailure('Rating must be between 0 and 5'))));
      verifyNever(() => mockRepository.submitRating(
            bookId: any(named: 'bookId'),
            rating: any(named: 'rating'),
          ));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 4.5,
          )).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to submit')));

      // Act
      final result = await useCase(bookId: 'book1', rating: 4.5);

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to submit'))));
      verify(() => mockRepository.submitRating(
            bookId: 'book1',
            rating: 4.5,
          )).called(1);
    });
  });
}
