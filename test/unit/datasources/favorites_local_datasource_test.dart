import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_local_datasource.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('FavoritesLocalDataSourceImpl', () {
    late FavoritesLocalDataSourceImpl dataSource;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      dataSource = FavoritesLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
    });

    group('getFavoriteBookIds', () {
      test('should return list of favorite book IDs when data exists', () async {
        // Arrange
        final favoriteIds = ['book1', 'book2', 'book3'];
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(favoriteIds);

        // Act
        final result = await dataSource.getFavoriteBookIds();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, equals(3));
        expect(result, contains('book1'));
        expect(result, contains('book2'));
        expect(result, contains('book3'));
        verify(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS')).called(1);
      });

      test('should return empty list when no data exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getFavoriteBookIds();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.isEmpty, true);
        verify(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS')).called(1);
      });

      test('should handle empty list gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn([]);

        // Act
        final result = await dataSource.getFavoriteBookIds();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.isEmpty, true);
      });
    });

    group('saveFavoriteBookIds', () {
      test('should save favorites successfully and store timestamp', () async {
        // Arrange
        final favoritesToSave = ['book1', 'book2', 'book3'];
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.saveFavoriteBookIds(favoritesToSave);

        // Assert
        verify(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', favoritesToSave)).called(1);
        verify(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any())).called(1);
      });

      test('should handle empty list gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.saveFavoriteBookIds([]),
          returnsNormally,
        );
      });

      test('should handle duplicate book IDs', () async {
        // Arrange
        final favoritesWithDuplicates = ['book1', 'book2', 'book1', 'book3'];
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.saveFavoriteBookIds(favoritesWithDuplicates),
          returnsNormally,
        );
      });
    });

    group('isFavorite', () {
      test('should return true when book is in favorites', () async {
        // Arrange
        final favoriteIds = ['book1', 'book2', 'book3'];
        const favoriteBookId = 'book2';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(favoriteIds);

        // Act
        final result = await dataSource.isFavorite(favoriteBookId);

        // Assert
        expect(result, true);
        verify(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS')).called(1);
      });

      test('should return false when book is not in favorites', () async {
        // Arrange
        final favoriteIds = ['book1', 'book2', 'book3'];
        const nonFavoriteBookId = 'book999';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(favoriteIds);

        // Act
        final result = await dataSource.isFavorite(nonFavoriteBookId);

        // Assert
        expect(result, false);
      });

      test('should return false when no favorites exist', () async {
        // Arrange
        const bookId = 'book1';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(null);

        // Act
        final result = await dataSource.isFavorite(bookId);

        // Assert
        expect(result, false);
      });
    });

    group('addToFavorites', () {
      test('should add book to existing favorites list', () async {
        // Arrange
        final existingFavorites = ['book1', 'book2'];
        const newBookId = 'book3';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(existingFavorites);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.addToFavorites(newBookId);

        // Assert
        verify(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS')).called(1);
        verify(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', ['book1', 'book2', 'book3'])).called(1);
        verify(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any())).called(1);
      });

      test('should handle adding to empty favorites list', () async {
        // Arrange
        const newBookId = 'book1';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.addToFavorites(newBookId);

        // Assert
        verify(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', ['book1'])).called(1);
      });

      test('should not add duplicate book ID', () async {
        // Arrange
        final existingFavorites = ['book1', 'book2'];
        const duplicateBookId = 'book1';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(existingFavorites);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.addToFavorites(duplicateBookId);

        // Assert
        // Should not call setStringList since book is already in favorites
        verifyNever(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()));
        verifyNever(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()));
      });
    });

    group('removeFromFavorites', () {
      test('should remove book from existing favorites list', () async {
        // Arrange
        final existingFavorites = ['book1', 'book2', 'book3'];
        const bookIdToRemove = 'book2';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(existingFavorites);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.removeFromFavorites(bookIdToRemove);

        // Assert
        verify(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS')).called(1);
        verify(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', ['book1', 'book3'])).called(1);
        verify(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any())).called(1);
      });

      test('should handle removing from empty favorites list', () async {
        // Arrange
        const bookIdToRemove = 'book1';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.removeFromFavorites(bookIdToRemove);

        // Assert
        // Should not call setStringList since book is not in favorites
        verifyNever(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()));
        verifyNever(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()));
      });

      test('should handle removing non-existent book ID', () async {
        // Arrange
        final existingFavorites = ['book1', 'book2'];
        const nonExistentBookId = 'book999';
        
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(existingFavorites);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.removeFromFavorites(nonExistentBookId);

        // Assert
        // Should not call setStringList since book is not in favorites
        verifyNever(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()));
        verifyNever(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()));
      });
    });

    group('isFavoritesCacheValid', () {
      test('should return true when cache is within validity duration', () async {
        // Arrange
        final validTimestamp = DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP'))
            .thenReturn(validTimestamp);

        // Act
        final result = await dataSource.isFavoritesCacheValid();

        // Assert
        expect(result, true);
        verify(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP')).called(1);
      });

      test('should return false when cache is expired', () async {
        // Arrange
        final expiredTimestamp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP'))
            .thenReturn(expiredTimestamp);

        // Act
        final result = await dataSource.isFavoritesCacheValid();

        // Assert
        expect(result, false);
      });

      test('should return false when no timestamp exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP'))
            .thenReturn(null);

        // Act
        final result = await dataSource.isFavoritesCacheValid();

        // Assert
        expect(result, false);
      });
    });

    group('invalidateFavoritesCache', () {
      test('should remove favorites and timestamp', () async {
        // Arrange
        when(() => mockSharedPreferences.remove('FAVORITE_BOOK_IDS'))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.remove('FAVORITES_TIMESTAMP'))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.invalidateFavoritesCache();

        // Assert
        verify(() => mockSharedPreferences.remove('FAVORITE_BOOK_IDS')).called(1);
        verify(() => mockSharedPreferences.remove('FAVORITES_TIMESTAMP')).called(1);
      });
    });

    group('getLastFavoritesCacheTime', () {
      test('should return DateTime when timestamp exists', () async {
        // Arrange
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP'))
            .thenReturn(timestamp);

        // Act
        final result = await dataSource.getLastFavoritesCacheTime();

        // Assert
        expect(result, isA<DateTime>());
        expect(result?.millisecondsSinceEpoch, equals(timestamp));
      });

      test('should return null when no timestamp exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt('FAVORITES_TIMESTAMP'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getLastFavoritesCacheTime();

        // Assert
        expect(result, isNull);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle SharedPreferences errors gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenThrow(Exception('SharedPreferences error'));

        // Act & Assert
        expect(
          () => dataSource.getFavoriteBookIds(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle setStringList failure gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn(['book1']);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenThrow(Exception('Failed to save'));
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.addToFavorites('book2'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle special characters in book IDs', () async {
        // Arrange
        const specialBookId = '!@#\$%^&*()';
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn([]);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(specialBookId),
          returnsNormally,
        );
      });

      test('should handle unicode characters in book IDs', () async {
        // Arrange
        const unicodeBookId = '🚀👍🎉';
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn([]);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(unicodeBookId),
          returnsNormally,
        );
      });

      test('should handle very long book IDs', () async {
        // Arrange
        final longBookId = 'a' * 1000;
        when(() => mockSharedPreferences.getStringList('FAVORITE_BOOK_IDS'))
            .thenReturn([]);
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.addToFavorites(longBookId),
          returnsNormally,
        );
      });

      test('should handle large number of favorites gracefully', () async {
        // Arrange
        final largeFavoritesList = List.generate(1000, (index) => 'book-$index');
        when(() => mockSharedPreferences.setStringList('FAVORITE_BOOK_IDS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('FAVORITES_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.saveFavoriteBookIds(largeFavoritesList),
          returnsNormally,
        );
      });
    });
  });
}
