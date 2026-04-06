import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

void main() {
  group('RentalStatusLocalDataSource Tests', () {
    late RentalStatusLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = RentalStatusLocalDataSourceImpl();
    });

    final mockRentalStatus1 = RentalStatusModel(
      bookId: 'book_1',
      status: RentalStatusType.available,
    );

    final mockRentalStatus2 = RentalStatusModel(
      bookId: 'book_2',
      status: RentalStatusType.rented,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      rentedDate: DateTime.now().subtract(const Duration(days: 7)),
    );

    group('CachedRentalStatus', () {
      test('should not be expired when within TTL', () {
        final cached = CachedRentalStatus(
          status: mockRentalStatus1,
          cachedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ttl: const Duration(minutes: 5),
        );

        expect(cached.isExpired, isFalse);
      });

      test('should be expired when past TTL', () {
        final cached = CachedRentalStatus(
          status: mockRentalStatus1,
          cachedAt: DateTime.now().subtract(const Duration(minutes: 6)),
          ttl: const Duration(minutes: 5),
        );

        expect(cached.isExpired, isTrue);
      });

      test('should use default TTL of 5 minutes when not specified', () {
        final cached = CachedRentalStatus(
          status: mockRentalStatus1,
          cachedAt: DateTime.now(),
        );

        expect(cached.ttl, equals(const Duration(minutes: 5)));
      });
    });

    group('getCachedRentalStatus', () {
      test('should return null when cache is empty', () async {
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, isNull);
      });

      test('should return cached status when not expired', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, equals(mockRentalStatus1));
      });

      test('should return null and remove expired entry', () async {
        await dataSource.cacheRentalStatus(
          mockRentalStatus1,
          ttl: const Duration(milliseconds: 1),
        );
        
        await Future.delayed(const Duration(milliseconds: 10));
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, isNull);
      });

      test('should return null for non-existent book ID', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        final result = await dataSource.getCachedRentalStatus('non_existent_book');
        expect(result, isNull);
      });
    });

    group('cacheRentalStatus', () {
      test('should cache rental status with default TTL', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, equals(mockRentalStatus1));
      });

      test('should cache rental status with custom TTL', () async {
        await dataSource.cacheRentalStatus(
          mockRentalStatus1,
          ttl: const Duration(minutes: 10),
        );
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, equals(mockRentalStatus1));
      });

      test('should overwrite existing cache entry', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);
        
        final updatedStatus = RentalStatusModel(
          bookId: 'book_1',
          status: RentalStatusType.rented,
        );
        
        await dataSource.cacheRentalStatus(updatedStatus);
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, equals(updatedStatus));
        expect(result!.status, equals(RentalStatusType.rented));
      });

      test('should cache multiple different books', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);

        final result1 = await dataSource.getCachedRentalStatus('book_1');
        final result2 = await dataSource.getCachedRentalStatus('book_2');

        expect(result1, equals(mockRentalStatus1));
        expect(result2, equals(mockRentalStatus2));
      });
    });

    group('getCachedRentalStatusBatch', () {
      test('should return empty list when no books are cached', () async {
        final result = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_2']);
        expect(result, isEmpty);
      });

      test('should return cached statuses for valid book IDs', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);

        final result = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_2']);

        expect(result, hasLength(2));
        expect(result, containsAll([mockRentalStatus1, mockRentalStatus2]));
      });

      test('should return only valid cached statuses and ignore missing ones', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);

        final result = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_missing']);

        expect(result, hasLength(1));
        expect(result.first, equals(mockRentalStatus1));
      });

      test('should remove expired entries and not return them', () async {
        await dataSource.cacheRentalStatus(
          mockRentalStatus1,
          ttl: const Duration(milliseconds: 1),
        );
        await dataSource.cacheRentalStatus(mockRentalStatus2);
        
        await Future.delayed(const Duration(milliseconds: 10));

        final result = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_2']);

        expect(result, hasLength(1));
        expect(result.first, equals(mockRentalStatus2));
      });

      test('should handle empty book ID list', () async {
        final result = await dataSource.getCachedRentalStatusBatch([]);
        expect(result, isEmpty);
      });
    });

    group('clearCache', () {
      test('should remove all cached entries', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);

        await dataSource.clearCache();

        final result1 = await dataSource.getCachedRentalStatus('book_1');
        final result2 = await dataSource.getCachedRentalStatus('book_2');

        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('should work when cache is already empty', () async {
        await expectLater(dataSource.clearCache(), completes);
      });
    });

    group('clearCacheForBook', () {
      test('should remove cache for specific book only', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);

        await dataSource.clearCacheForBook('book_1');

        final result1 = await dataSource.getCachedRentalStatus('book_1');
        final result2 = await dataSource.getCachedRentalStatus('book_2');

        expect(result1, isNull);
        expect(result2, equals(mockRentalStatus2));
      });

      test('should work when book is not cached', () async {
        await expectLater(dataSource.clearCacheForBook('non_existent'), completes);
      });

      test('should handle empty book ID', () async {
        await expectLater(dataSource.clearCacheForBook(''), completes);
      });
    });

    group('clearExpiredCache', () {
      test('should remove only expired entries', () async {
        await dataSource.cacheRentalStatus(
          mockRentalStatus1,
          ttl: const Duration(milliseconds: 1),
        );
        await dataSource.cacheRentalStatus(mockRentalStatus2);
        
        await Future.delayed(const Duration(milliseconds: 10));

        await dataSource.clearExpiredCache();

        final result1 = await dataSource.getCachedRentalStatus('book_1');
        final result2 = await dataSource.getCachedRentalStatus('book_2');

        expect(result1, isNull);
        expect(result2, equals(mockRentalStatus2));
      });

      test('should work when no entries are expired', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(mockRentalStatus2);

        await dataSource.clearExpiredCache();

        final result1 = await dataSource.getCachedRentalStatus('book_1');
        final result2 = await dataSource.getCachedRentalStatus('book_2');

        expect(result1, equals(mockRentalStatus1));
        expect(result2, equals(mockRentalStatus2));
      });

      test('should work when cache is empty', () async {
        await expectLater(dataSource.clearExpiredCache(), completes);
      });
    });

    group('Integration Tests', () {
      test('should handle complex cache lifecycle', () async {
        await dataSource.cacheRentalStatus(mockRentalStatus1);
        await dataSource.cacheRentalStatus(
          mockRentalStatus2,
          ttl: const Duration(milliseconds: 5),
        );

        final batch1 = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_2']);
        expect(batch1, hasLength(2));

        await Future.delayed(const Duration(milliseconds: 10));

        // After delay, book_2 should be expired but book_1 should still be valid
        final batch2 = await dataSource.getCachedRentalStatusBatch(['book_1', 'book_2']);
        expect(batch2, hasLength(1));
        expect(batch2.first.bookId, equals('book_1'));

        await dataSource.clearCacheForBook('book_1');
        final result = await dataSource.getCachedRentalStatus('book_1');
        expect(result, isNull);

        final testStatus = RentalStatusModel(
          bookId: 'book_3',
          status: RentalStatusType.available,
        );
        await dataSource.cacheRentalStatus(testStatus);
        await dataSource.clearCache();
        final finalResult = await dataSource.getCachedRentalStatus('book_3');
        expect(finalResult, isNull);
      });
    });
  });
}
