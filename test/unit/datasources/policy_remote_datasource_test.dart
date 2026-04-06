import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/policies/data/datasources/policy_remote_datasource.dart';
import 'package:flutter_library/features/policies/data/models/policy_model.dart';

void main() {
  group('PolicyRemoteDataSourceImpl', () {
    late PolicyRemoteDataSourceImpl dataSource;

    setUp(() {
      dataSource = PolicyRemoteDataSourceImpl();
    });

    group('getPolicy', () {
      test('should return privacy policy when policyId is "privacy"', () async {
        // Act
        final result = await dataSource.getPolicy('privacy');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('privacy'));
        expect(result.title, equals('Privacy Policy'));
        expect(result.content, contains('Information We Collect'));
        expect(result.version, equals('1.2.0'));
        expect(result.lastUpdated, isA<DateTime>());
      });

      test('should return terms policy when policyId is "terms"', () async {
        // Act
        final result = await dataSource.getPolicy('terms');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('terms'));
        expect(result.title, equals('Terms & Conditions'));
        expect(result.content, contains('Acceptance of Terms'));
        expect(result.version, equals('1.1.0'));
      });

      test('should return shipping policy when policyId is "shipping"', () async {
        // Act
        final result = await dataSource.getPolicy('shipping');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('shipping'));
        expect(result.title, equals('Shipping & Delivery Policy'));
        expect(result.content, contains('Shipping Methods'));
        expect(result.version, equals('1.0.0'));
      });

      test('should return cancellation policy when policyId is "cancellation"', () async {
        // Act
        final result = await dataSource.getPolicy('cancellation');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('cancellation'));
        expect(result.title, equals('Cancellation & Refund Policy'));
        expect(result.content, contains('Order Cancellation'));
        expect(result.version, equals('1.0.0'));
      });

      test('should return fallback policy for unknown policyId', () async {
        // Act
        final result = await dataSource.getPolicy('unknown');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('unknown'));
        expect(result.title, equals('Policy Not Found'));
        expect(result.content, contains('Policy Not Available'));
        expect(result.version, equals('1.0.0'));
      });

      test('should return fallback policy for empty policyId', () async {
        // Act
        final result = await dataSource.getPolicy('');

        // Assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals(''));
        expect(result.title, equals('Policy Not Found'));
        expect(result.content, contains('Policy Not Available'));
      });

      test('should have network delay simulation', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getPolicy('privacy');
        
        stopwatch.stop();
        
        // Should take at least 500ms due to delay
        expect(stopwatch.elapsedMilliseconds, greaterThan(400));
        expect(stopwatch.elapsedMilliseconds, lessThan(800));
      });

      test('should return consistent results for same policyId', () async {
        // Act
        final result1 = await dataSource.getPolicy('privacy');
        final result2 = await dataSource.getPolicy('privacy');

        // Assert
        expect(result1.id, equals(result2.id));
        expect(result1.title, equals(result2.title));
        expect(result1.content, equals(result2.content));
        expect(result1.version, equals(result2.version));
      });

      test('should return different content for different policies', () async {
        // Act
        final privacyPolicy = await dataSource.getPolicy('privacy');
        final termsPolicy = await dataSource.getPolicy('terms');

        // Assert
        expect(privacyPolicy.content, isNot(equals(termsPolicy.content)));
        expect(privacyPolicy.title, isNot(equals(termsPolicy.title)));
      });

      test('privacy policy should contain required sections', () async {
        // Act
        final result = await dataSource.getPolicy('privacy');

        // Assert
        expect(result.content, contains('Information We Collect'));
        expect(result.content, contains('How We Use Your Information'));
        expect(result.content, contains('Information Sharing'));
        expect(result.content, contains('Data Security'));
        expect(result.content, contains('Contact Us'));
      });

      test('terms policy should contain required sections', () async {
        // Act
        final result = await dataSource.getPolicy('terms');

        // Assert
        expect(result.content, contains('Acceptance of Terms'));
        expect(result.content, contains('Use License'));
        expect(result.content, contains('Disclaimer'));
        expect(result.content, contains('Limitations'));
        expect(result.content, contains('Account Terms'));
      });

      test('shipping policy should contain shipping methods', () async {
        // Act
        final result = await dataSource.getPolicy('shipping');

        // Assert
        expect(result.content, contains('Standard Shipping'));
        expect(result.content, contains('Express Shipping'));
        expect(result.content, contains('Overnight Shipping'));
        expect(result.content, contains('Processing Time'));
      });

      test('cancellation policy should contain refund information', () async {
        // Act
        final result = await dataSource.getPolicy('cancellation');

        // Assert
        expect(result.content, contains('Order Cancellation'));
        expect(result.content, contains('Return Policy'));
        expect(result.content, contains('Refund Process'));
        expect(result.content, contains('Non-Refundable Items'));
      });

      test('fallback policy should contain contact information', () async {
        // Act
        final result = await dataSource.getPolicy('nonexistent');

        // Assert
        expect(result.content, contains('support@flutterlibrary.com'));
        expect(result.content, contains('Contact Support'));
      });

      test('should use consistent date across all policies', () async {
        // Act
        final privacy = await dataSource.getPolicy('privacy');
        final terms = await dataSource.getPolicy('terms');
        final shipping = await dataSource.getPolicy('shipping');
        final cancellation = await dataSource.getPolicy('cancellation');

        // Assert - All should have the same lastUpdated date
        expect(privacy.lastUpdated, equals(terms.lastUpdated));
        expect(terms.lastUpdated, equals(shipping.lastUpdated));
        expect(shipping.lastUpdated, equals(cancellation.lastUpdated));
      });
    });
  });
}
