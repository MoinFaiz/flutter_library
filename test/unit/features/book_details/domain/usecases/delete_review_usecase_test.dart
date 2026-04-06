import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/delete_review_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late DeleteReviewUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = DeleteReviewUseCase(mockRepository);
  });

  group('DeleteReviewUseCase', () {
    test('should delete review when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.deleteReview('review1'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase('review1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.deleteReview('review1')).called(1);
    });

    test('should return ValidationFailure when reviewId is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, equals(Left(ValidationFailure('Review ID cannot be empty'))));
      verifyNever(() => mockRepository.deleteReview(any()));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.deleteReview('review1'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to delete')));

      // Act
      final result = await useCase('review1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to delete'))));
      verify(() => mockRepository.deleteReview('review1')).called(1);
    });
  });
}
