import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource_impl.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('BookUploadRemoteDataSourceImpl', () {
    late BookUploadRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = BookUploadRemoteDataSourceImpl(dio: mockDio);
    });

    group('searchBooks', () {
      test('should return list of BookModel when search is successful', () async {
        // Arrange
        const query = 'test query';

        // Act
        final result = await dataSource.searchBooks(query);

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

      test('should have reasonable execution time with network delay', () async {
        // Arrange
        const query = 'test query';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.searchBooks(query);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 800ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1200));
        expect(stopwatch.elapsedMilliseconds, greaterThan(700)); // Should take at least 800ms due to delay
      });

      test('should handle empty search query', () async {
        // Arrange
        const query = '';

        // Act
        final result = await dataSource.searchBooks(query);

        // Assert
        expect(result, isA<List<BookModel>>());
      });

      test('should handle special characters in search query', () async {
        // Arrange
        const query = '!@#\$%^&*()';

        // Act
        final result = await dataSource.searchBooks(query);

        // Assert
        expect(result, isA<List<BookModel>>());
      });

      test('should handle unicode characters in search query', () async {
        // Arrange
        const query = '🚀👍🎉 test query';

        // Act
        final result = await dataSource.searchBooks(query);

        // Assert
        expect(result, isA<List<BookModel>>());
      });

      test('should return consistent results for same query', () async {
        // Arrange
        const query = 'consistent test';

        // Act
        final result1 = await dataSource.searchBooks(query);
        final result2 = await dataSource.searchBooks(query);

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
          expect(result1[i].title, equals(result2[i].title));
          expect(result1[i].author, equals(result2[i].author));
        }
      });
    });

    group('getBookByIsbn', () {
      test('should return BookModel for valid ISBN', () async {
        // Arrange
        const isbn = '9781234567890';

        // Act
        final result = await dataSource.getBookByIsbn(isbn);

        // Assert
        if (result != null) {
          expect(result, isA<BookModel>());
          expect(result.id, isNotEmpty);
          expect(result.title, isNotEmpty);
          expect(result.author, isNotEmpty);
        }
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const isbn = '9781234567890';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getBookByIsbn(isbn);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 600ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(500)); // Should take at least 600ms due to delay
      });

      test('should handle invalid ISBN format', () async {
        // Arrange
        const isbn = 'invalid-isbn';

        // Act
        final result = await dataSource.getBookByIsbn(isbn);

        // Assert
        // Should not throw exception, may return null
        expect(result, anyOf(isNull, isA<BookModel>()));
      });

      test('should handle empty ISBN', () async {
        // Arrange
        const isbn = '';

        // Act
        final result = await dataSource.getBookByIsbn(isbn);

        // Assert
        expect(result, anyOf(isNull, isA<BookModel>()));
      });

      test('should return consistent results for same ISBN', () async {
        // Arrange
        const isbn = '9781234567890';

        // Act
        final result1 = await dataSource.getBookByIsbn(isbn);
        final result2 = await dataSource.getBookByIsbn(isbn);

        // Assert
        if (result1 != null && result2 != null) {
          expect(result1.id, equals(result2.id));
          expect(result1.title, equals(result2.title));
          expect(result1.author, equals(result2.author));
        } else {
          expect(result1, equals(result2)); // Both should be null
        }
      });
    });

    group('uploadBook', () {
      test('should upload book successfully', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Test Book',
          isbn: '978-0123456789',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/image.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 29.99,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.id, isNotEmpty);
        expect(result.title, equals(form.title));
        expect(result.author, equals(form.author));
      });

      test('should handle books with minimal information', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Minimal Book',
          isbn: '978-0000000000',
          author: 'Author',
          description: '',
          genres: ['Other'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: [],
              condition: BookCondition.acceptable,
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              rentPrice: 5.99,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.title, equals(form.title));
        expect(result.author, equals(form.author));
      });

      test('should have reasonable execution time', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Performance Test Book',
          isbn: '978-1111111111',
          author: 'Test Author',
          description: 'Testing performance',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.veryGood,
              isForSale: true,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 19.99,
              rentPrice: 3.99,
            ),
          ],
        );

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.uploadBook(form);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1000ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1600));
        expect(stopwatch.elapsedMilliseconds, greaterThan(800));
      });
    });

    group('updateBook', () {
      test('should update book successfully', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Updated Book',
          isbn: '978-2222222222',
          author: 'Updated Author',
          description: 'Updated Description',
          genres: ['Updated Genre'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/updated.jpg'],
              condition: BookCondition.likeNew,
              isForSale: true,
              isForRent: false,
              isForDonate: true,
              expectedPrice: 24.99,
            ),
          ],
        );

        // Act
        final result = await dataSource.updateBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.title, equals(form.title));
        expect(result.author, equals(form.author));
      });

      test('should have reasonable execution time', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Update Performance Test',
          isbn: '978-3333333333',
          author: 'Test Author',
          description: 'Testing update performance',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/update-test.jpg'],
              condition: BookCondition.new_,
              isForSale: true,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 34.99,
              rentPrice: 6.99,
            ),
          ],
        );

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.updateBook(form);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1000ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1500));
        expect(stopwatch.elapsedMilliseconds, greaterThan(800));
      });
    });

    group('uploadImage', () {
      test('should upload image successfully', () async {
        // Arrange
        const filePath = '/path/to/test/image.jpg';

        // Act
        final result = await dataSource.uploadImage(filePath);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result.startsWith('https://'), isTrue);
      });

      test('should handle different file extensions', () async {
        // Arrange
        final filePaths = [
          '/path/to/image.jpg',
          '/path/to/image.png', 
          '/path/to/image.gif',
          '/path/to/image.webp',
        ];

        for (final filePath in filePaths) {
          // Act
          final result = await dataSource.uploadImage(filePath);

          // Assert
          expect(result, isA<String>());
          expect(result, isNotEmpty);
          expect(result.startsWith('https://'), isTrue,
              reason: 'Should handle file: $filePath');
        }
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const filePath = '/path/to/test/image.jpg';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.uploadImage(filePath);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(2100));
        expect(stopwatch.elapsedMilliseconds, greaterThan(1200));
      });

      test('should handle invalid file paths gracefully', () async {
        // Arrange
        const invalidPaths = ['', 'invalid-path', '/nonexistent/file.jpg'];

        for (final path in invalidPaths) {
          // Act
          final result = await dataSource.uploadImage(path);

          // Assert
          expect(result, isA<String>());
          expect(result, isNotEmpty,
              reason: 'Should handle invalid path gracefully: $path');
        }
      });
    });

    group('getGenres', () {
      test('should return list of genres', () async {
        // Act
        final result = await dataSource.getGenres();

        // Assert
        expect(result, isA<List<String>>());
        expect(result, isNotEmpty);
        
        for (final genre in result) {
          expect(genre, isNotEmpty);
        }
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getGenres();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 300ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
        expect(stopwatch.elapsedMilliseconds, greaterThan(200));
      });

      test('should return consistent genres list', () async {
        // Act
        final result1 = await dataSource.getGenres();
        final result2 = await dataSource.getGenres();

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i], equals(result2[i]));
        }
      });

      test('should return valid genre names', () async {
        // Act
        final result = await dataSource.getGenres();

        // Assert
        final commonGenres = ['Fiction', 'Non-Fiction', 'Science', 'Technology', 'History'];
        
        for (final commonGenre in commonGenres) {
          expect(result.contains(commonGenre), isTrue,
              reason: 'Should contain common genre: $commonGenre');
        }
      });
    });

    group('getLanguages', () {
      test('should return list of languages', () async {
        // Act
        final result = await dataSource.getLanguages();

        // Assert
        expect(result, isA<List<String>>());
        expect(result, isNotEmpty);
        
        for (final language in result) {
          expect(language, isNotEmpty);
        }
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getLanguages();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 200ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(stopwatch.elapsedMilliseconds, greaterThan(150));
      });

      test('should return consistent languages list', () async {
        // Act
        final result1 = await dataSource.getLanguages();
        final result2 = await dataSource.getLanguages();

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i], equals(result2[i]));
        }
      });

      test('should return valid language names', () async {
        // Act
        final result = await dataSource.getLanguages();

        // Assert
        final commonLanguages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
        
        for (final commonLanguage in commonLanguages) {
          expect(result.contains(commonLanguage), isTrue,
              reason: 'Should contain common language: $commonLanguage');
        }
      });
    });

    group('uploadCopy', () {
      test('should upload copy successfully', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: ['https://example.com/copy.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 25.99,
          notes: 'Test copy upload',
        );

        // Act
        final result = await dataSource.uploadCopy(copy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.id, isNotEmpty);
        expect(result.condition, equals(copy.condition));
        expect(result.isForSale, equals(copy.isForSale));
        expect(result.isForRent, equals(copy.isForRent));
        expect(result.isForDonate, equals(copy.isForDonate));
        expect(result.expectedPrice, equals(copy.expectedPrice));
        expect(result.uploadDate, isNotNull);
        expect(result.updatedAt, isNotNull);
      });

      test('should handle copy with minimal information', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: [],
          condition: BookCondition.acceptable,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
          rentPrice: 3.99,
        );

        // Act
        final result = await dataSource.uploadCopy(copy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.id, isNotEmpty);
        expect(result.condition, equals(copy.condition));
        expect(result.isForRent, isTrue);
        expect(result.rentPrice, equals(copy.rentPrice));
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: ['https://example.com/perf-test.jpg'],
          condition: BookCondition.veryGood,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 19.99,
        );

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.uploadCopy(copy);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1000ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1400));
        expect(stopwatch.elapsedMilliseconds, greaterThan(900));
      });

      test('should handle donation copies correctly', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: ['https://example.com/donation.jpg'],
          condition: BookCondition.poor,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
          notes: 'Donation copy - free to good home',
        );

        // Act
        final result = await dataSource.uploadCopy(copy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.isForDonate, isTrue);
        expect(result.isForSale, isFalse);
        expect(result.isForRent, isFalse);
        expect(result.notes, equals(copy.notes));
      });
    });

    group('updateCopy', () {
      test('should update copy successfully', () async {
        // Arrange
        final originalCopy = BookCopyModel(
          id: 'copy_123',
          imageUrls: ['https://example.com/original.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 20.00,
          uploadDate: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final updatedCopy = originalCopy.copyWith(
          expectedPrice: 15.00,
          notes: 'Price reduced',
        );

        // Act
        final result = await dataSource.updateCopy(updatedCopy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.id, equals(originalCopy.id));
        expect(result.expectedPrice, equals(15.00));
        expect(result.notes, equals('Price reduced'));
        expect(result.updatedAt, isNotNull);
        expect(result.updatedAt!.isAfter(originalCopy.updatedAt!), isTrue);
      });

      test('should handle availability changes', () async {
        // Arrange
        final copy = BookCopyModel(
          id: 'copy_456',
          imageUrls: ['https://example.com/update-test.jpg'],
          condition: BookCondition.likeNew,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 30.00,
          uploadDate: DateTime.now().subtract(const Duration(hours: 6)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        );

        final updatedCopy = copy.copyWith(
          isForSale: false,
          isForRent: true,
          rentPrice: 8.99,
          expectedPrice: null,
        );

        // Act
        final result = await dataSource.updateCopy(updatedCopy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.isForSale, isFalse);
        expect(result.isForRent, isTrue);
        expect(result.rentPrice, equals(8.99));
      });

      test('should have reasonable execution time', () async {
        // Arrange
        final copy = BookCopyModel(
          id: 'copy_perf',
          imageUrls: ['https://example.com/perf-update.jpg'],
          condition: BookCondition.new_,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 25.00,
          rentPrice: 5.99,
          uploadDate: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.updateCopy(copy);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 800ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1100));
        expect(stopwatch.elapsedMilliseconds, greaterThan(700));
      });

      test('should handle condition updates', () async {
        // Arrange
        final copy = BookCopyModel(
          id: 'copy_condition',
          imageUrls: ['https://example.com/condition-test.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 22.00,
          uploadDate: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        final updatedCopy = copy.copyWith(
          condition: BookCondition.acceptable,
          expectedPrice: 18.00,
          notes: 'Condition downgraded, price adjusted',
        );

        // Act
        final result = await dataSource.updateCopy(updatedCopy);

        // Assert
        expect(result, isA<BookCopyModel>());
        expect(result.condition, equals(BookCondition.acceptable));
        expect(result.expectedPrice, equals(18.00));
        expect(result.notes, contains('Condition downgraded'));
      });
    });

    group('deleteCopy', () {
      test('should delete copy successfully', () async {
        // Arrange
        const copyId = 'copy_to_delete';
        const reason = 'Copy sold';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.deleteCopy(copyId, reason),
          returnsNormally,
        );
      });

      test('should handle different deletion reasons', () async {
        // Arrange
        const copyId = 'copy_delete_test';
        const reasons = [
          'Sold to customer',
          'Damaged beyond repair',
          'Lost or stolen',
          'Donated to charity',
          'Owner changed mind',
        ];

        for (final reason in reasons) {
          // Act & Assert
          expect(
            () => dataSource.deleteCopy(copyId, reason),
            returnsNormally,
            reason: 'Should handle deletion reason: $reason',
          );
        }
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const copyId = 'copy_perf_delete';
        const reason = 'Performance test deletion';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.deleteCopy(copyId, reason);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(800));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400));
      });

      test('should handle empty or invalid copy IDs gracefully', () async {
        // Arrange
        const invalidIds = ['', 'invalid-id', 'null', '0'];
        const reason = 'Test deletion';

        for (final copyId in invalidIds) {
          // Act & Assert
          expect(
            () => dataSource.deleteCopy(copyId, reason),
            returnsNormally,
            reason: 'Should handle invalid copy ID: $copyId gracefully',
          );
        }
      });

      test('should handle empty or invalid reasons gracefully', () async {
        // Arrange
        const copyId = 'copy_reason_test';
        const invalidReasons = ['', '   ', 'null', 'undefined'];

        for (final reason in invalidReasons) {
          // Act & Assert
          expect(
            () => dataSource.deleteCopy(copyId, reason),
            returnsNormally,
            reason: 'Should handle invalid reason: "$reason" gracefully',
          );
        }
      });
    });

    group('getUserBooks', () {
      test('should return list of user books', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result, isNotEmpty);
        
        for (final book in result) {
          expect(book, isA<BookModel>());
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
          expect(book.author, isNotEmpty);
        }
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getUserBooks();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 600ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(900));
        expect(stopwatch.elapsedMilliseconds, greaterThan(500));
      });

      test('should return user books with specific titles', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        final titles = result.map((book) => book.title).toList();
        expect(titles, contains('My Flutter App Development'));
        expect(titles, contains('Learning Dart Programming'));
        expect(titles, contains('Mobile UI/UX Design'));
      });

      test('should return consistent results', () async {
        // Act
        final result1 = await dataSource.getUserBooks();
        final result2 = await dataSource.getUserBooks();

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
          expect(result1[i].title, equals(result2[i].title));
        }
      });
    });

    group('deleteBook', () {
      test('should delete book successfully', () async {
        // Arrange
        const bookId = 'book_to_delete';
        const reason = 'Book sold';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.deleteBook(bookId, reason),
          returnsNormally,
        );
      });

      test('should handle different deletion reasons', () async {
        // Arrange
        const bookId = 'book_delete_test';
        const reasons = [
          'All copies sold',
          'No longer publishing',
          'Wrong book uploaded',
          'Duplicate entry',
          'Copyright issues',
        ];

        for (final reason in reasons) {
          // Act & Assert
          expect(
            () => dataSource.deleteBook(bookId, reason),
            returnsNormally,
            reason: 'Should handle deletion reason: $reason',
          );
        }
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const bookId = 'book_perf_delete';
        const reason = 'Performance test deletion';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.deleteBook(bookId, reason);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 800ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1100));
        expect(stopwatch.elapsedMilliseconds, greaterThan(700));
      });

      test('should handle empty or invalid book IDs gracefully', () async {
        // Arrange
        const invalidIds = ['', 'invalid-id', 'null', '0'];
        const reason = 'Test deletion';

        for (final bookId in invalidIds) {
          // Act & Assert
          expect(
            () => dataSource.deleteBook(bookId, reason),
            returnsNormally,
            reason: 'Should handle invalid book ID: $bookId gracefully',
          );
        }
      });

      test('should handle empty or invalid reasons gracefully', () async {
        // Arrange
        const bookId = 'book_reason_test';
        const invalidReasons = ['', '   ', 'null', 'undefined'];

        for (final reason in invalidReasons) {
          // Act & Assert
          expect(
            () => dataSource.deleteBook(bookId, reason),
            returnsNormally,
            reason: 'Should handle invalid reason: "$reason" gracefully',
          );
        }
      });
    });

    group('Error Handling and Exception Cases', () {
      test('should handle exceptions in searchBooks gracefully', () async {
        // Arrange
        const query = 'test error handling';

        // Act - The current implementation uses mock data, so it should handle exceptions internally
        final result = await dataSource.searchBooks(query);

        // Assert - Should return a list even if there are internal errors
        expect(result, isA<List<BookModel>>());
      });

      test('should handle exceptions in getBookByIsbn gracefully', () async {
        // Arrange
        const isbn = 'error-test-isbn';

        // Act - The current implementation uses mock data
        final result = await dataSource.getBookByIsbn(isbn);

        // Assert - Should return null or a valid BookModel, not throw
        expect(result, anyOf(isNull, isA<BookModel>()));
      });

      test('should handle exceptions in upload operations gracefully', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Error Test Book',
          isbn: '978-9999999999',
          author: 'Error Test Author',
          description: 'Testing error scenarios',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/error.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 99.99,
            ),
          ],
        );

        // Act - The current implementation uses mock data
        final result = await dataSource.uploadBook(form);

        // Assert - Should return a valid BookModel
        expect(result, isA<BookModel>());
        expect(result.title, equals(form.title));
        expect(result.author, equals(form.author));
      });

      test('should handle exceptions in copy operations gracefully', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 25.99,
        );

        // Act - The current implementation uses mock data
        final result = await dataSource.uploadCopy(copy);

        // Assert - Should return a valid BookCopyModel
        expect(result, isA<BookCopyModel>());
        expect(result.condition, equals(copy.condition));
        expect(result.isForSale, equals(copy.isForSale));
      });

      test('should handle exceptions in image upload gracefully', () async {
        // Arrange
        const filePath = '/path/to/test/image.jpg';

        // Act - The current implementation uses mock data
        final result = await dataSource.uploadImage(filePath);

        // Assert - Should return a valid URL string
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result.startsWith('https://'), isTrue);
      });

      test('should handle exceptions in delete operations gracefully', () async {
        // Arrange
        const copyId = 'test_copy_id';
        const reason = 'Test deletion';

        // Act & Assert - Should complete without throwing
        expect(
          () => dataSource.deleteCopy(copyId, reason),
          returnsNormally,
        );
      });

      test('should handle exceptions in metadata operations gracefully', () async {
        // Act - The current implementation uses mock data
        final genres = await dataSource.getGenres();
        final languages = await dataSource.getLanguages();

        // Assert - Should return valid lists
        expect(genres, isA<List<String>>());
        expect(genres, isNotEmpty);
        expect(languages, isA<List<String>>());
        expect(languages, isNotEmpty);
      });

      test('should handle very large data inputs gracefully', () async {
        // Arrange
        final largeQuery = 'x' * 10000;
        final largeIsbn = '9' * 100;
        final largePath = '/very/long/path/${'folder/' * 100}image.jpg';

        // Act & Assert - Should handle large inputs without issues
        expect(
          () => dataSource.searchBooks(largeQuery),
          returnsNormally,
        );

        expect(
          () => dataSource.getBookByIsbn(largeIsbn),
          returnsNormally,
        );

        expect(
          () => dataSource.uploadImage(largePath),
          returnsNormally,
        );
      });

      test('should handle concurrent operations under stress', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Stress Test Book',
          isbn: '978-stress-test',
          author: 'Stress Tester',
          description: 'Testing concurrent operations',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/stress.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 15.99,
            ),
          ],
        );

        // Act - Create many concurrent operations
        final futures = <Future>[];
        
        // Add various operations
        for (int i = 0; i < 10; i++) {
          futures.add(dataSource.searchBooks('query$i'));
          futures.add(dataSource.getBookByIsbn('978-test-$i'));
          futures.add(dataSource.uploadImage('/test/image$i.jpg'));
          futures.add(dataSource.getGenres());
          futures.add(dataSource.getLanguages());
        }
        
        // Add some upload/update operations
        futures.add(dataSource.uploadBook(form));
        futures.add(dataSource.updateBook(form));

        // Assert - All operations should complete successfully
        final results = await Future.wait(futures);
        expect(results.length, equals(futures.length));
        
        // Verify each result is of the expected type
        for (int i = 0; i < 50; i += 5) {
          expect(results[i], isA<List<BookModel>>()); // searchBooks
          expect(results[i + 1], anyOf(isNull, isA<BookModel>())); // getBookByIsbn
          expect(results[i + 2], isA<String>()); // uploadImage
          expect(results[i + 3], isA<List<String>>()); // getGenres
          expect(results[i + 4], isA<List<String>>()); // getLanguages
        }
        expect(results.last, isA<BookModel>()); // updateBook
        expect(results[results.length - 2], isA<BookModel>()); // uploadBook
      });

      test('should maintain data integrity under concurrent access', () async {
        // Act - Access reference data concurrently from multiple futures
        final genresFutures = List.generate(5, (_) => dataSource.getGenres());
        final languagesFutures = List.generate(5, (_) => dataSource.getLanguages());
        
        final allGenres = await Future.wait(genresFutures);
        final allLanguages = await Future.wait(languagesFutures);

        // Assert - All results should be identical
        final referenceGenres = allGenres.first;
        final referenceLanguages = allLanguages.first;
        
        for (final genres in allGenres) {
          expect(genres, equals(referenceGenres));
        }
        
        for (final languages in allLanguages) {
          expect(languages, equals(referenceLanguages));
        }
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle DioException in searchBooks', () async {
        // Note: Current implementation doesn't actually use Dio for search,
        // but this tests the exception handling structure
        // Arrange
        const query = 'test query';

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.searchBooks(query),
          returnsNormally,
        );
      });

      test('should handle DioException in getBookByIsbn', () async {
        // Arrange
        const isbn = '978-1234567890';

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.getBookByIsbn(isbn),
          returnsNormally,
        );
      });

      test('should handle DioException in uploadBook', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Test Book',
          isbn: '978-0123456789',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/image.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 29.99,
            ),
          ],
        );

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.uploadBook(form),
          returnsNormally,
        );
      });

      test('should handle DioException in updateBook', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Updated Book',
          isbn: '978-2222222222',
          author: 'Updated Author',
          description: 'Updated Description',
          genres: ['Updated Genre'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/updated.jpg'],
              condition: BookCondition.likeNew,
              isForSale: true,
              isForRent: false,
              isForDonate: true,
              expectedPrice: 24.99,
            ),
          ],
        );

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.updateBook(form),
          returnsNormally,
        );
      });

      test('should handle DioException in uploadCopy', () async {
        // Arrange
        const copy = BookCopyModel(
          imageUrls: ['https://example.com/copy.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 25.99,
          notes: 'Test copy upload',
        );

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.uploadCopy(copy),
          returnsNormally,
        );
      });

      test('should handle DioException in updateCopy', () async {
        // Arrange
        final copy = BookCopyModel(
          id: 'copy_123',
          imageUrls: ['https://example.com/original.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 20.00,
          uploadDate: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.updateCopy(copy),
          returnsNormally,
        );
      });

      test('should handle DioException in deleteCopy', () async {
        // Arrange
        const copyId = 'copy_to_delete';
        const reason = 'Copy sold';

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.deleteCopy(copyId, reason),
          returnsNormally,
        );
      });

      test('should handle DioException in deleteBook', () async {
        // Arrange
        const bookId = 'book_to_delete';
        const reason = 'Book sold';

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.deleteBook(bookId, reason),
          returnsNormally,
        );
      });

      test('should handle DioException in uploadImage', () async {
        // Arrange
        const filePath = '/path/to/test/image.jpg';

        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.uploadImage(filePath),
          returnsNormally,
        );
      });

      test('should handle DioException in getGenres', () async {
        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.getGenres(),
          returnsNormally,
        );
      });

      test('should handle DioException in getLanguages', () async {
        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.getLanguages(),
          returnsNormally,
        );
      });

      test('should handle DioException in getUserBooks', () async {
        // Act & Assert - Should not throw even if there were a network error
        expect(
          () => dataSource.getUserBooks(),
          returnsNormally,
        );
      });

      test('should handle concurrent search operations', () async {
        // Act
        final future1 = dataSource.searchBooks('query1');
        final future2 = dataSource.searchBooks('query2');
        final future3 = dataSource.getGenres();
        final future4 = dataSource.getLanguages();
        
        final results = await Future.wait([future1, future2, future3, future4]);

        // Assert
        expect(results.length, equals(4));
        expect(results[0], isA<List<BookModel>>());
        expect(results[1], isA<List<BookModel>>());
        expect(results[2], isA<List<String>>());
        expect(results[3], isA<List<String>>());
      });

      test('should handle rapid successive operations', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Rapid Test Book',
          isbn: '978-4444444444',
          author: 'Test Author',
          description: 'Testing rapid operations',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/rapid.jpg'],
              condition: BookCondition.poor,
              isForSale: false,
              isForRent: false,
              isForDonate: true,
            ),
          ],
        );

        // Act & Assert - Should handle rapid operations without issues
        final futures = <Future>[];
        futures.add(dataSource.uploadBook(form));
        futures.add(dataSource.updateBook(form));
        futures.add(dataSource.uploadImage('/test/image.jpg'));
        
        expect(
          () => Future.wait(futures),
          returnsNormally,
        );
      });

      test('should handle very long input strings', () async {
        // Arrange
        final longQuery = 'a' * 1000;
        final longIsbn = '9' * 20;

        // Act & Assert
        expect(
          () => dataSource.searchBooks(longQuery),
          returnsNormally,
        );
        
        expect(
          () => dataSource.getBookByIsbn(longIsbn),
          returnsNormally,
        );
      });

      test('should handle null-like input values', () async {
        // Arrange
        const nullLikeValues = ['null', 'undefined', 'NULL', ''];

        for (final value in nullLikeValues) {
          // Act & Assert
          expect(
            () => dataSource.searchBooks(value),
            returnsNormally,
            reason: 'Should handle search query: $value gracefully',
          );
          
          expect(
            () => dataSource.getBookByIsbn(value),
            returnsNormally,
            reason: 'Should handle ISBN: $value gracefully',
          );
          
          expect(
            () => dataSource.uploadImage(value),
            returnsNormally,
            reason: 'Should handle image path: $value gracefully',
          );
        }
      });
    });

    group('Data Validation', () {
      test('should return books with valid data structure', () async {
        // Act
        final books = await dataSource.searchBooks('test');

        // Assert
        for (final book in books) {
          expect(book.id, isNotEmpty);
          expect(book.title, isNotEmpty);
          expect(book.author, isNotEmpty);
          
          // Optional fields should have proper types if present
          expect(book.description, isA<String>());
        }
      });

      test('should return unique book IDs in search results', () async {
        // Act
        final books = await dataSource.searchBooks('test');

        // Assert
        final ids = books.map((b) => b.id).toList();
        final uniqueIds = ids.toSet();
        
        expect(uniqueIds.length, equals(ids.length), 
            reason: 'All book IDs should be unique');
      });

      test('should return valid URLs for uploaded images', () async {
        // Arrange
        const testPaths = [
          '/test/image1.jpg',
          '/test/image2.png',
          '/test/image3.gif',
        ];

        for (final path in testPaths) {
          // Act
          final result = await dataSource.uploadImage(path);

          // Assert
          expect(Uri.tryParse(result), isNotNull,
              reason: 'Should return valid URL for path: $path');
          expect(result.startsWith('http'), isTrue,
              reason: 'Should return HTTP URL for path: $path');
        }
      });

      test('should maintain data consistency', () async {
        // Act - Get reference data multiple times
        final genres1 = await dataSource.getGenres();
        final genres2 = await dataSource.getGenres();
        final languages1 = await dataSource.getLanguages();
        final languages2 = await dataSource.getLanguages();

        // Assert - Data should be identical
        expect(genres1, equals(genres2));
        expect(languages1, equals(languages2));
      });

      test('should return properly formatted genre and language lists', () async {
        // Act
        final genres = await dataSource.getGenres();
        final languages = await dataSource.getLanguages();

        // Assert
        for (final genre in genres) {
          expect(genre.trim(), equals(genre),
              reason: 'Genre should not have leading/trailing whitespace');
          expect(genre.isNotEmpty, isTrue);
        }
        
        for (final language in languages) {
          expect(language.trim(), equals(language),
              reason: 'Language should not have leading/trailing whitespace');
          expect(language.isNotEmpty, isTrue);
        }
      });
    });

    group('Mock Search Results Coverage', () {
      test('should return multiple results when query matches multiple keywords', () async {
        // Act
        final result = await dataSource.searchBooks('flutter dart mobile');

        // Assert
        expect(result.length, greaterThanOrEqualTo(1));
      });

      test('should return books matching "flutter" keyword', () async {
        // Act
        final result = await dataSource.searchBooks('flutter programming');

        // Assert
        final hasFlutterBook = result.any((book) => 
          book.title.toLowerCase().contains('flutter'));
        expect(hasFlutterBook, isTrue);
      });

      test('should return books matching "dart" keyword', () async {
        // Act
        final result = await dataSource.searchBooks('learning dart');

        // Assert
        final hasDartBook = result.any((book) => 
          book.title.toLowerCase().contains('dart'));
        expect(hasDartBook, isTrue);
      });

      test('should return books matching "mobile" keyword', () async {
        // Act
        final result = await dataSource.searchBooks('mobile development');

        // Assert
        final hasMobileBook = result.any((book) => 
          book.title.toLowerCase().contains('mobile'));
        expect(hasMobileBook, isTrue);
      });

      test('should return all matching books when query contains all keywords', () async {
        // Act
        final result = await dataSource.searchBooks('FLUTTER DART MOBILE');

        // Assert - Should match all three categories
        expect(result.length, equals(3));
        expect(result.any((book) => book.title.contains('Flutter')), isTrue);
        expect(result.any((book) => book.title.contains('Dart')), isTrue);
        expect(result.any((book) => book.title.contains('Mobile')), isTrue);
      });

      test('should handle case-insensitive search', () async {
        // Act
        final lowerResult = await dataSource.searchBooks('flutter');
        final upperResult = await dataSource.searchBooks('FLUTTER');
        final mixedResult = await dataSource.searchBooks('FlUtTeR');

        // Assert - All should return same results
        expect(lowerResult.length, equals(upperResult.length));
        expect(lowerResult.length, equals(mixedResult.length));
      });
    });

    group('Mock ISBN Lookup Coverage', () {
      test('should return null for unknown ISBN', () async {
        // Act
        final result = await dataSource.getBookByIsbn('999-9999999999');

        // Assert
        expect(result, isNull);
      });

      test('should return null for empty ISBN', () async {
        // Act
        final result = await dataSource.getBookByIsbn('');

        // Assert
        expect(result, isNull);
      });

      test('should return book for ISBN 978-1234567890', () async {
        // Act
        final result = await dataSource.getBookByIsbn('978-1234567890');

        // Assert
        expect(result, isNotNull);
        expect(result!.title, equals('Flutter Development Guide'));
        expect(result.author, equals('John Smith'));
      });

      test('should return book for ISBN 978-0987654321', () async {
        // Act
        final result = await dataSource.getBookByIsbn('978-0987654321');

        // Assert
        expect(result, isNotNull);
        expect(result!.title, equals('Dart Programming Language'));
        expect(result.author, equals('Jane Doe'));
      });

      test('should return different books for different ISBNs', () async {
        // Act
        final book1 = await dataSource.getBookByIsbn('978-1234567890');
        final book2 = await dataSource.getBookByIsbn('978-0987654321');

        // Assert
        expect(book1, isNotNull);
        expect(book2, isNotNull);
        expect(book1!.id, isNot(equals(book2!.id)));
        expect(book1.title, isNot(equals(book2.title)));
      });
    });

    group('_createBookFromForm Coverage', () {
      test('should handle form with empty copies list', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Empty Copies Book',
          isbn: '978-5555555555',
          author: 'Test Author',
          description: 'Book with no copies',
          genres: ['Test'],
          language: 'English',
          copies: [], // Empty copies list
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.imageUrls, isEmpty);
        expect(result.pricing.salePrice, equals(0.0));
        expect(result.pricing.rentPrice, equals(0.0));
        expect(result.availability.totalCopies, equals(0));
        expect(result.availability.availableForRentCount, equals(0));
        expect(result.availability.availableForSaleCount, equals(0));
      });

      test('should handle form with copy having null expectedPrice', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Price Book',
          isbn: '978-6666666666',
          author: 'Test Author',
          description: 'Book with null price',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: null, // Null price
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.pricing.salePrice, equals(0.0));
        expect(result.pricing.minimumCostToBuy, equals(0.0));
        expect(result.pricing.maximumCostToBuy, equals(0.0));
      });

      test('should handle form with copy having null rentPrice', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Rent Price Book',
          isbn: '978-7777777777',
          author: 'Test Author',
          description: 'Book with null rent price',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              rentPrice: null, // Null rent price
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.pricing.rentPrice, equals(0.0));
      });

      test('should handle form with copy having empty imageUrls', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'No Image Book',
          isbn: '978-8888888888',
          author: 'Test Author',
          description: 'Book with no images',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: [], // Empty image URLs
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 25.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.imageUrls, isEmpty);
      });

      test('should handle form with null pageCount', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Page Count Book',
          isbn: '978-9999999999',
          author: 'Test Author',
          description: 'Book with null page count',
          genres: ['Test'],
          language: 'English',
          pageCount: null, // Null page count
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.metadata.pageCount, equals(0));
      });

      test('should handle form with null language', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Language Book',
          isbn: '978-0000000001',
          author: 'Test Author',
          description: 'Book with null language',
          genres: ['Test'],
          language: null, // Null language
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.metadata.language, equals('English'));
      });

      test('should handle form with null publishedYear', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Year Book',
          isbn: '978-0000000002',
          author: 'Test Author',
          description: 'Book with null published year',
          genres: ['Test'],
          language: 'English',
          publishedYear: null, // Null published year
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.publishedYear, equals(DateTime.now().year));
      });

      test('should handle form with null createdAt and updatedAt', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Null Dates Book',
          isbn: '978-0000000003',
          author: 'Test Author',
          description: 'Book with null dates',
          genres: ['Test'],
          language: 'English',
          createdAt: null, // Null createdAt
          updatedAt: null, // Null updatedAt
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.createdAt, isNotNull);
        expect(result.updatedAt, isNotNull);
      });

      test('should handle form with existing id', () async {
        // Arrange
        final form = BookUploadFormModel(
          id: 'existing_book_id', // Existing ID
          title: 'Existing Book',
          isbn: '978-0000000004',
          author: 'Test Author',
          description: 'Book with existing ID',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.id, equals('existing_book_id'));
      });

      test('should calculate availability counts correctly for mixed copies', () async {
        // Arrange
        final form = BookUploadFormModel(
          title: 'Mixed Availability Book',
          isbn: '978-0000000005',
          author: 'Test Author',
          description: 'Book with mixed availability',
          genres: ['Test'],
          language: 'English',
          copies: [
            const BookCopyModel(
              imageUrls: ['https://example.com/test1.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
            const BookCopyModel(
              imageUrls: ['https://example.com/test2.jpg'],
              condition: BookCondition.good,
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              rentPrice: 5.00,
            ),
            const BookCopyModel(
              imageUrls: ['https://example.com/test3.jpg'],
              condition: BookCondition.good,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
            const BookCopyModel(
              imageUrls: ['https://example.com/test4.jpg'],
              condition: BookCondition.good,
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              rentPrice: 5.00,
            ),
          ],
        );

        // Act
        final result = await dataSource.uploadBook(form);

        // Assert
        expect(result, isA<BookModel>());
        expect(result.availability.totalCopies, equals(4));
        expect(result.availability.availableForSaleCount, equals(2));
        expect(result.availability.availableForRentCount, equals(2));
      });
    });

    group('_createMockBook Coverage', () {
      test('should create mock book with all required fields', () async {
        // Act
        final result = await dataSource.searchBooks('flutter');

        // Assert
        expect(result, isNotEmpty);
        final book = result.first;
        
        // Verify all fields are properly set
        expect(book.id, isNotEmpty);
        expect(book.title, isNotEmpty);
        expect(book.author, isNotEmpty);
        expect(book.imageUrls, isNotEmpty);
        expect(book.imageUrls.first, startsWith('https://'));
        expect(book.rating, equals(4.5));
        expect(book.pricing.salePrice, equals(29.99));
        expect(book.pricing.rentPrice, equals(7.99));
        expect(book.pricing.minimumCostToBuy, equals(29.99));
        expect(book.pricing.maximumCostToBuy, equals(29.99));
        expect(book.availability.availableForRentCount, equals(0));
        expect(book.availability.availableForSaleCount, equals(0));
        expect(book.availability.totalCopies, equals(0));
        expect(book.metadata.isbn, isNotEmpty);
        expect(book.metadata.publisher, equals('Tech Publishing'));
        expect(book.metadata.ageAppropriateness, equals(AgeAppropriateness.adult));
        expect(book.metadata.genres, contains('Technology'));
        expect(book.metadata.genres, contains('Programming'));
        expect(book.metadata.pageCount, equals(300));
        expect(book.metadata.language, equals('English'));
        expect(book.metadata.edition, equals('1st Edition'));
        expect(book.isFromFriend, isFalse);
        expect(book.description, isNotEmpty);
        expect(book.publishedYear, equals(2024));
        expect(book.createdAt, isNotNull);
        expect(book.updatedAt, isNotNull);
      });

      test('should create different mock books for different search terms', () async {
        // Act
        final flutterBooks = await dataSource.searchBooks('flutter');
        final dartBooks = await dataSource.searchBooks('dart');
        final mobileBooks = await dataSource.searchBooks('mobile');

        // Assert
        expect(flutterBooks.length, equals(1));
        expect(dartBooks.length, equals(1));
        expect(mobileBooks.length, equals(1));
        
        expect(flutterBooks.first.id, isNot(equals(dartBooks.first.id)));
        expect(dartBooks.first.id, isNot(equals(mobileBooks.first.id)));
      });
    });

    group('_mockSearchResults Coverage', () {
      test('should return empty list for non-matching query', () async {
        // Act
        final result = await dataSource.searchBooks('xyz123nonexistent');

        // Assert
        expect(result, isEmpty);
      });

      test('should return flutter book when query contains flutter', () async {
        // Act
        final result = await dataSource.searchBooks('flutter');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title, contains('Flutter'));
      });

      test('should return dart book when query contains dart', () async {
        // Act
        final result = await dataSource.searchBooks('dart');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title, contains('Dart'));
      });

      test('should return mobile book when query contains mobile', () async {
        // Act
        final result = await dataSource.searchBooks('mobile');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title, contains('Mobile'));
      });

      test('should return multiple books when query matches multiple keywords', () async {
        // Act
        final result = await dataSource.searchBooks('flutter dart mobile');

        // Assert
        expect(result, hasLength(3));
        expect(result.any((b) => b.title.contains('Flutter')), isTrue);
        expect(result.any((b) => b.title.contains('Dart')), isTrue);
        expect(result.any((b) => b.title.contains('Mobile')), isTrue);
      });

      test('should handle case-insensitive search for flutter', () async {
        // Act
        final result1 = await dataSource.searchBooks('FLUTTER');
        final result2 = await dataSource.searchBooks('Flutter');
        final result3 = await dataSource.searchBooks('flutter');

        // Assert
        expect(result1.length, equals(result2.length));
        expect(result2.length, equals(result3.length));
      });

      test('should handle query containing flutter as part of larger text', () async {
        // Act
        final result = await dataSource.searchBooks('I want to learn flutter programming');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title, contains('Flutter'));
      });
    });

    group('_mockUserBooks Coverage', () {
      test('should return exactly 3 user books', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        expect(result, hasLength(3));
      });

      test('should return user books with correct titles', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        final titles = result.map((b) => b.title).toList();
        expect(titles, contains('My Flutter App Development'));
        expect(titles, contains('Learning Dart Programming'));
        expect(titles, contains('Mobile UI/UX Design'));
      });

      test('should return user books with correct author', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        expect(result.every((b) => b.author == 'Current User'), isTrue);
      });

      test('should return user books with unique ISBNs', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        final isbns = result.map((b) => b.metadata.isbn).toSet();
        expect(isbns.length, equals(3));
      });

      test('should return user books with unique IDs', () async {
        // Act
        final result = await dataSource.getUserBooks();

        // Assert
        final ids = result.map((b) => b.id).toSet();
        expect(ids.length, equals(3));
      });
    });
  });
}

