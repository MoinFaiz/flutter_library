// ignore: unused_import
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/policies/data/repositories/policy_repository_impl.dart';
import 'package:flutter_library/features/policies/data/datasources/policy_remote_datasource.dart';
import 'package:flutter_library/features/policies/data/datasources/policy_local_datasource.dart';
import 'package:flutter_library/features/policies/data/models/policy_model.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';

class MockPolicyRemoteDataSource extends Mock implements PolicyRemoteDataSource {}
class MockPolicyLocalDataSource extends Mock implements PolicyLocalDataSource {}

void main() {
  group('PolicyRepositoryImpl', () {
    late PolicyRepositoryImpl repository;
    late MockPolicyRemoteDataSource mockRemoteDataSource;
    late MockPolicyLocalDataSource mockLocalDataSource;

    setUpAll(() {
      registerFallbackValue(PolicyModel(
        id: 'test',
        title: 'test',
        content: 'test',
        version: '1.0',
        lastUpdated: DateTime.now(),
      ));
    });

    setUp(() {
      mockRemoteDataSource = MockPolicyRemoteDataSource();
      mockLocalDataSource = MockPolicyLocalDataSource();
      repository = PolicyRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
    });

    const tPolicyId = 'privacy_policy';
    
    final tPolicyModel = PolicyModel(
      id: 'privacy_policy',
      title: 'Privacy Policy',
      content: 'This is our privacy policy content...',
      version: '1.0',
      lastUpdated: DateTime(2023, 1, 1),
    );

    final tPolicy = Policy(
      id: 'privacy_policy',
      title: 'Privacy Policy',
      content: 'This is our privacy policy content...',
      version: '1.0',
      lastUpdated: DateTime(2023, 1, 1),
    );

    group('getPolicy', () {
      test('should return policy from remote when successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getPolicy(tPolicyId))
            .thenAnswer((_) async => tPolicyModel);

        // act
        final result = await repository.getPolicy(tPolicyId);

        // assert
        verify(() => mockRemoteDataSource.getPolicy(tPolicyId));
        final policy = result.getOrElse(() => throw Exception('Expected Right'));
        expect(policy.id, equals(tPolicy.id));
        expect(policy.title, equals(tPolicy.title));
        expect(policy.content, equals(tPolicy.content));
      });

      test('should return cached policy when remote fails and cache exists', () async {
        // arrange
        when(() => mockRemoteDataSource.getPolicy(tPolicyId))
            .thenThrow(Exception('Remote failed'));
        when(() => mockLocalDataSource.getCachedPolicy(tPolicyId))
            .thenAnswer((_) async => tPolicyModel);

        // act
        final result = await repository.getPolicy(tPolicyId);

        // assert
        verify(() => mockRemoteDataSource.getPolicy(tPolicyId));
        verify(() => mockLocalDataSource.getCachedPolicy(tPolicyId));
        final policy = result.getOrElse(() => throw Exception('Expected Right'));
        expect(policy.id, equals(tPolicy.id));
        expect(policy.title, equals(tPolicy.title));
      });

      test('should throw exception when both remote and cache fail', () async {
        // arrange
        when(() => mockRemoteDataSource.getPolicy(tPolicyId))
            .thenThrow(Exception('Remote failed'));
        when(() => mockLocalDataSource.getCachedPolicy(tPolicyId))
            .thenThrow(Exception('Cache failed'));

        // act & assert
        expect(
          () => repository.getPolicy(tPolicyId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCachedPolicy', () {
      test('should return cached policy when exists', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedPolicy(tPolicyId))
            .thenAnswer((_) async => tPolicyModel);

        // act
        final result = await repository.getCachedPolicy(tPolicyId);

        // assert
        verify(() => mockLocalDataSource.getCachedPolicy(tPolicyId));
        expect(result, isNotNull);
        final policy = result.getOrElse(() => throw Exception('Expected Right'));
        expect(policy!.id, equals(tPolicy.id));
      });

      test('should return null when cached policy does not exist', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedPolicy(tPolicyId))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getCachedPolicy(tPolicyId);

        // assert
        verify(() => mockLocalDataSource.getCachedPolicy(tPolicyId));
        expect(result, isNull);
      });

      test('should return null when cache throws exception', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedPolicy(tPolicyId))
            .thenThrow(Exception('Cache error'));

        // act
        final result = await repository.getCachedPolicy(tPolicyId);

        // assert
        expect(result, isNull);
      });
    });

    group('cachePolicy', () {
      test('should cache policy successfully', () async {
        // arrange
        when(() => mockLocalDataSource.cachePolicy(any()))
            .thenAnswer((_) async => {});

        // act
        await repository.cachePolicy(tPolicy);

        // assert
        verify(() => mockLocalDataSource.cachePolicy(any()));
      });

      test('should handle cache errors silently', () async {
        // arrange
        when(() => mockLocalDataSource.cachePolicy(any()))
            .thenThrow(Exception('Cache error'));

        // act & assert - should not throw
        expect(
          () => repository.cachePolicy(tPolicy),
          returnsNormally,
        );
      });
    });

    group('clearCache', () {
      test('should clear cache successfully', () async {
        // arrange
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // act
        await repository.clearCache();

        // assert
        verify(() => mockLocalDataSource.clearCache());
      });
    });

    group('isCacheExpired', () {
      test('should return true when cache is expired', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheExpired(tPolicyId))
            .thenAnswer((_) async => true);

        // act
        final result = await repository.isCacheExpired(tPolicyId);

        // assert
        verify(() => mockLocalDataSource.isCacheExpired(tPolicyId));
        expect(result, isTrue);
      });

      test('should return false when cache is not expired', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheExpired(tPolicyId))
            .thenAnswer((_) async => false);

        // act
        final result = await repository.isCacheExpired(tPolicyId);

        // assert
        verify(() => mockLocalDataSource.isCacheExpired(tPolicyId));
        expect(result, isFalse);
      });
    });
  });
}
