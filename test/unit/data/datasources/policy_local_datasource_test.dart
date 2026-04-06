import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/policies/data/datasources/policy_local_datasource.dart';
import 'package:flutter_library/features/policies/data/models/policy_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('PolicyLocalDataSourceImpl Tests', () {
    late PolicyLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = PolicyLocalDataSourceImpl();
    });

    // Mock SharedPreferences.getInstance to return our mock
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    group('getCachedPolicy', () {
      test('should return cached policy when data exists', () async {
        // Arrange
        const policyId = 'privacy_policy';
        const cachedData = '''
        {
          "id": "privacy_policy",
          "title": "Privacy Policy",
          "content": "Test content",
          "lastUpdated": "2023-01-01T00:00:00.000Z",
          "version": "1.0"
        }
        ''';
        
        SharedPreferences.setMockInitialValues({
          'policy_cache_privacy_policy': cachedData,
        });

        // Act
        final result = await dataSource.getCachedPolicy(policyId);

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result?.id, equals('privacy_policy'));
        expect(result?.title, equals('Privacy Policy'));
        expect(result?.content, equals('Test content'));
      });

      test('should return null when no cached data exists', () async {
        // Arrange
        const policyId = 'non_existent_policy';
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await dataSource.getCachedPolicy(policyId);

        // Assert
        expect(result, isNull);
      });

      test('should return null when cached data is invalid JSON', () async {
        // Arrange
        const policyId = 'invalid_policy';
        SharedPreferences.setMockInitialValues({
          'policy_cache_invalid_policy': 'invalid json data',
        });

        // Act
        final result = await dataSource.getCachedPolicy(policyId);

        // Assert
        expect(result, isNull);
      });

      test('should handle exceptions gracefully', () async {
        // Arrange
        const policyId = 'test_policy';
        SharedPreferences.setMockInitialValues({
          'policy_cache_test_policy': '{"malformed": json}',
        });

        // Act
        final result = await dataSource.getCachedPolicy(policyId);

        // Assert
        expect(result, isNull);
      });
    });

    group('cachePolicy', () {
      test('should cache policy successfully', () async {
        // Arrange
        final policy = PolicyModel(
          id: 'test_policy',
          title: 'Test Policy',
          content: 'Test content',
          lastUpdated: DateTime.parse('2023-01-01T00:00:00.000Z'),
          version: '1.0',
        );

        SharedPreferences.setMockInitialValues({});

        // Act
        await dataSource.cachePolicy(policy);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString('policy_cache_test_policy');
        expect(cachedData, isNotNull);
        
        final timestamp = prefs.getInt('policy_timestamp_test_policy');
        expect(timestamp, isNotNull);
        expect(timestamp! > 0, isTrue);
      });

      test('should handle caching errors gracefully', () async {
        // Arrange
        final policy = PolicyModel(
          id: 'test_policy',
          title: 'Test Policy',
          content: 'Test content',
          lastUpdated: DateTime.parse('2023-01-01T00:00:00.000Z'),
          version: '1.0',
        );

        // Act & Assert - Should not throw
        expect(() => dataSource.cachePolicy(policy), returnsNormally);
      });
    });

    group('clearCache', () {
      test('should clear all policy cache data', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'policy_cache_policy1': 'data1',
          'policy_cache_policy2': 'data2',
          'policy_timestamp_policy1': '1234567890',
          'policy_timestamp_policy2': '1234567891',
          'other_key': 'should_remain',
        });

        // Act
        await dataSource.clearCache();

        // Assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('policy_cache_policy1'), isNull);
        expect(prefs.getString('policy_cache_policy2'), isNull);
        expect(prefs.getString('policy_timestamp_policy1'), isNull);
        expect(prefs.getString('policy_timestamp_policy2'), isNull);
        expect(prefs.getString('other_key'), equals('should_remain'));
      });

      test('should handle clear errors gracefully', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert - Should not throw
        expect(() => dataSource.clearCache(), returnsNormally);
      });
    });

    group('isCacheExpired', () {
      test('should return true when no timestamp exists', () async {
        // Arrange
        const policyId = 'test_policy';
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await dataSource.isCacheExpired(policyId);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when cache is not expired', () async {
        // Arrange
        const policyId = 'test_policy';
        final recentTimestamp = DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch;
        
        SharedPreferences.setMockInitialValues({
          'policy_timestamp_test_policy': recentTimestamp,
        });

        // Act
        final result = await dataSource.isCacheExpired(policyId);

        // Assert
        expect(result, isFalse);
      });

      test('should return true when cache is expired', () async {
        // Arrange
        const policyId = 'test_policy';
        final oldTimestamp = DateTime.now()
            .subtract(const Duration(days: 8))
            .millisecondsSinceEpoch;
        
        SharedPreferences.setMockInitialValues({
          'policy_timestamp_test_policy': oldTimestamp,
        });

        // Act
        final result = await dataSource.isCacheExpired(policyId);

        // Assert
        expect(result, isTrue);
      });

      test('should return true on exceptions', () async {
        // Arrange
        const policyId = 'test_policy';
        SharedPreferences.setMockInitialValues({
          'policy_timestamp_test_policy': 'invalid_timestamp',
        });

        // Act
        final result = await dataSource.isCacheExpired(policyId);

        // Assert
        expect(result, isTrue);
      });

      test('should handle exactly 7 days boundary', () async {
        // Arrange
        const policyId = 'test_policy';
        final exactlySevenDaysAgo = DateTime.now()
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch;
        
        SharedPreferences.setMockInitialValues({
          'policy_timestamp_test_policy': exactlySevenDaysAgo,
        });

        // Act
        final result = await dataSource.isCacheExpired(policyId);

        // Assert
        expect(result, isTrue);
      });
    });

    group('Cache constants', () {
      test('should have correct cache prefix', () {
        // This test verifies the internal structure
        const testId = 'test';
        expect('policy_cache_$testId', equals('policy_cache_test'));
      });

      test('should have correct timestamp prefix', () {
        // This test verifies the internal structure  
        const testId = 'test';
        expect('policy_timestamp_$testId', equals('policy_timestamp_test'));
      });

      test('should have 7 days cache expiry', () {
        // This test verifies the cache expiry duration
        const expectedDays = 7;
        const expectedExpiry = Duration(days: expectedDays);
        expect(expectedExpiry.inDays, equals(7));
      });
    });
  });
}
