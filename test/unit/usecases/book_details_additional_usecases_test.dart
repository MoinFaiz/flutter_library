import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_reviews_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/domain/repositories/rental_status_repository.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockRentalStatusRepository extends Mock implements RentalStatusRepository {}
class MockReviewsRepository extends Mock implements ReviewsRepository {}
class MockBookOperationsRepository extends Mock implements BookOperationsRepository {}

void main() {
  group('Book Details Additional Use Cases Tests', () {
    late MockRentalStatusRepository mockRentalStatusRepository;
    late MockReviewsRepository mockReviewsRepository;
    late MockBookOperationsRepository mockBookOperationsRepository;

    setUp(() {
      mockRentalStatusRepository = MockRentalStatusRepository();
      mockReviewsRepository = MockReviewsRepository();
      mockBookOperationsRepository = MockBookOperationsRepository();
    });

    final mockRentalStatus = RentalStatus(
      bookId: 'book_123',
      status: RentalStatusType.rented,
      dueDate: DateTime(2024, 1, 15),
      rentedDate: DateTime(2024, 1, 1),
      daysRemaining: 14,
      canRenew: true,
    );

    final mockReview = Review(
      id: 'review_123',
      bookId: 'book_123',
      userId: 'user_456',
      userName: 'John Doe',
      reviewText: 'Great book!',
      rating: 4.5,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final mockBook = Book(
      id: 'book_123',
      title: 'Test Book',
      author: 'Test Author',
      description: 'Test Description',
      imageUrls: const ['test.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        totalCopies: 3,
        availableForRentCount: 2,
        availableForSaleCount: 5,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      isFavorite: false,
      isFromFriend: false,
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('GetRentalStatusUseCase', () {
      late GetRentalStatusUseCase useCase;

      setUp(() {
        useCase = GetRentalStatusUseCase(repository: mockRentalStatusRepository);
      });

      test('should return rental status when repository call is successful', () async {
        // Arrange
        when(() => mockRentalStatusRepository.getRentalStatus('book_123'))
            .thenAnswer((_) async => Right(mockRentalStatus));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, Right(mockRentalStatus));
        verify(() => mockRentalStatusRepository.getRentalStatus('book_123')).called(1);
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockRentalStatusRepository.getRentalStatus('book_123'))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ServerFailure()));
        verify(() => mockRentalStatusRepository.getRentalStatus('book_123')).called(1);
      });

      test('should handle network failure gracefully', () async {
        // Arrange
        when(() => mockRentalStatusRepository.getRentalStatus('book_123'))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(NetworkFailure()));
      });
    });

    group('RenewBookUseCase', () {
      late RenewBookUseCase useCase;

      setUp(() {
        useCase = RenewBookUseCase(repository: mockBookOperationsRepository);
      });

      test('should return book when renewed successfully', () async {
        // Arrange
        when(() => mockBookOperationsRepository.renewBook('book_123'))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, Right(mockBook));
        verify(() => mockBookOperationsRepository.renewBook('book_123')).called(1);
      });

      test('should return failure when renewal limit is exceeded', () async {
        // Arrange
        when(() => mockBookOperationsRepository.renewBook('book_123'))
            .thenAnswer((_) async => const Left(ValidationFailure('Renewal limit exceeded')));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ValidationFailure('Renewal limit exceeded')));
      });

      test('should return failure when book is not currently rented', () async {
        // Arrange
        when(() => mockBookOperationsRepository.renewBook('book_123'))
            .thenAnswer((_) async => const Left(ValidationFailure('Book is not rented')));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ValidationFailure('Book is not rented')));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(() => mockBookOperationsRepository.renewBook('book_123'))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('GetReviewsUseCase', () {
      late GetReviewsUseCase useCase;

      setUp(() {
        useCase = GetReviewsUseCase(repository: mockReviewsRepository);
      });

      test('should return list of reviews when repository call is successful', () async {
        // Arrange
        final reviews = [mockReview];
        when(() => mockReviewsRepository.getReviews('book_123'))
            .thenAnswer((_) async => Right(reviews));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, Right(reviews));
        verify(() => mockReviewsRepository.getReviews('book_123')).called(1);
      });

      test('should return empty list when no reviews exist', () async {
        // Arrange
        when(() => mockReviewsRepository.getReviews('book_123'))
            .thenAnswer((_) async => const Right<Failure, List<Review>>([]));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Right<Failure, List<Review>>([]));
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockReviewsRepository.getReviews('book_123'))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('SubmitReviewUseCase', () {
      late SubmitReviewUseCase useCase;

      setUp(() {
        useCase = SubmitReviewUseCase(mockReviewsRepository);
      });

      test('should return review when submitted successfully', () async {
        // Arrange
        when(() => mockReviewsRepository.submitReview(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 4.5,
        )).thenAnswer((_) async => Right(mockReview));

        // Act
        final result = await useCase(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 4.5,
        );

        // Assert
        expect(result, Right(mockReview));
        verify(() => mockReviewsRepository.submitReview(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 4.5,
        )).called(1);
      });

      test('should return validation failure for invalid rating', () async {
        // Act
        final result = await useCase(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 6.0,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return validation failure for empty review text', () async {
        // Act
        final result = await useCase(
          bookId: 'book_123',
          reviewText: '',
          rating: 4.5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return validation failure for short review text', () async {
        // Act
        final result = await useCase(
          bookId: 'book_123',
          reviewText: 'Short',
          rating: 4.5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('RemoveFromCartUseCase', () {
      late RemoveFromCartUseCase useCase;

      setUp(() {
        useCase = RemoveFromCartUseCase(repository: mockBookOperationsRepository);
      });

      test('should return success when book is removed from cart', () async {
        // Arrange
        when(() => mockBookOperationsRepository.removeFromCart('book_123'))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, Right(mockBook));
        verify(() => mockBookOperationsRepository.removeFromCart('book_123')).called(1);
      });

      test('should handle book not in cart gracefully', () async {
        // Arrange
        when(() => mockBookOperationsRepository.removeFromCart('book_123'))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not in cart')));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ValidationFailure('Book not in cart')));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(() => mockBookOperationsRepository.removeFromCart('book_123'))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase('book_123');

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('Integration Tests', () {
      test('should handle complete book review workflow', () async {
        // Arrange
        final getReviewsUseCase = GetReviewsUseCase(repository: mockReviewsRepository);
        final submitReviewUseCase = SubmitReviewUseCase(mockReviewsRepository);

        when(() => mockReviewsRepository.getReviews('book_123'))
            .thenAnswer((_) async => const Right([]));
        when(() => mockReviewsRepository.submitReview(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 4.5,
        )).thenAnswer((_) async => Right(mockReview));

        // Act & Assert
        final initialReviews = await getReviewsUseCase('book_123');
        expect(initialReviews.fold((_) => null, (reviews) => reviews.length), 0);

        final submitResult = await submitReviewUseCase(
          bookId: 'book_123',
          reviewText: 'Great book!',
          rating: 4.5,
        );
        expect(submitResult, Right(mockReview));
      });

      test('should handle rental status workflow', () async {
        // Arrange
        final getRentalStatusUseCase = GetRentalStatusUseCase(repository: mockRentalStatusRepository);
        final renewBookUseCase = RenewBookUseCase(repository: mockBookOperationsRepository);

        when(() => mockRentalStatusRepository.getRentalStatus('book_123'))
            .thenAnswer((_) async => Right(mockRentalStatus));
        when(() => mockBookOperationsRepository.renewBook('book_123'))
            .thenAnswer((_) async => Right(mockBook));

        // Act & Assert
        final statusResult = await getRentalStatusUseCase('book_123');
        expect(statusResult, Right(mockRentalStatus));

        final renewResult = await renewBookUseCase('book_123');
        expect(renewResult, Right(mockBook));
      });
    });
  });
}
