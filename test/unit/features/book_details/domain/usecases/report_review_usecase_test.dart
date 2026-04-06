import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/report_review_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}

void main() {
  late ReportReviewUseCase useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = ReportReviewUseCase(mockRepository);
  });

  group('ReportReviewUseCase', () {
    test('should report review when all inputs are valid', () async {
      // Arrange
      when(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: 'Inappropriate content',
      );

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).called(1);
    });

    test('should trim reason before reporting', () async {
      // Arrange
      when(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: '  Inappropriate content  ',
      );

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).called(1);
    });

    test('should return ValidationFailure when reviewId is empty', () async {
      // Act
      final result = await useCase(
        reviewId: '',
        reason: 'Inappropriate content',
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Review ID cannot be empty'))));
      verifyNever(() => mockRepository.reportReview(
            reviewId: any(named: 'reviewId'),
            reason: any(named: 'reason'),
          ));
    });

    test('should return ValidationFailure when reason is empty', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: '',
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Please provide a reason for reporting'))));
      verifyNever(() => mockRepository.reportReview(
            reviewId: any(named: 'reviewId'),
            reason: any(named: 'reason'),
          ));
    });

    test('should return ValidationFailure when reason is only whitespace', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: '   ',
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Please provide a reason for reporting'))));
      verifyNever(() => mockRepository.reportReview(
            reviewId: any(named: 'reviewId'),
            reason: any(named: 'reason'),
          ));
    });

    test('should return ValidationFailure when reason is too short', () async {
      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: 'Bad',
      );

      // Assert
      expect(result, equals(Left(ValidationFailure('Reason must be at least 10 characters long'))));
      verifyNever(() => mockRepository.reportReview(
            reviewId: any(named: 'reviewId'),
            reason: any(named: 'reason'),
          ));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to report')));

      // Act
      final result = await useCase(
        reviewId: 'review1',
        reason: 'Inappropriate content',
      );

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to report'))));
      verify(() => mockRepository.reportReview(
            reviewId: 'review1',
            reason: 'Inappropriate content',
          )).called(1);
    });
  });
}
