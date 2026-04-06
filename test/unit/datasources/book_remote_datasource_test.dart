import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/home/data/datasources/book_remote_datasource.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('BookRemoteDataSourceImpl', () {
    late BookRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = BookRemoteDataSourceImpl(dio: mockDio);
    });

    group('getBooks', () {
      test('should return list of BookModel when request is successful', () async {
        // Act
        final result = await dataSource.getBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isNotEmpty, true);
        
        // Verify each item is a proper BookModel
        for (final book in result) {
          expect(book, isA<BookModel>());
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
        }
      });

      test('should return books with pagination', () async {
        // Act
        final page1 = await dataSource.getBooks(page: 1, limit: 5);
        final page2 = await dataSource.getBooks(page: 2, limit: 5);

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
        final result = await dataSource.getBooks(page: 999, limit: 20);

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });

      test('should have reasonable execution time with network delay', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getBooks();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1-second delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(900)); // Should take at least 1 second due to delay
      });
    });

    group('searchBooks', () {
      test('should return list of BookModel when search is successful', () async {
        // Act
        final result = await dataSource.searchBooks('flutter');

        // Assert
        expect(result, isA<List<BookModel>>());
        
        // Verify each item is a proper BookModel
        for (final book in result) {
          expect(book, isA<BookModel>());
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
        }
      });

      test('should filter books based on search query', () async {
        // Act
        final dartBooks = await dataSource.searchBooks('dart');
        final flutterBooks = await dataSource.searchBooks('flutter');

        // Assert
        expect(dartBooks, isA<List<BookModel>>());
        expect(flutterBooks, isA<List<BookModel>>());
        
        // Should return different results for different queries
        if (dartBooks.isNotEmpty && flutterBooks.isNotEmpty) {
          final dartTitles = dartBooks.map((b) => b.title.toLowerCase()).toList();
          final flutterTitles = flutterBooks.map((b) => b.title.toLowerCase()).toList();
          
          // At least some titles should contain the search term
          expect(dartTitles.any((title) => title.contains('dart')), true);
          expect(flutterTitles.any((title) => title.contains('flutter')), true);
        }
      });

      test('should return empty list for non-matching search query', () async {
        // Act
        final result = await dataSource.searchBooks('xyz_nonexistent_book_123');

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });

      test('should handle case-insensitive search', () async {
        // Act
        final lowerResult = await dataSource.searchBooks('flutter');
        final upperResult = await dataSource.searchBooks('FLUTTER');
        final mixedResult = await dataSource.searchBooks('Flutter');

        // Assert
        expect(lowerResult.length, equals(upperResult.length));
        expect(lowerResult.length, equals(mixedResult.length));
      });

      test('should have faster execution time than getBooks', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.searchBooks('test');
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400)); // Should take at least 500ms due to delay
      });
    });

    group('getBookById', () {
      test('should return BookModel when book exists', () async {
        // Act
        final result = await dataSource.getBookById('1');

        // Assert
        expect(result, isA<BookModel>());
        expect(result?.id, equals('1'));
        expect(result?.title, isNotEmpty);
      });

      test('should return null when book does not exist', () async {
        // Act
        final result = await dataSource.getBookById('999999');

        // Assert
        expect(result, isNull);
      });

      test('should return different books for different IDs', () async {
        // Act
        final book1 = await dataSource.getBookById('1');
        final book2 = await dataSource.getBookById('2');

        // Assert
        if (book1 != null && book2 != null) {
          expect(book1.id, isNot(equals(book2.id)));
          expect(book1.title, isNot(equals(book2.title)));
        }
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getBookById('1');
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 200ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty search query gracefully', () async {
        // Act
        final result = await dataSource.searchBooks('');

        // Assert
        expect(result, isA<List<BookModel>>());
        // Should return all books or empty list, but not throw
      });

      test('should handle special characters in search query', () async {
        // Act
        final result = await dataSource.searchBooks('!@#\$%^&*()');

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true); // Should return empty for special chars
      });

      test('should handle unicode characters in search query', () async {
        // Act
        final result = await dataSource.searchBooks('🚀 👍 🎉');

        // Assert
        expect(result, isA<List<BookModel>>());
        // Should handle gracefully without throwing
      });

      test('should handle very long search query', () async {
        // Arrange
        final longQuery = 'a' * 1000;

        // Act
        final result = await dataSource.searchBooks(longQuery);

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });

      test('should handle negative page numbers gracefully', () async {
        // Act
        final result = await dataSource.getBooks(page: -1, limit: 10);

        // Assert
        expect(result, isA<List<BookModel>>());
        // Should handle gracefully, likely return first page or empty
      });

      test('should handle zero or negative limit gracefully', () async {
        // Act
        final result1 = await dataSource.getBooks(page: 1, limit: 0);
        final result2 = await dataSource.getBooks(page: 1, limit: -5);

        // Assert
        expect(result1, isA<List<BookModel>>());
        expect(result2, isA<List<BookModel>>());
        // Should handle gracefully without throwing
      });
    });
  });
}
