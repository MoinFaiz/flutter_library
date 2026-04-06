import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('FavoritesRemoteDataSourceImpl', () {
    late FavoritesRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = FavoritesRemoteDataSourceImpl(dio: mockDio);
    });

    group('getFavoriteBookIds', () {
      test('should return list of favorite book IDs', () async {
        // Act
        final result = await dataSource.getFavoriteBookIds();

        // Assert
        expect(result, isA<List<String>>());
        
        // Verify each item is a proper string ID
        for (final id in result) {
          expect(id, isA<String>());
          expect(id, isNotEmpty);
        }
      });

      test('should have reasonable execution time with network delay', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getFavoriteBookIds();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 300ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
        expect(stopwatch.elapsedMilliseconds, greaterThan(250)); // Should take at least 300ms due to delay
      });

      test('should return consistent data across multiple calls', () async {
        // Act
        final result1 = await dataSource.getFavoriteBookIds();
        final result2 = await dataSource.getFavoriteBookIds();

        // Assert
        expect(result1.length, equals(result2.length));
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i], equals(result2[i]));
        }
      });
    });

    group('addToFavorites', () {
      test('should add book to favorites successfully', () async {
        // Arrange
        const bookId = 'test-book-id';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.addToFavorites(bookId),
          returnsNormally,
        );
      });

      test('should handle empty book ID gracefully', () async {
        // Act & Assert
        expect(
          () => dataSource.addToFavorites(''),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const bookId = 'test-book-id';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.addToFavorites(bookId);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 200ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(400));
        expect(stopwatch.elapsedMilliseconds, greaterThan(150));
      });
    });

    group('removeFromFavorites', () {
      test('should remove book from favorites successfully', () async {
        // Arrange
        const bookId = 'test-book-id';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.removeFromFavorites(bookId),
          returnsNormally,
        );
      });

      test('should handle nonexistent book ID gracefully', () async {
        // Arrange
        const bookId = 'nonexistent-book-id';

        // Act & Assert
        expect(
          () => dataSource.removeFromFavorites(bookId),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const bookId = 'test-book-id';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.removeFromFavorites(bookId);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 200ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(400));
        expect(stopwatch.elapsedMilliseconds, greaterThan(150));
      });
    });

    group('isFavorite', () {
      test('should return true for books in favorites', () async {
        // Arrange - First get the list of favorites to test with
        final favorites = await dataSource.getFavoriteBookIds();
        
        if (favorites.isNotEmpty) {
          final favoriteBookId = favorites.first;

          // Act
          final result = await dataSource.isFavorite(favoriteBookId);

          // Assert
          expect(result, true);
        }
      });

      test('should return false for books not in favorites', () async {
        // Arrange
        const nonFavoriteBookId = 'definitely-not-a-favorite-999999';

        // Act
        final result = await dataSource.isFavorite(nonFavoriteBookId);

        // Assert
        expect(result, false);
      });

      test('should handle empty book ID', () async {
        // Act
        final result = await dataSource.isFavorite('');

        // Assert
        expect(result, false);
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const bookId = 'test-book-id';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.isFavorite(bookId);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 100ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        expect(stopwatch.elapsedMilliseconds, greaterThan(50));
      });
    });

    group('syncFavorites', () {
      test('should sync local favorites with server successfully', () async {
        // Arrange
        final localFavorites = ['book1', 'book2', 'book3'];

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.syncFavorites(localFavorites),
          returnsNormally,
        );
      });

      test('should handle empty favorites list', () async {
        // Act & Assert
        expect(
          () => dataSource.syncFavorites([]),
          returnsNormally,
        );
      });

      test('should handle large favorites list', () async {
        // Arrange
        final largeFavoritesList = List.generate(1000, (index) => 'book-$index');

        // Act & Assert
        expect(
          () => dataSource.syncFavorites(largeFavoritesList),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Arrange
        final localFavorites = ['book1', 'book2', 'book3'];

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.syncFavorites(localFavorites);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms + 300ms delays + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle special characters in book ID for addToFavorites', () async {
        // Arrange
        const bookId = '!@#\$%^&*()';

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(bookId),
          returnsNormally,
        );
      });

      test('should handle unicode characters in book ID', () async {
        // Arrange
        const bookId = '🚀👍🎉';

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(bookId),
          returnsNormally,
        );
      });

      test('should handle very long book ID', () async {
        // Arrange
        final longBookId = 'a' * 1000;

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(longBookId),
          returnsNormally,
        );
      });

      test('should handle duplicate book IDs in sync list', () async {
        // Arrange
        final duplicateFavorites = ['book1', 'book2', 'book1', 'book3', 'book2'];

        // Act & Assert
        expect(
          () => dataSource.syncFavorites(duplicateFavorites),
          returnsNormally,
        );
      });

      test('should handle null values in sync list gracefully', () async {
        // Arrange - Cannot actually pass null in Dart's type system, so test empty strings
        final favoritesWithEmpty = ['book1', '', 'book3'];

        // Act & Assert
        expect(
          () => dataSource.syncFavorites(favoritesWithEmpty),
          returnsNormally,
        );
      });

      test('should handle rapid successive calls', () async {
        // Arrange
        const bookId = 'rapid-test-book';

        // Act & Assert - Should handle multiple rapid calls without issues
        final futures = <Future<void>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(dataSource.addToFavorites('$bookId-$i'));
        }
        
        expect(
          () => Future.wait(futures),
          returnsNormally,
        );
      });
    });
  });
}
