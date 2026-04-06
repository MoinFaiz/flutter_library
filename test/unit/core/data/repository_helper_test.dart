import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/data/repository_helper.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/error/exceptions.dart';

void main() {
  group('RepositoryHelper Tests', () {
    group('handleCachedFetch', () {
      test('should return cached data when cache is valid', () async {
        // Arrange
        final cachedData = ['cached1', 'cached2'];
        final remoteData = ['remote1', 'remote2'];
        var cacheDataCalled = false;

        Future<bool> isCacheValid() async => true;
        Future<List<String>> getCachedData() async => cachedData;
        Future<List<String>> getRemoteData() async => remoteData;
        Future<void> cacheData(List<String> data) async => cacheDataCalled = true;

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (_) => fail('Should return cached data'),
          (data) => expect(data, equals(cachedData)),
        );
        expect(cacheDataCalled, isFalse);
      });

      test('should fetch remote data when cache is invalid', () async {
        // Arrange
        final cachedData = ['cached1', 'cached2'];
        final remoteData = ['remote1', 'remote2'];
        var cacheDataCalled = false;
        var getCachedDataCalled = false;

        Future<bool> isCacheValid() async => false;
        Future<List<String>> getCachedData() async {
          getCachedDataCalled = true;
          return cachedData;
        }
        Future<List<String>> getRemoteData() async => remoteData;
        Future<void> cacheData(List<String> data) async => cacheDataCalled = true;

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (_) => fail('Should return remote data'),
          (data) => expect(data, equals(remoteData)),
        );
        expect(cacheDataCalled, isTrue);
        expect(getCachedDataCalled, isFalse);
      });

      test('should fetch remote data when cached data retrieval fails', () async {
        // Arrange
        final remoteData = ['remote1', 'remote2'];
        var cacheDataCalled = false;

        Future<bool> isCacheValid() async => true;
        Future<List<String>> getCachedData() async => throw Exception('Cache read failed');
        Future<List<String>> getRemoteData() async => remoteData;
        Future<void> cacheData(List<String> data) async => cacheDataCalled = true;

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (_) => fail('Should return remote data'),
          (data) => expect(data, equals(remoteData)),
        );
        expect(cacheDataCalled, isTrue);
      });

      test('should return failure when remote data fetch fails', () async {
        // Arrange
        Future<bool> isCacheValid() async => false;
        Future<List<String>> getCachedData() async => ['cached'];
        Future<List<String>> getRemoteData() async => throw const ServerException('Remote failed');
        Future<void> cacheData(List<String> data) async {}

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should handle cache data operation failure gracefully', () async {
        // Arrange
        final remoteData = ['remote1', 'remote2'];

        Future<bool> isCacheValid() async => false;
        Future<List<String>> getCachedData() async => ['cached'];
        Future<List<String>> getRemoteData() async => remoteData;
        Future<void> cacheData(List<String> data) async => throw Exception('Cache write failed');

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert - Should still succeed even if caching fails
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Should return failure due to cache write error'),
        );
      });

      test('should handle different data types', () async {
        // Arrange
        final intData = [1, 2, 3];

        Future<bool> isCacheValid() async => true;
        Future<List<int>> getCachedData() async => intData;
        Future<List<int>> getRemoteData() async => [4, 5, 6];
        Future<void> cacheData(List<int> data) async {}

        // Act
        final result = await RepositoryHelper.handleCachedFetch<int>(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<int>>>());
        result.fold(
          (_) => fail('Should return cached data'),
          (data) => expect(data, equals(intData)),
        );
      });

      test('should handle empty data lists', () async {
        // Arrange
        final emptyData = <String>[];

        Future<bool> isCacheValid() async => true;
        Future<List<String>> getCachedData() async => emptyData;
        Future<List<String>> getRemoteData() async => ['remote'];
        Future<void> cacheData(List<String> data) async {}

        // Act
        final result = await RepositoryHelper.handleCachedFetch(
          isCacheValid,
          getCachedData,
          getRemoteData,
          cacheData,
        );

        // Assert
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (_) => fail('Should return empty data'),
          (data) => expect(data, isEmpty),
        );
      });
    });

    group('applyDataTransformation', () {
      test('should apply transformation to data', () async {
        // Arrange
        final inputData = ['a', 'b', 'c'];
        final expectedOutput = ['A', 'B', 'C'];

        Future<List<String>> transform(List<String> data) async {
          return data.map((item) => item.toUpperCase()).toList();
        }

        // Act
        final result = await RepositoryHelper.applyDataTransformation(
          inputData,
          transform,
        );

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should handle empty data transformation', () async {
        // Arrange
        final inputData = <String>[];

        Future<List<String>> transform(List<String> data) async {
          return data.map((item) => item.toUpperCase()).toList();
        }

        // Act
        final result = await RepositoryHelper.applyDataTransformation(
          inputData,
          transform,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should handle complex data transformations', () async {
        // Arrange
        final inputData = [1, 2, 3, 4, 5];

        Future<List<int>> transform(List<int> data) async {
          return data.where((item) => item.isEven).map((item) => item * 2).toList();
        }

        // Act
        final result = await RepositoryHelper.applyDataTransformation(
          inputData,
          transform,
        );

        // Assert
        expect(result, equals([4, 8]));
      });

      test('should handle async transformations with delay', () async {
        // Arrange
        final inputData = ['test1', 'test2'];

        Future<List<String>> transform(List<String> data) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return data.map((item) => '${item}_transformed').toList();
        }

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await RepositoryHelper.applyDataTransformation(
          inputData,
          transform,
        );
        stopwatch.stop();

        // Assert
        expect(result, equals(['test1_transformed', 'test2_transformed']));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
      });

      test('should propagate exceptions from transformation', () async {
        // Arrange
        final inputData = ['test'];

        Future<List<String>> transform(List<String> data) async {
          throw Exception('Transformation failed');
        }

        // Act & Assert
        expect(
          () => RepositoryHelper.applyDataTransformation(inputData, transform),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('handleToggleOperation', () {
      test('should toggle from false to true successfully', () async {
        // Arrange
        var currentStatus = false;
        var remoteUpdated = false;
        var localUpdated = false;
        var cacheInvalidated = false;
        final updatedData = 'updated_result';

        Future<bool> getCurrentStatus() async => currentStatus;
        Future<void> updateRemote(bool newStatus) async {
          expect(newStatus, isTrue);
          remoteUpdated = true;
        }
        Future<void> updateLocal() async => localUpdated = true;
        Future<void> invalidateCache() async => cacheInvalidated = true;
        Future<String> getUpdatedData() async => updatedData;

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Should succeed'),
          (data) => expect(data, equals(updatedData)),
        );
        expect(remoteUpdated, isTrue);
        expect(localUpdated, isTrue);
        expect(cacheInvalidated, isTrue);
      });

      test('should toggle from true to false successfully', () async {
        // Arrange
        var currentStatus = true;
        var remoteUpdated = false;
        var localUpdated = false;
        var cacheInvalidated = false;
        final updatedData = 'updated_result';

        Future<bool> getCurrentStatus() async => currentStatus;
        Future<void> updateRemote(bool newStatus) async {
          expect(newStatus, isFalse);
          remoteUpdated = true;
        }
        Future<void> updateLocal() async => localUpdated = true;
        Future<void> invalidateCache() async => cacheInvalidated = true;
        Future<String> getUpdatedData() async => updatedData;

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Should succeed'),
          (data) => expect(data, equals(updatedData)),
        );
        expect(remoteUpdated, isTrue);
        expect(localUpdated, isTrue);
        expect(cacheInvalidated, isTrue);
      });

      test('should return failure when remote update fails', () async {
        // Arrange
        var localUpdated = false;
        var cacheInvalidated = false;

        Future<bool> getCurrentStatus() async => false;
        Future<void> updateRemote(bool newStatus) async => throw const ServerException('Remote failed');
        Future<void> updateLocal() async => localUpdated = true;
        Future<void> invalidateCache() async => cacheInvalidated = true;
        Future<String> getUpdatedData() async => 'updated';

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
        expect(localUpdated, isFalse);
        expect(cacheInvalidated, isFalse);
      });

      test('should continue operation when local update fails', () async {
        // Arrange
        var remoteUpdated = false;
        var cacheInvalidated = false;

        Future<bool> getCurrentStatus() async => false;
        Future<void> updateRemote(bool newStatus) async => remoteUpdated = true;
        Future<void> updateLocal() async => throw Exception('Local update failed');
        Future<void> invalidateCache() async => cacheInvalidated = true;
        Future<String> getUpdatedData() async => 'updated';

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Should return failure due to local update error'),
        );
        expect(remoteUpdated, isTrue);
        expect(cacheInvalidated, isFalse);
      });

      test('should handle getCurrentStatus failure', () async {
        // Arrange
        Future<bool> getCurrentStatus() async => throw const NetworkException('Status check failed');
        Future<void> updateRemote(bool newStatus) async {}
        Future<void> updateLocal() async {}
        Future<void> invalidateCache() async {}
        Future<String> getUpdatedData() async => 'updated';

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should handle getUpdatedData failure', () async {
        // Arrange
        var remoteUpdated = false;
        var localUpdated = false;
        var cacheInvalidated = false;

        Future<bool> getCurrentStatus() async => false;
        Future<void> updateRemote(bool newStatus) async => remoteUpdated = true;
        Future<void> updateLocal() async => localUpdated = true;
        Future<void> invalidateCache() async => cacheInvalidated = true;
        Future<String> getUpdatedData() async => throw const CacheException('Data fetch failed');

        // Act
        final result = await RepositoryHelper.handleToggleOperation(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
        expect(remoteUpdated, isTrue);
        expect(localUpdated, isTrue);
        expect(cacheInvalidated, isTrue);
      });

      test('should handle different data types for toggle operation', () async {
        // Arrange
        final updatedData = {'id': 1, 'status': true};

        Future<bool> getCurrentStatus() async => false;
        Future<void> updateRemote(bool newStatus) async {}
        Future<void> updateLocal() async {}
        Future<void> invalidateCache() async {}
        Future<Map<String, dynamic>> getUpdatedData() async => updatedData;

        // Act
        final result = await RepositoryHelper.handleToggleOperation<Map<String, dynamic>>(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Right<Failure, Map<String, dynamic>>>());
        result.fold(
          (_) => fail('Should succeed'),
          (data) => expect(data, equals(updatedData)),
        );
      });
    });

    group('Edge Cases and Performance', () {
      test('should handle concurrent cache operations', () async {
        // Arrange
        var cacheValidCalls = 0;
        var remoteDataCalls = 0;

        Future<bool> isCacheValid() async {
          cacheValidCalls++;
          await Future.delayed(const Duration(milliseconds: 5));
          return false;
        }
        Future<List<String>> getCachedData() async => ['cached'];
        Future<List<String>> getRemoteData() async {
          remoteDataCalls++;
          await Future.delayed(const Duration(milliseconds: 10));
          return ['remote_$remoteDataCalls'];
        }
        Future<void> cacheData(List<String> data) async {}

        // Act
        final futures = List.generate(
          3,
          (_) => RepositoryHelper.handleCachedFetch(
            isCacheValid,
            getCachedData,
            getRemoteData,
            cacheData,
          ),
        );
        final results = await Future.wait(futures);

        // Assert
        expect(results, hasLength(3));
        expect(cacheValidCalls, equals(3));
        expect(remoteDataCalls, equals(3));
        for (final result in results) {
          expect(result, isA<Right<Failure, List<String>>>());
        }
      });

      test('should handle null or invalid operations gracefully', () async {
        // Arrange
        Future<bool> getCurrentStatus() async => false;
        Future<void> updateRemote(bool newStatus) async {}
        Future<void> updateLocal() async {}
        Future<void> invalidateCache() async {}
        Future<String?> getUpdatedData() async => null;

        // Act
        final result = await RepositoryHelper.handleToggleOperation<String?>(
          getCurrentStatus,
          updateRemote,
          updateLocal,
          invalidateCache,
          getUpdatedData,
        );

        // Assert
        expect(result, isA<Right<Failure, String?>>());
        result.fold(
          (_) => fail('Should succeed'),
          (data) => expect(data, isNull),
        );
      });
    });
  });
}
