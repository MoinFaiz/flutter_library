import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/library/data/datasources/library_remote_datasource_impl.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('LibraryRemoteDataSourceImpl', () {
    late LibraryRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = LibraryRemoteDataSourceImpl(dio: mockDio);
    });

    group('getBorrowedBooks', () {
      test('should return list of BookModel when request is successful', () async {
        // Act
        final result = await dataSource.getBorrowedBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        
        // Verify each item is a proper BookModel
        for (final book in result) {
          expect(book, isA<BookModel>());
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
          expect(book.author, isNotEmpty);
        }
      });

      test('should return books with pagination', () async {
        // Act
        final page1 = await dataSource.getBorrowedBooks(page: 1, limit: 5);
        final page2 = await dataSource.getBorrowedBooks(page: 2, limit: 5);

        // Assert
        expect(page1, isA<List<BookModel>>());
        expect(page2, isA<List<BookModel>>());
        expect(page1.length, lessThanOrEqualTo(5));
        expect(page2.length, lessThanOrEqualTo(5));
        
        // Books on different pages should be different (assuming enough data)
        if (page1.isNotEmpty && page2.isNotEmpty) {
          expect(page1.first.id, isNot(equals(page2.first.id)));
        }
      });

      test('should return empty list when page exceeds available data', () async {
        // Act
        final result = await dataSource.getBorrowedBooks(page: 999, limit: 20);

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });

      test('should have reasonable execution time with network delay', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getBorrowedBooks();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 800ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1200));
        expect(stopwatch.elapsedMilliseconds, greaterThan(700)); // Should take at least 800ms due to delay
      });

      test('should return consistent data structure across multiple calls', () async {
        // Act
        final result1 = await dataSource.getBorrowedBooks();
        final result2 = await dataSource.getBorrowedBooks();

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
          expect(result1[i].title, equals(result2[i].title));
          expect(result1[i].author, equals(result2[i].author));
        }
      });
    });

    group('getUploadedBooks', () {
      test('should return list of BookModel when request is successful', () async {
        // Act
        final result = await dataSource.getUploadedBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        
        // Verify each item is a proper BookModel
        for (final book in result) {
          expect(book, isA<BookModel>());
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
          expect(book.author, isNotEmpty);
        }
      });

      test('should return books with pagination', () async {
        // Act
        final page1 = await dataSource.getUploadedBooks(page: 1, limit: 5);
        final page2 = await dataSource.getUploadedBooks(page: 2, limit: 5);

        // Assert
        expect(page1, isA<List<BookModel>>());
        expect(page2, isA<List<BookModel>>());
        expect(page1.length, lessThanOrEqualTo(5));
        expect(page2.length, lessThanOrEqualTo(5));
        
        // Books on different pages should be different (assuming enough data)
        if (page1.isNotEmpty && page2.isNotEmpty) {
          expect(page1.first.id, isNot(equals(page2.first.id)));
        }
      });

      test('should return empty list when page exceeds available data', () async {
        // Act
        final result = await dataSource.getUploadedBooks(page: 999, limit: 20);

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });

      test('should have reasonable execution time with network delay', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getUploadedBooks();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 600ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(500)); // Should take at least 600ms due to delay
      });

      test('should return different data than borrowed books', () async {
        // Act
        final borrowedBooks = await dataSource.getBorrowedBooks();
        final uploadedBooks = await dataSource.getUploadedBooks();

        // Assert
        expect(borrowedBooks, isA<List<BookModel>>());
        expect(uploadedBooks, isA<List<BookModel>>());
        
        // Should return different books for different methods (in most cases)
        if (borrowedBooks.isNotEmpty && uploadedBooks.isNotEmpty) {
          final borrowedIds = borrowedBooks.map((b) => b.id).toSet();
          final uploadedIds = uploadedBooks.map((b) => b.id).toSet();
          
          // There might be some overlap, but they shouldn't be identical
          expect(borrowedIds, isNot(equals(uploadedIds)));
        }
      });
    });

    group('Pagination Edge Cases', () {
      test('should handle negative page numbers gracefully', () async {
        // Act
        final result1 = await dataSource.getBorrowedBooks(page: -1, limit: 10);
        final result2 = await dataSource.getUploadedBooks(page: -1, limit: 10);

        // Assert
        expect(result1, isA<List<BookModel>>());
        expect(result2, isA<List<BookModel>>());
        // Should handle gracefully, likely return first page or empty
      });

      test('should handle zero or negative limit gracefully', () async {
        // Act
        final result1 = await dataSource.getBorrowedBooks(page: 1, limit: 0);
        final result2 = await dataSource.getBorrowedBooks(page: 1, limit: -5);
        final result3 = await dataSource.getUploadedBooks(page: 1, limit: 0);
        final result4 = await dataSource.getUploadedBooks(page: 1, limit: -5);

        // Assert
        expect(result1, isA<List<BookModel>>());
        expect(result2, isA<List<BookModel>>());
        expect(result3, isA<List<BookModel>>());
        expect(result4, isA<List<BookModel>>());
        // Should handle gracefully without throwing
      });

      test('should handle very large page numbers', () async {
        // Act
        final result1 = await dataSource.getBorrowedBooks(page: 99999, limit: 10);
        final result2 = await dataSource.getUploadedBooks(page: 99999, limit: 10);

        // Assert
        expect(result1, isA<List<BookModel>>());
        expect(result2, isA<List<BookModel>>());
        expect(result1.isEmpty, true);
        expect(result2.isEmpty, true);
      });

      test('should handle very large limit values', () async {
        // Act
        final result1 = await dataSource.getBorrowedBooks(page: 1, limit: 10000);
        final result2 = await dataSource.getUploadedBooks(page: 1, limit: 10000);

        // Assert
        expect(result1, isA<List<BookModel>>());
        expect(result2, isA<List<BookModel>>());
        // Should handle gracefully, possibly with maximum allowed results
      });
    });

    group('Performance and Reliability', () {
      test('should handle rapid successive calls without issues', () async {
        // Act & Assert - Should handle multiple rapid calls without issues
        final futures = <Future<List<BookModel>>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(dataSource.getBorrowedBooks(page: i + 1, limit: 5));
        }
        
        final results = await Future.wait(futures);
        
        // Should complete all calls successfully
        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, isA<List<BookModel>>());
        }
      });

      test('should handle concurrent calls to different methods', () async {
        // Act
        final future1 = dataSource.getBorrowedBooks();
        final future2 = dataSource.getUploadedBooks();
        
        final results = await Future.wait([future1, future2]);

        // Assert
        expect(results.length, equals(2));
        expect(results[0], isA<List<BookModel>>());
        expect(results[1], isA<List<BookModel>>());
      });

      test('should maintain consistent performance across multiple calls', () async {
        final executionTimes = <int>[];
        
        for (int i = 0; i < 3; i++) {
          final stopwatch = Stopwatch()..start();
          await dataSource.getBorrowedBooks();
          stopwatch.stop();
          executionTimes.add(stopwatch.elapsedMilliseconds);
        }

        // All calls should have similar execution times (within reasonable variance)
        final avgTime = executionTimes.reduce((a, b) => a + b) / executionTimes.length;
        for (final time in executionTimes) {
          expect(time, lessThan(avgTime * 1.5)); // Within 50% of average
          expect(time, greaterThan(avgTime * 0.5)); // Within 50% of average
        }
      });
    });

    group('Data Integrity', () {
      test('should return books with valid book data structure', () async {
        // Act
        final borrowedBooks = await dataSource.getBorrowedBooks();
        final uploadedBooks = await dataSource.getUploadedBooks();

        // Assert
        final allBooks = [...borrowedBooks, ...uploadedBooks];
        
        for (final book in allBooks) {
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
          expect(book.author, isNotEmpty);
          expect(book.imageUrls, isNotEmpty);
          expect(book.rating, greaterThanOrEqualTo(0.0));
          expect(book.rating, lessThanOrEqualTo(5.0));
          expect(book.publishedYear, greaterThan(1000));
          expect(book.publishedYear, lessThanOrEqualTo(DateTime.now().year));
          expect(book.createdAt, isA<DateTime>());
          expect(book.updatedAt, isA<DateTime>());
        }
      });

      test('should return unique book IDs within each collection', () async {
        // Act
        final borrowedBooks = await dataSource.getBorrowedBooks(limit: 100);
        final uploadedBooks = await dataSource.getUploadedBooks(limit: 100);

        // Assert
        final borrowedIds = borrowedBooks.map((b) => b.id).toList();
        final uploadedIds = uploadedBooks.map((b) => b.id).toList();
        
        // All IDs within each collection should be unique
        expect(borrowedIds.toSet().length, equals(borrowedIds.length));
        expect(uploadedIds.toSet().length, equals(uploadedIds.length));
      });
    });
  });
}
