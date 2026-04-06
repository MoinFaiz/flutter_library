import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/home/domain/usecases/get_books_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/search_books_usecase.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookRepository extends Mock implements BookRepository {}
void main() {
  group('Home Use Cases Tests', () {
    late MockBookRepository mockBookRepository;
    late GetBooksUseCase getBooksUseCase;
    late SearchBooksUseCase searchBooksUseCase;

    setUp(() {
      mockBookRepository = MockBookRepository();
      getBooksUseCase = GetBooksUseCase(
        bookRepository: mockBookRepository,
      );
      searchBooksUseCase = SearchBooksUseCase(
        bookRepository: mockBookRepository,
      );
    });

    final tBook1 = Book(
      id: 'book_1',
      title: 'Test Book 1',
      author: 'Test Author 1',
      description: 'A test book description 1',
      imageUrls: const ['https://example.com/book1.jpg'],
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

    final tBook2 = Book(
      id: 'book_2',
      title: 'Test Book 2',
      author: 'Test Author 2',
      description: 'A test book description 2',
      imageUrls: const ['https://example.com/book2.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 7.99,
      ),
      availability: const BookAvailability(
        totalCopies: 3,
        availableForRentCount: 2,
        availableForSaleCount: 1,
      ),
      metadata: const BookMetadata(
        isbn: '978-0987654321',
        publisher: 'Another Publisher',
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Mystery', 'Thriller'],
        pageCount: 280,
        language: 'English',
      ),
      isFavorite: true,
      isFromFriend: false,
      publishedYear: 2022,
      createdAt: DateTime(2022, 1, 1),
      updatedAt: DateTime(2022, 1, 1),
    );

    final tBooksList = [tBook1, tBook2];

    group('GetBooksUseCase', () {
      test('should return list of books when repository call is successful with default parameters', () async {
        // arrange
        when(() => mockBookRepository.getBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final result = await getBooksUseCase();

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].id, equals('book_1'));
            expect(books[1].id, equals('book_2'));
          },
        );
        verify(() => mockBookRepository.getBooks(page: 1, limit: 20)).called(1);
      });

      test('should return list of books when repository call is successful with custom parameters', () async {
        // arrange
        const page = 2;
        const limit = 10;
        when(() => mockBookRepository.getBooks(page: page, limit: limit))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final result = await getBooksUseCase(page: page, limit: limit);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].title, equals('Test Book 1'));
            expect(books[1].title, equals('Test Book 2'));
          },
        );
        verify(() => mockBookRepository.getBooks(page: page, limit: limit)).called(1);
      });

      test('should return empty list when no books are available', () async {
        // arrange
        when(() => mockBookRepository.getBooks(page: 1, limit: 20))
            .thenAnswer((_) async => const Right([]));

        // act
        final result = await getBooksUseCase();

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books, isEmpty),
        );
        verify(() => mockBookRepository.getBooks(page: 1, limit: 20)).called(1);
      });

      test('should return NetworkFailure when repository call fails with network error', () async {
        // arrange
        when(() => mockBookRepository.getBooks(page: 1, limit: 20))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await getBooksUseCase();

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (books) => fail('Expected Left but got Right: $books'),
        );
        verify(() => mockBookRepository.getBooks(page: 1, limit: 20)).called(1);
      });

      test('should return ServerFailure when repository call fails with server error', () async {
        // arrange
        when(() => mockBookRepository.getBooks(page: 1, limit: 20))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await getBooksUseCase();

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (books) => fail('Expected Left but got Right: $books'),
        );
        verify(() => mockBookRepository.getBooks(page: 1, limit: 20)).called(1);
      });

      test('should handle pagination correctly', () async {
        // arrange
        const page1 = 1;
        const page2 = 2;
        const limit = 1;
        when(() => mockBookRepository.getBooks(page: page1, limit: limit))
            .thenAnswer((_) async => Right([tBook1]));
        when(() => mockBookRepository.getBooks(page: page2, limit: limit))
            .thenAnswer((_) async => Right([tBook2]));

        // act
        final result1 = await getBooksUseCase(page: page1, limit: limit);
        final result2 = await getBooksUseCase(page: page2, limit: limit);

        // assert
        expect(result1, isA<Right<Failure, List<Book>>>());
        expect(result2, isA<Right<Failure, List<Book>>>());
        
        result1.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('book_1'));
          },
        );
        
        result2.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('book_2'));
          },
        );

        verify(() => mockBookRepository.getBooks(page: page1, limit: limit)).called(1);
        verify(() => mockBookRepository.getBooks(page: page2, limit: limit)).called(1);
      });
    });

    group('SearchBooksUseCase', () {
      test('should return list of books when search is successful', () async {
        // arrange
        const query = 'Test Book';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].title, contains('Test Book'));
            expect(books[1].title, contains('Test Book'));
          },
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should return empty list when no books match the search query', () async {
        // arrange
        const query = 'Nonexistent Book';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books, isEmpty),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should handle search by author', () async {
        // arrange
        const query = 'Test Author 1';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right([tBook1]));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].author, equals('Test Author 1'));
          },
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should handle search by genre', () async {
        // arrange
        const query = 'Mystery';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right([tBook2]));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].metadata.genres, contains('Mystery'));
          },
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should return ValidationFailure when search query is empty', () async {
        // arrange
        const query = '';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(ValidationFailure('Search query cannot be empty')));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (books) => fail('Expected Left but got Right: $books'),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should return NetworkFailure when search fails with network error', () async {
        // arrange
        const query = 'Test Book';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (books) => fail('Expected Left but got Right: $books'),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should return ServerFailure when search fails with server error', () async {
        // arrange
        const query = 'Test Book';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (books) => fail('Expected Left but got Right: $books'),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should handle special characters in search query', () async {
        // arrange
        const query = 'Test "Book" & More!';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books.length, equals(2)),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should handle case-insensitive search', () async {
        // arrange
        const query = 'test book';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final result = await searchBooksUseCase(query);

        // assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books.length, equals(2)),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('should handle search then get books workflow', () async {
        // arrange
        const searchQuery = 'Fiction';
        when(() => mockBookRepository.searchBooks(searchQuery))
            .thenAnswer((_) async => Right([tBook1]));
        when(() => mockBookRepository.getBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right(tBooksList));

        // act
        final searchResult = await searchBooksUseCase(searchQuery);
        final getBooksResult = await getBooksUseCase();

        // assert
        expect(searchResult, isA<Right<Failure, List<Book>>>());
        expect(getBooksResult, isA<Right<Failure, List<Book>>>());
        
        searchResult.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books.length, equals(1)),
        );
        
        getBooksResult.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) => expect(books.length, equals(2)),
        );

        verify(() => mockBookRepository.searchBooks(searchQuery)).called(1);
        verify(() => mockBookRepository.getBooks(page: 1, limit: 20)).called(1);
      });

      test('should handle multiple searches with different queries', () async {
        // arrange
        const query1 = 'Fiction';
        const query2 = 'Mystery';
        when(() => mockBookRepository.searchBooks(query1))
            .thenAnswer((_) async => Right([tBook1]));
        when(() => mockBookRepository.searchBooks(query2))
            .thenAnswer((_) async => Right([tBook2]));

        // act
        final result1 = await searchBooksUseCase(query1);
        final result2 = await searchBooksUseCase(query2);

        // assert
        expect(result1, isA<Right<Failure, List<Book>>>());
        expect(result2, isA<Right<Failure, List<Book>>>());
        
        result1.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].metadata.genres, contains('Fiction'));
          },
        );
        
        result2.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].metadata.genres, contains('Mystery'));
          },
        );

        verify(() => mockBookRepository.searchBooks(query1)).called(1);
        verify(() => mockBookRepository.searchBooks(query2)).called(1);
      });
    });
  });
}
