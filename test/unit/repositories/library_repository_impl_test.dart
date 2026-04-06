import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/library/data/repositories/library_repository_impl.dart';
import 'package:flutter_library/features/library/data/datasources/library_remote_datasource.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/constants/app_constants.dart';

class MockLibraryRemoteDataSource extends Mock implements LibraryRemoteDataSource {}

void main() {
  group('LibraryRepositoryImpl', () {
    late LibraryRepositoryImpl repository;
    late MockLibraryRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockLibraryRemoteDataSource();
      repository = LibraryRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    });

    // Helper method to create test BookModel
    BookModel createTestBookModel({
      required String id,
      required String title,
      required String author,
      String description = 'Test description',
      List<String> imageUrls = const ['https://example.com/image.jpg'],
      double rating = 4.5,
      double salePrice = 29.99,
      double rentPrice = 9.99,
      int totalCopies = 5,
      int availableForRentCount = 3,
      int availableForSaleCount = 2,
      List<String> genres = const ['Fiction'],
      int pageCount = 250,
      String language = 'English',
      AgeAppropriateness ageAppropriateness = AgeAppropriateness.adult,
      bool isFromFriend = false,
      int publishedYear = 2024,
    }) {
      return BookModel(
        id: id,
        title: title,
        author: author,
        description: description,
        imageUrls: imageUrls,
        rating: rating,
        pricing: BookPricing(
          salePrice: salePrice,
          rentPrice: rentPrice,
        ),
        availability: BookAvailability(
          totalCopies: totalCopies,
          availableForRentCount: availableForRentCount,
          availableForSaleCount: availableForSaleCount,
        ),
        metadata: BookMetadata(
          ageAppropriateness: ageAppropriateness,
          genres: genres,
          pageCount: pageCount,
          language: language,
        ),
        isFromFriend: isFromFriend,
        publishedYear: publishedYear,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final testUploadedBook1 = createTestBookModel(
      id: 'uploaded_1',
      title: 'My Uploaded Book 1',
      author: 'Test Author 1',
    );

    final testUploadedBook2 = createTestBookModel(
      id: 'uploaded_2',
      title: 'My Uploaded Book 2',
      author: 'Test Author 2',
    );

    final testBorrowedBook1 = createTestBookModel(
      id: 'borrowed_1',
      title: 'Borrowed Book 1',
      author: 'Another Author 1',
    );

    final testBorrowedBook2 = createTestBookModel(
      id: 'borrowed_2',
      title: 'Borrowed Book 2',
      author: 'Another Author 2',
    );

    group('getBorrowedBooks', () {
      test('should return list of borrowed books when remote data source call is successful', () async {
        // Arrange
        final borrowedBooks = [testBorrowedBook1, testBorrowedBook2];
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => borrowedBooks);

        // Act
        final result = await repository.getBorrowedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].id, equals('borrowed_1'));
            expect(books[1].id, equals('borrowed_2'));
          },
        );
        verify(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20)).called(1);
      });

      test('should return empty list when user has no borrowed books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getBorrowedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should use default parameters when not specified', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testBorrowedBook1]);

        // Act
        final result = await repository.getBorrowedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        verify(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20)).called(1);
      });

      test('should handle pagination correctly', () async {
        // Arrange
        final page1Books = [testBorrowedBook1];
        final page2Books = [testBorrowedBook2];

        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 5))
            .thenAnswer((_) async => page1Books);
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 2, limit: 5))
            .thenAnswer((_) async => page2Books);

        // Act
        final result1 = await repository.getBorrowedBooks(page: 1, limit: 5);
        final result2 = await repository.getBorrowedBooks(page: 2, limit: 5);

        // Assert
        expect(result1, isA<Right<Failure, List<Book>>>());
        expect(result2, isA<Right<Failure, List<Book>>>());
        
        result1.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('borrowed_1'));
          },
        );
        
        result2.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('borrowed_2'));
          },
        );
      });

      test('should return ServerFailure when remote data source throws an exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getBorrowedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains(AppConstants.failedToGetBorrowedBooksError));
            expect(failure.message, contains('Network error'));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });

      test('should return ServerFailure for various exception types', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenThrow('String error');

        // Act
        final result = await repository.getBorrowedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains(AppConstants.failedToGetBorrowedBooksError));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });
    });

    group('getUploadedBooks', () {
      test('should return list of uploaded books when remote data source call is successful', () async {
        // Arrange
        final uploadedBooks = [testUploadedBook1, testUploadedBook2];
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => uploadedBooks);

        // Act
        final result = await repository.getUploadedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].id, equals('uploaded_1'));
            expect(books[1].id, equals('uploaded_2'));
          },
        );
        verify(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20)).called(1);
      });

      test('should return empty list when user has no uploaded books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getUploadedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should use default parameters when not specified', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testUploadedBook1]);

        // Act
        final result = await repository.getUploadedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        verify(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20)).called(1);
      });

      test('should handle pagination correctly', () async {
        // Arrange
        final page1Books = [testUploadedBook1];
        final page2Books = [testUploadedBook2];

        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 5))
            .thenAnswer((_) async => page1Books);
        when(() => mockRemoteDataSource.getUploadedBooks(page: 2, limit: 5))
            .thenAnswer((_) async => page2Books);

        // Act
        final result1 = await repository.getUploadedBooks(page: 1, limit: 5);
        final result2 = await repository.getUploadedBooks(page: 2, limit: 5);

        // Assert
        expect(result1, isA<Right<Failure, List<Book>>>());
        expect(result2, isA<Right<Failure, List<Book>>>());
        
        result1.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('uploaded_1'));
          },
        );
        
        result2.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books[0].id, equals('uploaded_2'));
          },
        );
      });

      test('should return ServerFailure when remote data source throws an exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenThrow(Exception('Authentication failed'));

        // Act
        final result = await repository.getUploadedBooks(page: 1, limit: 20);

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains(AppConstants.failedToGetUploadedBooksError));
            expect(failure.message, contains('Authentication failed'));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });

      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeBookList = List.generate(100, (index) => createTestBookModel(
          id: 'book_$index',
          title: 'Book $index',
          author: 'Author $index',
        ));
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 100))
            .thenAnswer((_) async => largeBookList);

        // Act
        final result = await repository.getUploadedBooks(page: 1, limit: 100);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books.length, equals(100)),
        );
      });
    });

    group('getAllBorrowedBooks', () {
      test('should return all borrowed books when remote data source call is successful', () async {
        // Arrange
        final allBorrowedBooks = [testBorrowedBook1, testBorrowedBook2];
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => allBorrowedBooks);

        // Act
        final result = await repository.getAllBorrowedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].id, equals('borrowed_1'));
            expect(books[1].id, equals('borrowed_2'));
          },
        );
        verify(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000)).called(1);
      });

      test('should return empty list when user has no borrowed books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getAllBorrowedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeBookList = List.generate(500, (index) => createTestBookModel(
          id: 'borrowed_book_$index',
          title: 'Borrowed Book $index',
          author: 'Author $index',
        ));
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => largeBookList);

        // Act
        final result = await repository.getAllBorrowedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books.length, equals(500)),
        );
      });

      test('should return ServerFailure when remote data source throws an exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenThrow(Exception('Server timeout'));

        // Act
        final result = await repository.getAllBorrowedBooks();

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains(AppConstants.failedToGetAllBorrowedBooksError));
            expect(failure.message, contains('Server timeout'));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });

      test('should use correct limit for getting all books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllBorrowedBooks();

        // Assert
        verify(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000)).called(1);
      });
    });

    group('getAllUploadedBooks', () {
      test('should return all uploaded books when remote data source call is successful', () async {
        // Arrange
        final allUploadedBooks = [testUploadedBook1, testUploadedBook2];
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => allUploadedBooks);

        // Act
        final result = await repository.getAllUploadedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(2));
            expect(books[0].id, equals('uploaded_1'));
            expect(books[1].id, equals('uploaded_2'));
          },
        );
        verify(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000)).called(1);
      });

      test('should return empty list when user has no uploaded books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getAllUploadedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeBookList = List.generate(750, (index) => createTestBookModel(
          id: 'uploaded_book_$index',
          title: 'Uploaded Book $index',
          author: 'Author $index',
        ));
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => largeBookList);

        // Act
        final result = await repository.getAllUploadedBooks();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books.length, equals(750)),
        );
      });

      test('should return ServerFailure when remote data source throws an exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenThrow(Exception('Database connection failed'));

        // Act
        final result = await repository.getAllUploadedBooks();

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains(AppConstants.failedToGetAllUploadedBooksError));
            expect(failure.message, contains('Database connection failed'));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });

      test('should use correct limit for getting all books', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllUploadedBooks();

        // Assert
        verify(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000)).called(1);
      });
    });

    group('Integration Tests', () {
      test('should handle concurrent calls to different methods', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testBorrowedBook1]);
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testUploadedBook1]);
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => [testBorrowedBook1, testBorrowedBook2]);
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 1000))
            .thenAnswer((_) async => [testUploadedBook1, testUploadedBook2]);

        // Act
        final futures = await Future.wait([
          repository.getBorrowedBooks(),
          repository.getUploadedBooks(),
          repository.getAllBorrowedBooks(),
          repository.getAllUploadedBooks(),
        ]);

        // Assert
        expect(futures.length, equals(4));
        for (final result in futures) {
          expect(result, isA<Right<Failure, List<Book>>>());
        }
      });

      test('should maintain data integrity across different repository methods', () async {
        // Arrange
        final uploadedBooks = [testUploadedBook1, testUploadedBook2];
        final borrowedBooks = [testBorrowedBook1];

        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => uploadedBooks);
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => borrowedBooks);

        // Act
        final uploadedResult = await repository.getUploadedBooks();
        final borrowedResult = await repository.getBorrowedBooks();

        // Assert
        uploadedResult.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(2));
            expect(books.every((book) => book.id.startsWith('uploaded_')), isTrue);
          },
        );

        borrowedResult.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books.every((book) => book.id.startsWith('borrowed_')), isTrue);
          },
        );
      });

      test('should handle mixed success and failure scenarios', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testUploadedBook1]);
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20))
            .thenThrow(Exception('Network error'));

        // Act
        final uploadedResult = await repository.getUploadedBooks();
        final borrowedResult = await repository.getBorrowedBooks();

        // Assert
        expect(uploadedResult, isA<Right<Failure, List<Book>>>());
        expect(borrowedResult, isA<Left<Failure, List<Book>>>());
      });
    });

    group('Edge Cases', () {
      test('should handle null values gracefully', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenThrow(const FormatException('Null value encountered'));

        // Act
        final result = await repository.getUploadedBooks();

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
      });

      test('should handle very large page numbers', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 999999, limit: 20))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getBorrowedBooks(page: 999999, limit: 20);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle very large limit values', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 999999))
            .thenAnswer((_) async => [testUploadedBook1]);

        // Act
        final result = await repository.getUploadedBooks(page: 1, limit: 999999);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books.length, equals(1)),
        );
      });

      test('should handle zero values for pagination parameters', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: 0, limit: 0))
            .thenAnswer((_) async => <BookModel>[]);

        // Act
        final result = await repository.getBorrowedBooks(page: 0, limit: 0);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should handle timeout exceptions', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenThrow(const SocketException('Connection timeout'));

        // Act
        final result = await repository.getUploadedBooks();

        // Assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Connection timeout'));
          },
          (books) => fail('Expected Left but got Right'),
        );
      });
    });

    group('Performance Tests', () {
      test('should handle rapid consecutive calls', () async {
        // Arrange
        when(() => mockRemoteDataSource.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
            .thenAnswer((_) async => [testBorrowedBook1]);

        // Act
        final futures = List.generate(10, (_) => repository.getBorrowedBooks());
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(10));
        for (final result in results) {
          expect(result, isA<Right<Failure, List<Book>>>());
        }
        verify(() => mockRemoteDataSource.getBorrowedBooks(page: 1, limit: 20)).called(10);
      });

      test('should not cache results between calls', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => [testUploadedBook1]);

        // Act
        await repository.getUploadedBooks();
        await repository.getUploadedBooks();

        // Assert
        verify(() => mockRemoteDataSource.getUploadedBooks(page: 1, limit: 20)).called(2);
      });
    });
  });
}
