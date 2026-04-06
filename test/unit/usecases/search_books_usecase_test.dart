import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/home/domain/usecases/search_books_usecase.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  group('SearchBooksUseCase Tests', () {
    late SearchBooksUseCase useCase;
    late MockBookRepository mockBookRepository;

    setUp(() {
      mockBookRepository = MockBookRepository();
      useCase = SearchBooksUseCase(bookRepository: mockBookRepository);
    });

    final mockBooks = [
      Book(
        id: '1',
        title: 'Flutter Programming',
        author: 'John Doe',
        description: 'Comprehensive guide to Flutter',
        imageUrls: const ['https://example.com/flutter.jpg'],
        rating: 4.8,
        publishedYear: 2023,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          isbn: '978-1234567890',
          publisher: 'Tech Books',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Programming', 'Technology'],
          pageCount: 400,
          language: 'English',
        ),
        pricing: const BookPricing(salePrice: 39.99, rentPrice: 9.99),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 10,
          totalCopies: 15,
        ),
      ),
      Book(
        id: '2',
        title: 'Dart Language Guide',
        author: 'Jane Smith',
        description: 'Master Dart programming language',
        imageUrls: const ['https://example.com/dart.jpg'],
        rating: 4.5,
        publishedYear: 2022,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          isbn: '978-0987654321',
          publisher: 'Dev Publications',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Programming', 'Language'],
          pageCount: 320,
          language: 'English',
        ),
        pricing: const BookPricing(salePrice: 29.99, rentPrice: 7.99),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 8,
          totalCopies: 11,
        ),
      ),
    ];

    group('Basic Search Functionality', () {
      test('should return search results when repository succeeds', () async {
        const query = 'flutter';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right(mockBooks));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) => expect(books.length, 2),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should return failure when book repository fails', () async {
        const query = 'test';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Search failed')));

        final result = await useCase(query);

        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (books) => fail('Expected failure but got success: $books'),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });
    });

    group('Search Query Variations', () {
      test('should handle empty search query', () async {
        const query = '';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle single character search query', () async {
        const query = 'f';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => Right([mockBooks[0]]));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) {
            expect(books.length, 1);
            expect(books[0].title, 'Flutter Programming');
          },
        );
      });

      test('should handle very long search query', () async {
        const query = 'this is a very long search query with multiple keywords and specific criteria';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle search query with special characters', () async {
        const query = 'C++ & C# Programming';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) => expect(books, isEmpty),
        );
      });
    });

    group('Error Handling', () {
      test('should handle network failure from book repository', () async {
        const query = 'network test';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        final result = await useCase(query);

        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (books) => fail('Expected failure but got success'),
        );
      });

      test('should handle cache failure from book repository', () async {
        const query = 'cache test';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(CacheFailure('Cache unavailable')));

        final result = await useCase(query);

        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (books) => fail('Expected failure but got success'),
        );
      });

      test('should handle unknown failure from book repository', () async {
        const query = 'unknown error test';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(UnknownFailure('Unknown error occurred')));

        final result = await useCase(query);

        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect((failure as UnknownFailure).message, 'Unknown error occurred');
          },
          (books) => fail('Expected failure but got success'),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle search with no results', () async {
        const query = 'nonexistent book title xyz123';
        when(() => mockBookRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(query);

        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (books) => expect(books, isEmpty),
        );
        verify(() => mockBookRepository.searchBooks(query)).called(1);
      });

      test('should handle concurrent search calls', () async {
        const query1 = 'flutter';
        const query2 = 'dart';
        when(() => mockBookRepository.searchBooks(query1))
            .thenAnswer((_) async => Right([mockBooks[0]]));
        when(() => mockBookRepository.searchBooks(query2))
            .thenAnswer((_) async => Right([mockBooks[1]]));

        final results = await Future.wait([useCase(query1), useCase(query2)]);

        expect(results.length, 2);
        results[0].fold(
          (failure) => fail('Expected success but got failure'),
          (books) {
            expect(books.length, 1);
            expect(books[0].title, 'Flutter Programming');
          },
        );
        results[1].fold(
          (failure) => fail('Expected success but got failure'),
          (books) {
            expect(books.length, 1);
            expect(books[0].title, 'Dart Language Guide');
          },
        );
      });
    });
  });
}