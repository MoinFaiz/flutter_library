import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/search_books_for_upload_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookUploadRepository extends Mock implements BookUploadRepository {}

void main() {
  group('SearchBooksForUploadUseCase (Book Upload) Tests', () {
    late SearchBooksForUploadUseCase useCase;
    late MockBookUploadRepository mockRepository;

    setUp(() {
      mockRepository = MockBookUploadRepository();
      useCase = SearchBooksForUploadUseCase(repository: mockRepository);
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
          edition: '1st Edition',
        ),
        pricing: const BookPricing(
          salePrice: 29.99,
          rentPrice: 9.99,
          discountedRentPrice: 8.99,
        ),
        availability: const BookAvailability(
          totalCopies: 10,
          availableForRentCount: 8,
          availableForSaleCount: 5,
        ),
      ),
    ];

    group('Successful Search', () {
      test('should return books when search is successful', () async {
        // Arrange
        const query = 'Flutter';
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => Right(mockBooks));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(Right(mockBooks)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should return empty list when no books found', () async {
        // Arrange
        const query = 'Nonexistent Book';
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((l) => null, (r) => r), isEmpty);
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should trim query string before searching', () async {
        // Arrange
        const query = '  Flutter  ';
        const trimmedQuery = 'Flutter';
        when(() => mockRepository.searchBooks(trimmedQuery))
            .thenAnswer((_) async => Right(mockBooks));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(Right(mockBooks)));
        verify(() => mockRepository.searchBooks(trimmedQuery)).called(1);
      });
    });

    group('Empty Query Handling', () {
      test('should return empty list when query is empty', () async {
        // Arrange
        const query = '';

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((l) => null, (r) => r), isEmpty);
        verifyNever(() => mockRepository.searchBooks(any()));
      });

      test('should return empty list when query is only whitespace', () async {
        // Arrange
        const query = '   ';

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((l) => null, (r) => r), isEmpty);
        verifyNever(() => mockRepository.searchBooks(any()));
      });

      test('should return empty list when query is tabs and spaces', () async {
        // Arrange
        const query = '\t  \n  ';

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((l) => null, (r) => r), isEmpty);
        verifyNever(() => mockRepository.searchBooks(any()));
      });
    });

    group('Error Handling', () {
      test('should return ServerFailure when repository fails', () async {
        // Arrange
        const query = 'Flutter';
        const failure = ServerFailure(message: 'Network error');
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should return CacheFailure when repository fails with cache error', () async {
        // Arrange
        const query = 'Flutter';
        const failure = CacheFailure('Cache not available');
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should propagate any failure from repository', () async {
        // Arrange
        const query = 'Flutter';
        const failure = ServerFailure(message: 'Unknown error');
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });
    });

    group('Special Characters and Input Validation', () {
      test('should handle query with special characters', () async {
        // Arrange
        const query = 'C++ Programming & Design';
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => Right(mockBooks));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(Right(mockBooks)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should handle query with numbers', () async {
        // Arrange
        const query = 'Programming 101';
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => Right(mockBooks));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(Right(mockBooks)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should handle ISBN queries', () async {
        // Arrange
        const query = '978-1234567890';
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => Right(mockBooks));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, equals(Right(mockBooks)));
        verify(() => mockRepository.searchBooks(query)).called(1);
      });

      test('should handle very long queries', () async {
        // Arrange
        final query = 'A' * 1000; // Very long string
        when(() => mockRepository.searchBooks(query))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase.call(query);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((l) => null, (r) => r), isEmpty);
        verify(() => mockRepository.searchBooks(query)).called(1);
      });
    });
  });
}
