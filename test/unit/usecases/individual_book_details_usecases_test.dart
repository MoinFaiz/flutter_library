import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookOperationsRepository extends Mock implements BookOperationsRepository {}

void main() {
  group('Individual Book Details Use Cases Tests', () {
    late MockBookOperationsRepository mockRepository;
    late RentBookUseCase rentBookUseCase;
    late BuyBookUseCase buyBookUseCase;
    late ReturnBookUseCase returnBookUseCase;
    late RenewBookUseCase renewBookUseCase;

    setUp(() {
      mockRepository = MockBookOperationsRepository();
      rentBookUseCase = RentBookUseCase(repository: mockRepository);
      buyBookUseCase = BuyBookUseCase(repository: mockRepository);
      returnBookUseCase = ReturnBookUseCase(repository: mockRepository);
      renewBookUseCase = RenewBookUseCase(repository: mockRepository);
    });

    final tBook = Book(
      id: 'book_123',
      title: 'Test Book',
      author: 'Test Author',
      description: 'A test book description',
      imageUrls: const ['https://example.com/book.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 9.99,
      ),
      availability: const BookAvailability(
        totalCopies: 5,
        availableForRentCount: 3,
        availableForSaleCount: 2,
      ),
      metadata: const BookMetadata(
        isbn: '978-0123456789',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Adventure'],
        pageCount: 350,
        language: 'English',
      ),
      isFavorite: false,
      isFromFriend: false,
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    group('RentBookUseCase', () {
      test('should return updated Book when rent is successful', () async {
        // arrange
        const bookId = 'book_123';
        final rentedBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 2, // One less available
            availableForSaleCount: 2,
          ),
        );
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(rentedBook));

        // act
        final result = await rentBookUseCase(bookId);

        // assert
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (book) {
            expect(book.id, equals(bookId));
            expect(book.availability.availableForRentCount, equals(2));
          },
        );
        verify(() => mockRepository.rentBook(bookId)).called(1);
      });

      test('should return ValidationFailure when book is not available for rent', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available for rent')));

        // act
        final result = await rentBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.rentBook(bookId)).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await rentBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.rentBook(bookId)).called(1);
      });
    });

    group('BuyBookUseCase', () {
      test('should return updated Book when purchase is successful', () async {
        // arrange
        const bookId = 'book_123';
        final boughtBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 3,
            availableForSaleCount: 1, // One less available
          ),
        );
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => Right(boughtBook));

        // act
        final result = await buyBookUseCase(bookId);

        // assert
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (book) {
            expect(book.id, equals(bookId));
            expect(book.availability.availableForSaleCount, equals(1));
          },
        );
        verify(() => mockRepository.buyBook(bookId)).called(1);
      });

      test('should return ValidationFailure when book is not available for sale', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book not available for sale')));

        // act
        final result = await buyBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.buyBook(bookId)).called(1);
      });

      test('should return ServerFailure when payment processing fails', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.buyBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Payment processing failed')));

        // act
        final result = await buyBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.buyBook(bookId)).called(1);
      });
    });

    group('ReturnBookUseCase', () {
      test('should return updated Book when return is successful', () async {
        // arrange
        const bookId = 'book_123';
        final returnedBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 4, // One more available
            availableForSaleCount: 2,
          ),
        );
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => Right(returnedBook));

        // act
        final result = await returnBookUseCase(bookId);

        // assert
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (book) {
            expect(book.id, equals(bookId));
            expect(book.availability.availableForRentCount, equals(4));
          },
        );
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });

      test('should return ValidationFailure when book is not currently rented by user', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book is not rented by this user')));

        // act
        final result = await returnBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });

      test('should return ServerFailure when return processing fails', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Return processing failed')));

        // act
        final result = await returnBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });
    });

    group('RenewBookUseCase', () {
      test('should return updated Book when renewal is successful', () async {
        // arrange
        const bookId = 'book_123';
        final renewedBook = tBook.copyWith(
          updatedAt: DateTime(2023, 2, 1), // Updated timestamp
        );
        when(() => mockRepository.renewBook(bookId))
            .thenAnswer((_) async => Right(renewedBook));

        // act
        final result = await renewBookUseCase(bookId);

        // assert
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (book) {
            expect(book.id, equals(bookId));
            expect(book.updatedAt, equals(DateTime(2023, 2, 1)));
          },
        );
        verify(() => mockRepository.renewBook(bookId)).called(1);
      });

      test('should return ValidationFailure when book renewal is not allowed', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.renewBook(bookId))
            .thenAnswer((_) async => const Left(ValidationFailure('Book renewal not allowed')));

        // act
        final result = await renewBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.renewBook(bookId)).called(1);
      });

      test('should return ServerFailure when renewal limit is exceeded', () async {
        // arrange
        const bookId = 'book_123';
        when(() => mockRepository.renewBook(bookId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Renewal limit exceeded')));

        // act
        final result = await renewBookUseCase(bookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected Left but got Right: $book'),
        );
        verify(() => mockRepository.renewBook(bookId)).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('should handle rent then return workflow', () async {
        // arrange
        const bookId = 'book_123';
        final rentedBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 2,
            availableForSaleCount: 2,
          ),
        );
        final returnedBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 3,
            availableForSaleCount: 2,
          ),
        );
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(rentedBook));
        when(() => mockRepository.returnBook(bookId))
            .thenAnswer((_) async => Right(returnedBook));

        // act
        final rentResult = await rentBookUseCase(bookId);
        final returnResult = await returnBookUseCase(bookId);

        // assert
        expect(rentResult, isA<Right<Failure, Book>>());
        expect(returnResult, isA<Right<Failure, Book>>());
        verify(() => mockRepository.rentBook(bookId)).called(1);
        verify(() => mockRepository.returnBook(bookId)).called(1);
      });

      test('should handle rent then renew workflow', () async {
        // arrange
        const bookId = 'book_123';
        final rentedBook = tBook.copyWith(
          availability: const BookAvailability(
            totalCopies: 5,
            availableForRentCount: 2,
            availableForSaleCount: 2,
          ),
        );
        final renewedBook = rentedBook.copyWith(
          updatedAt: DateTime(2023, 2, 1),
        );
        when(() => mockRepository.rentBook(bookId))
            .thenAnswer((_) async => Right(rentedBook));
        when(() => mockRepository.renewBook(bookId))
            .thenAnswer((_) async => Right(renewedBook));

        // act
        final rentResult = await rentBookUseCase(bookId);
        final renewResult = await renewBookUseCase(bookId);

        // assert
        expect(rentResult, isA<Right<Failure, Book>>());
        expect(renewResult, isA<Right<Failure, Book>>());
        verify(() => mockRepository.rentBook(bookId)).called(1);
        verify(() => mockRepository.renewBook(bookId)).called(1);
      });
    });
  });
}
