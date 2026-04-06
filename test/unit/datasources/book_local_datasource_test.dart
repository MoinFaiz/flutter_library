import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/home/data/datasources/book_local_datasource.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/core/error/exceptions.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('BookLocalDataSourceImpl', () {
    late BookLocalDataSourceImpl dataSource;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      dataSource = BookLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
    });

    group('getCachedBooks', () {
      test('should return list of BookModel from cache when cache exists', () async {
        // Arrange
        const jsonString = '''[{
          "id": "1", 
          "title": "Test Book", 
          "author": "Test Author",
          "imageUrls": ["url1"],
          "rating": 4.5,
          "pricing": {"salePrice": 10.0, "rentPrice": 5.0},
          "availability": {"totalCopies": 10, "availableCopies": 5},
          "metadata": {"isbn": "1234567890", "publisher": "Test Publisher", "genres": ["Fiction"], "language": "English", "pageCount": 200, "publishedYear": 2024},
          "isFromFriend": false,
          "isFavorite": false,
          "description": "Test description",
          "publishedYear": 2024,
          "createdAt": "2024-01-01T00:00:00.000Z",
          "updatedAt": "2024-01-01T00:00:00.000Z"
        }]''';
        
        when(() => mockSharedPreferences.getString('CACHED_BOOKS'))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
        expect(result.first.title, equals('Test Book'));
        verify(() => mockSharedPreferences.getString('CACHED_BOOKS')).called(1);
      });

      test('should throw CacheException when no cache exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('CACHED_BOOKS'))
            .thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.getCachedBooks(),
          throwsA(isA<CacheException>()),
        );
        verify(() => mockSharedPreferences.getString('CACHED_BOOKS')).called(1);
      });

      test('should handle empty cache gracefully', () async {
        // Arrange
        const jsonString = '[]';
        when(() => mockSharedPreferences.getString('CACHED_BOOKS'))
            .thenReturn(jsonString);

        // Act
        final result = await dataSource.getCachedBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.isEmpty, true);
      });
    });

    group('cacheBooks', () {
      test('should cache books successfully and store timestamp', () async {
        // Arrange
        final booksToCache = <BookModel>[];
        when(() => mockSharedPreferences.setString('CACHED_BOOKS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('CACHE_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheBooks(booksToCache);

        // Assert
        verify(() => mockSharedPreferences.setString('CACHED_BOOKS', any())).called(1);
        verify(() => mockSharedPreferences.setInt('CACHE_TIMESTAMP', any())).called(1);
      });

      test('should handle empty list gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.setString('CACHED_BOOKS', any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.setInt('CACHE_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.cacheBooks([]),
          returnsNormally,
        );
      });
    });

    group('isCacheValid', () {
      test('should return true when cache is within validity duration', () async {
        // Arrange
        final validTimestamp = DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP'))
            .thenReturn(validTimestamp);

        // Act
        final result = await dataSource.isCacheValid();

        // Assert
        expect(result, true);
        verify(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP')).called(1);
      });

      test('should return false when cache is expired', () async {
        // Arrange
        final expiredTimestamp = DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP'))
            .thenReturn(expiredTimestamp);

        // Act
        final result = await dataSource.isCacheValid();

        // Assert
        expect(result, false);
      });

      test('should return false when no timestamp exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP'))
            .thenReturn(null);

        // Act
        final result = await dataSource.isCacheValid();

        // Assert
        expect(result, false);
      });
    });

    group('invalidateCache', () {
      test('should remove cached books and timestamp', () async {
        // Arrange
        when(() => mockSharedPreferences.remove('CACHED_BOOKS'))
            .thenAnswer((_) async => true);
        when(() => mockSharedPreferences.remove('CACHE_TIMESTAMP'))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.invalidateCache();

        // Assert
        verify(() => mockSharedPreferences.remove('CACHED_BOOKS')).called(1);
        verify(() => mockSharedPreferences.remove('CACHE_TIMESTAMP')).called(1);
      });
    });

    group('getLastCacheTime', () {
      test('should return DateTime when timestamp exists', () async {
        // Arrange
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        when(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP'))
            .thenReturn(timestamp);

        // Act
        final result = await dataSource.getLastCacheTime();

        // Assert
        expect(result, isA<DateTime>());
        expect(result?.millisecondsSinceEpoch, equals(timestamp));
      });

      test('should return null when no timestamp exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getInt('CACHE_TIMESTAMP'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getLastCacheTime();

        // Assert
        expect(result, isNull);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle corrupted cache data gracefully', () async {
        // Arrange
        const corruptedJson = 'invalid_json_data';
        when(() => mockSharedPreferences.getString('CACHED_BOOKS'))
            .thenReturn(corruptedJson);

        // Act & Assert
        expect(
          () => dataSource.getCachedBooks(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle SharedPreferences errors gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('CACHED_BOOKS'))
            .thenThrow(Exception('SharedPreferences error'));

        // Act & Assert
        expect(
          () => dataSource.getCachedBooks(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle setString failure gracefully', () async {
        // Arrange
        when(() => mockSharedPreferences.setString('CACHED_BOOKS', any()))
            .thenThrow(Exception('Failed to save'));
        when(() => mockSharedPreferences.setInt('CACHE_TIMESTAMP', any()))
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => dataSource.cacheBooks([]),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
