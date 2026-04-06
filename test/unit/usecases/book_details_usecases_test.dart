import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_reviews_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/repositories/rental_status_repository.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockReviewsRepository extends Mock implements ReviewsRepository {}
class MockRentalStatusRepository extends Mock implements RentalStatusRepository {}

void main() {
  group('Book Details Use Cases Tests', () {
    late MockReviewsRepository mockReviewsRepository;
    late MockRentalStatusRepository mockRentalStatusRepository;
    late GetReviewsUseCase getReviewsUseCase;
    late GetRentalStatusUseCase getRentalStatusUseCase;

    setUp(() {
      mockReviewsRepository = MockReviewsRepository();
      mockRentalStatusRepository = MockRentalStatusRepository();
      getReviewsUseCase = GetReviewsUseCase(repository: mockReviewsRepository);
      getRentalStatusUseCase = GetRentalStatusUseCase(repository: mockRentalStatusRepository);
    });

    final tReview = Review(
      id: 'review_123',
      bookId: 'book_123',
      userId: 'user_123',
      userName: 'John Doe',
      reviewText: 'Great book! Highly recommended.',
      rating: 4.5,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    );

    final tRentalStatus = RentalStatus(
      bookId: 'book_123',
      status: RentalStatusType.rented,
      dueDate: DateTime(2024, 1, 31),
      rentedDate: DateTime(2024, 1, 1),
      daysRemaining: 16,
      canRenew: true,
      isInCart: false,
      isPurchased: false,
    );

    group('GetReviewsUseCase', () {
      test('should return list of reviews from repository', () async {
        // arrange
        const bookId = 'book_123';
        final reviews = [tReview];
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => Right(reviews));

        // act
        final result = await getReviewsUseCase.call(bookId);

        // assert
        expect(result, equals(Right(reviews)));
        verify(() => mockReviewsRepository.getReviews(bookId)).called(1);
      });

      test('should return empty list when no reviews exist', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => const Right<Failure, List<Review>>([]));

        // act
        final result = await getReviewsUseCase.call(bookId);

        // assert
        expect(result, equals(const Right<Failure, List<Review>>([])));
        verify(() => mockReviewsRepository.getReviews(bookId)).called(1);
      });

      test('should return server failure when repository fails', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

        // act
        final result = await getReviewsUseCase.call(bookId);

        // assert
        expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
        verify(() => mockReviewsRepository.getReviews(bookId)).called(1);
      });

      test('should return network failure when network error occurs', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));

        // act
        final result = await getReviewsUseCase.call(bookId);

        // assert
        expect(result, equals(const Left(NetworkFailure(message: 'Network error'))));
        verify(() => mockReviewsRepository.getReviews(bookId)).called(1);
      });
    });

    group('GetRentalStatusUseCase', () {
      test('should return rental status from repository', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRentalStatusRepository.getRentalStatus(bookId))
            .thenAnswer((_) async => Right(tRentalStatus));

        // act
        final result = await getRentalStatusUseCase.call(bookId);

        // assert
        expect(result, equals(Right(tRentalStatus)));
        verify(() => mockRentalStatusRepository.getRentalStatus(bookId)).called(1);
      });

      test('should return server failure when repository fails', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRentalStatusRepository.getRentalStatus(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

        // act
        final result = await getRentalStatusUseCase.call(bookId);

        // assert
        expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
        verify(() => mockRentalStatusRepository.getRentalStatus(bookId)).called(1);
      });

      test('should handle different rental status types', () async {
        // arrange
        const bookId = 'book_123';
        final overdueStatus = RentalStatus(
          bookId: bookId,
          status: RentalStatusType.overdue,
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          rentedDate: DateTime(2024, 1, 1),
          daysRemaining: -5,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
          lateFee: 5.0,
        );
        when(() => mockRentalStatusRepository.getRentalStatus(bookId))
            .thenAnswer((_) async => Right(overdueStatus));

        // act
        final result = await getRentalStatusUseCase.call(bookId);

        // assert
        expect(result, equals(Right(overdueStatus)));
        verify(() => mockRentalStatusRepository.getRentalStatus(bookId)).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('should handle getting rental status and reviews for same book', () async {
        // arrange
        const bookId = 'book_123';
        final reviews = [tReview];
        
        when(() => mockRentalStatusRepository.getRentalStatus(bookId))
            .thenAnswer((_) async => Right(tRentalStatus));
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => Right(reviews));

        // act
        final rentalResult = await getRentalStatusUseCase.call(bookId);
        final reviewsResult = await getReviewsUseCase.call(bookId);

        // assert
        expect(rentalResult, equals(Right(tRentalStatus)));
        expect(reviewsResult, equals(Right(reviews)));
        verify(() => mockRentalStatusRepository.getRentalStatus(bookId)).called(1);
        verify(() => mockReviewsRepository.getReviews(bookId)).called(1);
      });

      test('should handle multiple concurrent review requests', () async {
        // arrange
        const bookId = 'book_123';
        final reviews = [tReview];
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenAnswer((_) async => Right(reviews));

        // act
        final results = await Future.wait([
          getReviewsUseCase.call(bookId),
          getReviewsUseCase.call(bookId),
          getReviewsUseCase.call(bookId),
        ]);

        // assert
        for (final result in results) {
          expect(result, equals(Right(reviews)));
        }
        verify(() => mockReviewsRepository.getReviews(bookId)).called(3);
      });
    });

    group('Error Handling', () {
      test('should handle repository exception gracefully for reviews', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockReviewsRepository.getReviews(bookId))
            .thenThrow(Exception('Unexpected error'));

        // act & assert
        expect(
          () => getReviewsUseCase.call(bookId),
          throwsException,
        );
      });

      test('should handle repository exception gracefully for rental status', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRentalStatusRepository.getRentalStatus(bookId))
            .thenThrow(Exception('Unexpected error'));

        // act & assert
        expect(
          () => getRentalStatusUseCase.call(bookId),
          throwsException,
        );
      });
    });
  });
}
