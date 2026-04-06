import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookOperationsRepository extends Mock implements BookOperationsRepository {}

void main() {
  group('Book Operations Use Cases Tests', () {
    late MockBookOperationsRepository mockRepository;

    setUp(() {
      mockRepository = MockBookOperationsRepository();
    });

    final mockPricing = BookPricing(
      salePrice: 25.99,
      rentPrice: 5.99,
      discountedSalePrice: 22.09,
      discountedRentPrice: 5.39,
    );

    final mockAvailability = BookAvailability(
      totalCopies: 10,
      availableForRentCount: 5,
      availableForSaleCount: 3,
    );

    final mockMetadata = BookMetadata(
      genres: ['Fiction', 'Adventure'],
      ageAppropriateness: AgeAppropriateness.youngAdult,
      pageCount: 350,
      language: 'English',
    );

    final mockBook = Book(
      id: 'book_123',
      title: 'The Great Adventure',
      author: 'John Author',
      imageUrls: ['https://example.com/book.jpg'],
      rating: 4.5,
      pricing: mockPricing,
      availability: mockAvailability,
      metadata: mockMetadata,
      isFromFriend: false,
      isFavorite: false,
      description: 'An exciting adventure story.',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 6, 1),
    );

    group('RentBookUseCase', () {
      late RentBookUseCase useCase;

      setUp(() {
        useCase = RentBookUseCase(repository: mockRepository);
      });

      test('should return book when rent operation succeeds', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Right<Failure, Book>>());
        final book = result.fold((l) => null, (r) => r);
        expect(book, mockBook);
        expect(book?.id, bookId);
        verify(() => mockRepository.rentBook(bookId)).called(1);
      });

      test('should return failure when book is not available for rent', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available for rent')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book not available for rent');
        verify(() => mockRepository.rentBook(bookId)).called(1);
      });

      test('should return failure when book is not found', () async {
        // Arrange
        const bookId = 'non_existent_book';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Book not found')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Book not found');
      });

      test('should return failure when user has insufficient balance', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Insufficient balance')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Insufficient balance');
      });

      test('should handle network failure', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<NetworkFailure>());
      });

      test('should handle empty book ID', () async {
        // Arrange
        const emptyBookId = '';
        when(() => mockRepository.rentBook(emptyBookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid book ID')));

        // Act
        final result = await useCase(emptyBookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Invalid book ID');
      });
    });

    group('BuyBookUseCase', () {
      late BuyBookUseCase useCase;

      setUp(() {
        useCase = BuyBookUseCase(repository: mockRepository);
      });

      test('should return book when buy operation succeeds', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Right<Failure, Book>>());
        final book = result.fold((l) => null, (r) => r);
        expect(book, mockBook);
        expect(book?.id, bookId);
        verify(() => mockRepository.buyBook(bookId)).called(1);
      });

      test('should return failure when book is not available for sale', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available for sale')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book not available for sale');
      });

      test('should return failure when payment processing fails', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Payment processing failed')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Payment processing failed');
      });

      test('should handle out of stock scenario', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book is out of stock')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book is out of stock');
      });

      test('should handle concurrent purchase attempts', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final futures = List.generate(3, (_) => useCase(bookId));
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<Failure, Book>>());
        }
        verify(() => mockRepository.buyBook(bookId)).called(3);
      });
    });

    group('ReturnBookUseCase', () {
      late ReturnBookUseCase useCase;

      setUp(() {
        useCase = ReturnBookUseCase(repository: mockRepository);
      });

      test('should return updated book when book return succeeds', () async {
        // Arrange
        const bookId = 'book_123';
        final returnedBook = mockBook.copyWith(
          availability: BookAvailability(
            totalCopies: 10,
            availableForRentCount: 6, // One more available after return
            availableForSaleCount: 3,
          ),
        );
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => Right(returnedBook));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Right<Failure, Book>>());
        final book = result.fold((l) => null, (r) => r);
        expect(book, returnedBook);
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });

      test('should return failure when book was not rented by user', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not rented by user')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book not rented by user');
      });

      test('should return failure when book is already returned', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book already returned')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book already returned');
      });

      test('should return failure when book is overdue with penalties', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book is overdue - penalty applies')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Book is overdue - penalty applies');
      });

      test('should handle server error during return process', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Return processing failed')));

        // Act
        final result = await useCase(bookId);

        // Assert
        expect(result, isA<Left<Failure, Book>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Return processing failed');
      });

      test('should handle multiple return attempts gracefully', () async {
        // Arrange
        const bookId = 'book_123';
        final returnedBook = mockBook.copyWith(
          availability: BookAvailability(
            totalCopies: 10,
            availableForRentCount: 6,
            availableForSaleCount: 3,
          ),
        );
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => Right(returnedBook));

        // Act
        final result1 = await useCase(bookId);
        final result2 = await useCase(bookId);

        // Assert
        expect(result1, isA<Right<Failure, Book>>());
        expect(result2, isA<Right<Failure, Book>>());
        verify(() => mockRepository.returnBook(bookId)).called(2);
      });
    });

    group('Integration Scenarios', () {
      late RentBookUseCase rentUseCase;
      late BuyBookUseCase buyUseCase;
      late ReturnBookUseCase returnUseCase;

      setUp(() {
        rentUseCase = RentBookUseCase(repository: mockRepository);
        buyUseCase = BuyBookUseCase(repository: mockRepository);
        returnUseCase = ReturnBookUseCase(repository: mockRepository);
      });

      test('should handle rent then return workflow', () async {
        // Arrange
        const bookId = 'book_123';
        final returnedBook = mockBook.copyWith(
          availability: BookAvailability(
            totalCopies: 10,
            availableForRentCount: 6, // One more available after return
            availableForSaleCount: 3,
          ),
        );
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(mockBook));
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => Right(returnedBook));

        // Act
        final rentResult = await rentUseCase(bookId);
        final returnResult = await returnUseCase(bookId);

        // Assert
        expect(rentResult, isA<Right<Failure, Book>>());
        expect(returnResult, isA<Right<Failure, Book>>());
        verify(() => mockRepository.rentBook(bookId)).called(1);
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });

      test('should handle failed rent preventing return', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available')));
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not rented by user')));

        // Act
        final rentResult = await rentUseCase(bookId);
        final returnResult = await returnUseCase(bookId);

        // Assert
        expect(rentResult, isA<Left<Failure, Book>>());
        expect(returnResult, isA<Left<Failure, Book>>());
      });

      test('should handle concurrent operations on same book', () async {
        // Arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(mockBook));
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available for sale')));

        // Act
        final results = await Future.wait([
          rentUseCase(bookId),
          buyUseCase(bookId),
        ]);

        // Assert
        expect(results[0], isA<Right<Failure, Book>>());
        expect(results[1], isA<Left<Failure, Book>>());
      });
    });
  });
}
