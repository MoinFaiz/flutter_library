import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_rating_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late GetUserRatingUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = GetUserRatingUseCase(mockRepository);
  });

  final testRating = BookRating(
    id: 'rating1',
    bookId: 'book1',
    userId: 'user1',
    rating: 4.5,
    createdAt: DateTime(2025, 10, 31),
    updatedAt: DateTime(2025, 10, 31),
  );

  group('GetUserRatingUseCase', () {
    test('should return user rating when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.getUserRating('book1'))
          .thenAnswer((_) async => Right(testRating));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(Right(testRating)));
      verify(() => mockRepository.getUserRating('book1')).called(1);
    });

    test('should return null when user has no rating', () async {
      // Arrange
      when(() => mockRepository.getUserRating('book1'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.getUserRating('book1')).called(1);
    });

    test('should return ValidationFailure when bookId is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Book ID cannot be empty'))));
      verifyNever(() => mockRepository.getUserRating(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getUserRating('book1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase('book1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
      verify(() => mockRepository.getUserRating('book1')).called(1);
    });
  });
}
