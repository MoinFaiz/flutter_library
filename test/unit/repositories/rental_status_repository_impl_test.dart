import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/data/repositories/rental_status_repository_impl.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

class MockRentalStatusRemoteDataSource extends Mock implements RentalStatusRemoteDataSource {}
class MockRentalStatusLocalDataSource extends Mock implements RentalStatusLocalDataSource {}

class FakeRentalStatusModel extends Fake implements RentalStatusModel {}

void main() {
  late RentalStatusRepositoryImpl repository;
  late MockRentalStatusRemoteDataSource mockRemoteDataSource;
  late MockRentalStatusLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeRentalStatusModel());
  });

  setUp(() {
    mockRemoteDataSource = MockRentalStatusRemoteDataSource();
    mockLocalDataSource = MockRentalStatusLocalDataSource();
    repository = RentalStatusRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final testBookId = 'book123';
  final testRentalStatus = RentalStatusModel(
    bookId: testBookId,
    status: RentalStatusType.rented,
    dueDate: DateTime.now().add(Duration(days: 7)),
    rentedDate: DateTime.now().subtract(Duration(days: 3)),
    daysRemaining: 7,
    canRenew: true,
    isInCart: false,
    isPurchased: false,
  );

  group('RentalStatusRepositoryImpl', () {
    group('getRentalStatus', () {
      test('should return rental status from cache when available', () async {
        // arrange
        when(() => mockLocalDataSource.clearExpiredCache()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedRentalStatus(testBookId))
            .thenAnswer((_) async => testRentalStatus);

        // act
        final result = await repository.getRentalStatus(testBookId);

        // assert
        expect(result, equals(Right(testRentalStatus)));
        verify(() => mockLocalDataSource.clearExpiredCache()).called(1);
        verify(() => mockLocalDataSource.getCachedRentalStatus(testBookId)).called(1);
        verifyNever(() => mockRemoteDataSource.getRentalStatus(any()));
      });

      test('should fetch from remote when not in cache and cache result', () async {
        // arrange
        when(() => mockLocalDataSource.clearExpiredCache()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedRentalStatus(testBookId))
            .thenAnswer((_) async => null);
        when(() => mockRemoteDataSource.getRentalStatus(testBookId))
            .thenAnswer((_) async => testRentalStatus);
        when(() => mockLocalDataSource.cacheRentalStatus(
              testRentalStatus,
              ttl: any(named: 'ttl'),
            )).thenAnswer((_) async {});

        // act
        final result = await repository.getRentalStatus(testBookId);

        // assert
        expect(result, equals(Right(testRentalStatus)));
        verify(() => mockLocalDataSource.clearExpiredCache()).called(1);
        verify(() => mockLocalDataSource.getCachedRentalStatus(testBookId)).called(1);
        verify(() => mockRemoteDataSource.getRentalStatus(testBookId)).called(1);
        verify(() => mockLocalDataSource.cacheRentalStatus(
              testRentalStatus,
              ttl: any(named: 'ttl'),
            )).called(1);
      });

      test('should return failure when exception occurs', () async {
        // arrange
        when(() => mockLocalDataSource.clearExpiredCache()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedRentalStatus(testBookId))
            .thenThrow(Exception('Cache error'));

        // act
        final result = await repository.getRentalStatus(testBookId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('getRentalStatusBatch', () {
      test('should return empty list for empty input', () async {
        // act
        final result = await repository.getRentalStatusBatch([]);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (statuses) => expect(statuses, isEmpty),
        );
        verifyNever(() => mockLocalDataSource.clearExpiredCache());
      });

      test('should return cached and fetch missing statuses', () async {
        // arrange
        final bookIds = ['book123', 'book2']; // Only 2 books for simplicity
        final cachedStatus = [testRentalStatus]; // book123 cached
        final remoteStatus = [
          RentalStatusModel(
            bookId: 'book2',
            status: RentalStatusType.available,
            canRenew: false,
            isInCart: false,
            isPurchased: false,
          ),
        ];

        when(() => mockLocalDataSource.clearExpiredCache()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedRentalStatusBatch(bookIds))
            .thenAnswer((_) async => cachedStatus);
        when(() => mockRemoteDataSource.getRentalStatusBatch(['book2']))
            .thenAnswer((_) async => remoteStatus);
        when(() => mockLocalDataSource.cacheRentalStatus(
              any(),
              ttl: any(named: 'ttl'),
            )).thenAnswer((_) async {});

        // act
        final result = await repository.getRentalStatusBatch(bookIds);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (statuses) => expect(statuses.length, equals(2)),
        );
        verify(() => mockLocalDataSource.clearExpiredCache()).called(1);
        verify(() => mockLocalDataSource.getCachedRentalStatusBatch(bookIds)).called(1);
        verify(() => mockRemoteDataSource.getRentalStatusBatch(['book2'])).called(1);
      });
    });

    group('updateRentalStatus', () {
      test('should update rental status and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.updateRentalStatus(any()))
            .thenAnswer((_) async => testRentalStatus);
        when(() => mockLocalDataSource.clearCacheForBook(testBookId))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheRentalStatus(
              testRentalStatus,
              ttl: any(named: 'ttl'),
            )).thenAnswer((_) async {});

        // act
        final result = await repository.updateRentalStatus(testRentalStatus);

        // assert
        expect(result, equals(Right(testRentalStatus)));
        verify(() => mockRemoteDataSource.updateRentalStatus(any())).called(1);
        verify(() => mockLocalDataSource.clearCacheForBook(testBookId)).called(1);
        verify(() => mockLocalDataSource.cacheRentalStatus(
              testRentalStatus,
              ttl: any(named: 'ttl'),
            )).called(1);
      });

      test('should return failure when update fails', () async {
        // arrange
        when(() => mockRemoteDataSource.updateRentalStatus(any()))
            .thenThrow(Exception('Update failed'));

        // act
        final result = await repository.updateRentalStatus(testRentalStatus);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('cache management', () {
      test('should invalidate cache for specific book', () async {
        // arrange
        when(() => mockLocalDataSource.clearCacheForBook(testBookId))
            .thenAnswer((_) async {});

        // act
        await repository.invalidateCacheForBook(testBookId);

        // assert
        verify(() => mockLocalDataSource.clearCacheForBook(testBookId)).called(1);
      });

      test('should invalidate all cache', () async {
        // arrange
        when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {});

        // act
        await repository.invalidateAllCache();

        // assert
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });
    });
  });
}
