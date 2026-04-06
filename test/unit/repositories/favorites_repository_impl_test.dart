import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/error/exceptions.dart';

class MockFavoritesRemoteDataSource extends Mock implements FavoritesRemoteDataSource {}
class MockFavoritesLocalDataSource extends Mock implements FavoritesLocalDataSource {}

void main() {
  group('FavoritesRepositoryImpl', () {
    late FavoritesRepositoryImpl repository;
    late MockFavoritesRemoteDataSource mockRemoteDataSource;
    late MockFavoritesLocalDataSource mockLocalDataSource;

    setUp(() {
      mockRemoteDataSource = MockFavoritesRemoteDataSource();
      mockLocalDataSource = MockFavoritesLocalDataSource();
      repository = FavoritesRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
      );
    });

    const tBookId = 'book_1';
    const tFavoriteIds = ['book_1', 'book_2', 'book_3'];

    group('getFavoriteBookIds', () {
      test('should return list of favorite book IDs when successful', () async {
        // arrange
        when(() => mockLocalDataSource.getFavoriteBookIds())
            .thenAnswer((_) async => tFavoriteIds);

        // act
        final result = await repository.getFavoriteBookIds();

        // assert
        verify(() => mockLocalDataSource.getFavoriteBookIds());
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (ids) => expect(ids, equals(tFavoriteIds)),
        );
      });

      test('should return CacheFailure when local data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.getFavoriteBookIds())
            .thenThrow(CacheException('Cache error'));

        // act
        final result = await repository.getFavoriteBookIds();

        // assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (ids) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when local data source throws other exception', () async {
        // arrange
        when(() => mockLocalDataSource.getFavoriteBookIds())
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.getFavoriteBookIds();

        // assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (ids) => fail('Expected failure'),
        );
      });
    });

    group('addToFavorites', () {
      test('should add to favorites successfully', () async {
        // arrange
        when(() => mockLocalDataSource.addToFavorites(tBookId))
            .thenAnswer((_) async => {});
        when(() => mockRemoteDataSource.addToFavorites(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.addToFavorites(tBookId);

        // assert
        verify(() => mockLocalDataSource.addToFavorites(tBookId));
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (_) => {}, // void result doesn't need any check
        );
      });

      test('should return CacheFailure when local data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.addToFavorites(tBookId))
            .thenThrow(CacheException('Cache error'));

        // act
        final result = await repository.addToFavorites(tBookId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when local data source throws other exception', () async {
        // arrange
        when(() => mockLocalDataSource.addToFavorites(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.addToFavorites(tBookId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should still succeed even if remote sync fails', () async {
        // arrange
        when(() => mockLocalDataSource.addToFavorites(tBookId))
            .thenAnswer((_) async => {});
        when(() => mockRemoteDataSource.addToFavorites(tBookId))
            .thenAnswer((_) async => throw Exception('Remote error'));

        // act
        final result = await repository.addToFavorites(tBookId);

        // assert - Should still succeed because local update worked
        verify(() => mockLocalDataSource.addToFavorites(tBookId));
        expect(result, isA<Right<Failure, void>>());
        
        // Give time for background sync to fail (fire and forget)
        await Future.delayed(const Duration(milliseconds: 100));
      });
    });

    group('removeFromFavorites', () {
      test('should remove from favorites successfully', () async {
        // arrange
        when(() => mockLocalDataSource.removeFromFavorites(tBookId))
            .thenAnswer((_) async => {});
        when(() => mockRemoteDataSource.removeFromFavorites(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.removeFromFavorites(tBookId);

        // assert
        verify(() => mockLocalDataSource.removeFromFavorites(tBookId));
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (_) => {}, // void result doesn't need any check
        );
      });

      test('should return CacheFailure when local data source throws CacheException', () async {
        // arrange
        when(() => mockLocalDataSource.removeFromFavorites(tBookId))
            .thenThrow(CacheException('Cache error'));

        // act
        final result = await repository.removeFromFavorites(tBookId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when local data source throws other exception', () async {
        // arrange
        when(() => mockLocalDataSource.removeFromFavorites(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.removeFromFavorites(tBookId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should still succeed even if remote sync fails', () async {
        // arrange
        when(() => mockLocalDataSource.removeFromFavorites(tBookId))
            .thenAnswer((_) async => {});
        when(() => mockRemoteDataSource.removeFromFavorites(tBookId))
            .thenAnswer((_) async => throw Exception('Remote error'));

        // act
        final result = await repository.removeFromFavorites(tBookId);

        // assert - Should still succeed because local update worked
        verify(() => mockLocalDataSource.removeFromFavorites(tBookId));
        expect(result, isA<Right<Failure, void>>());
        
        // Give time for background sync to fail (fire and forget)
        await Future.delayed(const Duration(milliseconds: 100));
      });
    });

    group('invalidateFavoritesCache', () {
      test('should invalidate cache successfully', () async {
        // arrange
        when(() => mockLocalDataSource.invalidateFavoritesCache())
            .thenAnswer((_) async => {});

        // act
        final result = await repository.invalidateFavoritesCache();

        // assert
        verify(() => mockLocalDataSource.invalidateFavoritesCache());
        expect(result, isA<Right<Failure, void>>());
      });

      test('should return failure when invalidation fails', () async {
        // arrange
        when(() => mockLocalDataSource.invalidateFavoritesCache())
            .thenThrow(CacheException('Invalidation error'));

        // act
        final result = await repository.invalidateFavoritesCache();

        // assert
        verify(() => mockLocalDataSource.invalidateFavoritesCache());
        expect(result, isA<Left<Failure, void>>());
      });

      test('should handle generic exceptions during invalidation', () async {
        // arrange
        when(() => mockLocalDataSource.invalidateFavoritesCache())
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.invalidateFavoritesCache();

        // assert
        verify(() => mockLocalDataSource.invalidateFavoritesCache());
        expect(result, isA<Left<Failure, void>>());
      });
    });

    group('isFavoritesCacheValid', () {
      test('should return true when cache is valid', () async {
        // arrange
        when(() => mockLocalDataSource.isFavoritesCacheValid())
            .thenAnswer((_) async => true);

        // act
        final result = await repository.isFavoritesCacheValid();

        // assert
        verify(() => mockLocalDataSource.isFavoritesCacheValid());
        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (isValid) => expect(isValid, isTrue),
        );
      });

      test('should return false when cache is invalid', () async {
        // arrange
        when(() => mockLocalDataSource.isFavoritesCacheValid())
            .thenAnswer((_) async => false);

        // act
        final result = await repository.isFavoritesCacheValid();

        // assert
        verify(() => mockLocalDataSource.isFavoritesCacheValid());
        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (isValid) => expect(isValid, isFalse),
        );
      });

      test('should return failure when check fails', () async {
        // arrange
        when(() => mockLocalDataSource.isFavoritesCacheValid())
            .thenThrow(CacheException('Check error'));

        // act
        final result = await repository.isFavoritesCacheValid();

        // assert
        verify(() => mockLocalDataSource.isFavoritesCacheValid());
        expect(result, isA<Left<Failure, bool>>());
      });

      test('should handle generic exceptions during cache validity check', () async {
        // arrange
        when(() => mockLocalDataSource.isFavoritesCacheValid())
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.isFavoritesCacheValid();

        // assert
        verify(() => mockLocalDataSource.isFavoritesCacheValid());
        expect(result, isA<Left<Failure, bool>>());
      });
    });

    group('Edge Cases and Additional Coverage', () {
      test('should handle multiple consecutive add operations', () async {
        // arrange
        final bookIds = ['book_1', 'book_2', 'book_3'];
        
        for (final bookId in bookIds) {
          when(() => mockLocalDataSource.addToFavorites(bookId))
              .thenAnswer((_) async => {});
          when(() => mockRemoteDataSource.addToFavorites(bookId))
              .thenAnswer((_) async => {});
        }

        // act
        final results = <Either<Failure, void>>[];
        for (final bookId in bookIds) {
          results.add(await repository.addToFavorites(bookId));
        }

        // assert
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result, isA<Right<Failure, void>>());
        }
      });

      test('should handle multiple consecutive remove operations', () async {
        // arrange
        final bookIds = ['book_1', 'book_2', 'book_3'];
        
        for (final bookId in bookIds) {
          when(() => mockLocalDataSource.removeFromFavorites(bookId))
              .thenAnswer((_) async => {});
          when(() => mockRemoteDataSource.removeFromFavorites(bookId))
              .thenAnswer((_) async => {});
        }

        // act
        final results = <Either<Failure, void>>[];
        for (final bookId in bookIds) {
          results.add(await repository.removeFromFavorites(bookId));
        }

        // assert
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result, isA<Right<Failure, void>>());
        }
      });

      test('should handle empty favorites list', () async {
        // arrange
        when(() => mockLocalDataSource.getFavoriteBookIds())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getFavoriteBookIds();

        // assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (ids) => expect(ids, isEmpty),
        );
      });

      test('should handle large favorites list', () async {
        // arrange
        final largeList = List.generate(1000, (index) => 'book_$index');
        when(() => mockLocalDataSource.getFavoriteBookIds())
            .thenAnswer((_) async => largeList);

        // act
        final result = await repository.getFavoriteBookIds();

        // assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (ids) {
            expect(ids.length, equals(1000));
            expect(ids.first, equals('book_0'));
            expect(ids.last, equals('book_999'));
          },
        );
      });

      test('should handle special characters in book IDs', () async {
        // arrange
        const specialBookId = 'book_123-abc_XYZ!@#';
        when(() => mockLocalDataSource.addToFavorites(specialBookId))
            .thenAnswer((_) async => {});
        when(() => mockRemoteDataSource.addToFavorites(specialBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.addToFavorites(specialBookId);

        // assert
        verify(() => mockLocalDataSource.addToFavorites(specialBookId));
        expect(result, isA<Right<Failure, void>>());
      });

      test('should not call remote when local add fails', () async {
        // arrange
        when(() => mockLocalDataSource.addToFavorites(tBookId))
            .thenThrow(CacheException('Cache error'));

        // act
        final result = await repository.addToFavorites(tBookId);

        // assert
        verify(() => mockLocalDataSource.addToFavorites(tBookId));
        verifyNever(() => mockRemoteDataSource.addToFavorites(tBookId));
        expect(result, isA<Left<Failure, void>>());
      });

      test('should not call remote when local remove fails', () async {
        // arrange
        when(() => mockLocalDataSource.removeFromFavorites(tBookId))
            .thenThrow(CacheException('Cache error'));

        // act
        final result = await repository.removeFromFavorites(tBookId);

        // assert
        verify(() => mockLocalDataSource.removeFromFavorites(tBookId));
        verifyNever(() => mockRemoteDataSource.removeFromFavorites(tBookId));
        expect(result, isA<Left<Failure, void>>());
      });
    });
  });
}
