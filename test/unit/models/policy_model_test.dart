import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/policies/data/models/policy_model.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';

void main() {
  group('PolicyModel', () {
    final testLastUpdated = DateTime(2023, 12, 15, 10, 30, 0);
    
    final testPolicyModel = PolicyModel(
      id: 'privacy_policy',
      title: 'Privacy Policy',
      content: '''
This is our privacy policy content.

We collect and use your personal information in accordance with applicable laws.

1. Information We Collect
2. How We Use Information
3. Information Sharing
4. Data Security
5. Your Rights
      '''.trim(),
      lastUpdated: testLastUpdated,
      version: '2.1.0',
    );

    final testJson = {
      'id': 'privacy_policy',
      'title': 'Privacy Policy',
      'content': '''
This is our privacy policy content.

We collect and use your personal information in accordance with applicable laws.

1. Information We Collect
2. How We Use Information
3. Information Sharing
4. Data Security
5. Your Rights
      '''.trim(),
      'lastUpdated': '2023-12-15T10:30:00.000',
      'version': '2.1.0',
    };

    group('Entity Extension', () {
      test('should be a subclass of Policy entity', () {
        expect(testPolicyModel, isA<Policy>());
      });

      test('should have correct properties from parent entity', () {
        expect(testPolicyModel.id, equals('privacy_policy'));
        expect(testPolicyModel.title, equals('Privacy Policy'));
        expect(testPolicyModel.content.startsWith('This is our privacy policy content.'), isTrue);
        expect(testPolicyModel.lastUpdated, equals(testLastUpdated));
        expect(testPolicyModel.version, equals('2.1.0'));
      });
    });

    group('fromJson', () {
      test('should return a valid PolicyModel from JSON', () {
        // act
        final result = PolicyModel.fromJson(testJson);

        // assert
        expect(result, isA<PolicyModel>());
        expect(result.id, equals('privacy_policy'));
        expect(result.title, equals('Privacy Policy'));
        expect(result.content, equals(testJson['content']));
        expect(result.lastUpdated, equals(testLastUpdated));
        expect(result.version, equals('2.1.0'));
      });

      test('should handle different policy types', () {
        // arrange
        final termsJson = {
          'id': 'terms_conditions',
          'title': 'Terms and Conditions',
          'content': 'These are the terms and conditions for using our service.',
          'lastUpdated': '2023-11-01T12:00:00.000',
          'version': '1.0.0',
        };

        // act
        final result = PolicyModel.fromJson(termsJson);

        // assert
        expect(result.id, equals('terms_conditions'));
        expect(result.title, equals('Terms and Conditions'));
        expect(result.content, equals('These are the terms and conditions for using our service.'));
        expect(result.version, equals('1.0.0'));
      });

      test('should handle empty content', () {
        // arrange
        final jsonWithEmptyContent = Map<String, dynamic>.from(testJson);
        jsonWithEmptyContent['content'] = '';

        // act
        final result = PolicyModel.fromJson(jsonWithEmptyContent);

        // assert
        expect(result.content, equals(''));
      });

      test('should handle very long content', () {
        // arrange
        final longContent = 'Lorem ipsum dolor sit amet, ' * 1000;
        final jsonWithLongContent = Map<String, dynamic>.from(testJson);
        jsonWithLongContent['content'] = longContent;

        // act
        final result = PolicyModel.fromJson(jsonWithLongContent);

        // assert
        expect(result.content, equals(longContent));
        expect(result.content.length, greaterThan(10000));
      });

      test('should throw when required fields are missing', () {
        // arrange
        final incompleteJson = <String, dynamic>{
          'id': 'privacy_policy',
          'title': 'Privacy Policy',
          // missing content, lastUpdated, version
        };

        // act & assert
        expect(() => PolicyModel.fromJson(incompleteJson), throwsA(isA<TypeError>()));
      });

      test('should throw when date string is invalid', () {
        // arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(testJson);
        jsonWithInvalidDate['lastUpdated'] = 'invalid-date';

        // act & assert
        expect(() => PolicyModel.fromJson(jsonWithInvalidDate), throwsA(isA<FormatException>()));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // act
        final result = testPolicyModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('privacy_policy'));
        expect(result['title'], equals('Privacy Policy'));
        expect(result['content'], equals(testPolicyModel.content));
        expect(result['lastUpdated'], equals('2023-12-15T10:30:00.000'));
        expect(result['version'], equals('2.1.0'));
      });

      test('should maintain data integrity in round-trip conversion', () {
        // act
        final json = testPolicyModel.toJson();
        final reconstructed = PolicyModel.fromJson(json);

        // assert
        expect(reconstructed.id, equals(testPolicyModel.id));
        expect(reconstructed.title, equals(testPolicyModel.title));
        expect(reconstructed.content, equals(testPolicyModel.content));
        expect(reconstructed.lastUpdated, equals(testPolicyModel.lastUpdated));
        expect(reconstructed.version, equals(testPolicyModel.version));
      });

      test('should handle special characters in content', () {
        // arrange
        final policyWithSpecialChars = PolicyModel(
          id: 'special_policy',
          title: 'Policy with Special Characters: & < > " \' \\',
          content: 'Content with special chars: &amp; &lt; &gt; &quot; &#x27; \\n \\t',
          lastUpdated: testLastUpdated,
          version: '1.0.0',
        );

        // act
        final json = policyWithSpecialChars.toJson();
        final reconstructed = PolicyModel.fromJson(json);

        // assert
        expect(reconstructed.title, equals(policyWithSpecialChars.title));
        expect(reconstructed.content, equals(policyWithSpecialChars.content));
      });
    });

    group('Equality', () {
      test('should be equal to another PolicyModel with same values', () {
        // arrange
        final otherPolicyModel = PolicyModel(
          id: 'privacy_policy',
          title: 'Privacy Policy',
          content: testPolicyModel.content,
          lastUpdated: testLastUpdated,
          version: '2.1.0',
        );

        // act & assert
        expect(testPolicyModel, equals(otherPolicyModel));
        expect(testPolicyModel.hashCode, equals(otherPolicyModel.hashCode));
      });

      test('should not be equal to PolicyModel with different values', () {
        // arrange
        final differentPolicyModel = PolicyModel(
          id: 'terms_conditions', // different id
          title: 'Privacy Policy',
          content: testPolicyModel.content,
          lastUpdated: testLastUpdated,
          version: '2.1.0',
        );

        // act & assert
        expect(testPolicyModel, isNot(equals(differentPolicyModel)));
      });

      test('should not be equal to PolicyModel with different version', () {
        // arrange
        final differentVersionModel = PolicyModel(
          id: 'privacy_policy',
          title: 'Privacy Policy',
          content: testPolicyModel.content,
          lastUpdated: testLastUpdated,
          version: '2.2.0', // different version
        );

        // act & assert
        expect(testPolicyModel, isNot(equals(differentVersionModel)));
      });
    });

    group('Edge Cases', () {
      test('should handle policy with minimal content', () {
        // arrange
        final minimalJson = {
          'id': 'minimal_policy',
          'title': 'Minimal',
          'content': 'Short content.',
          'lastUpdated': '2023-01-01T00:00:00.000',
          'version': '1.0',
        };

        // act
        final result = PolicyModel.fromJson(minimalJson);

        // assert
        expect(result.content, equals('Short content.'));
        expect(result.version, equals('1.0'));
      });

      test('should handle content with newlines and formatting', () {
        // arrange
        final formattedContent = '''
# Privacy Policy

## Introduction
This policy explains how we handle your data.

### Data Collection
- Personal information
- Usage data
- Device information

### Contact Us
Email: privacy@example.com
        ''';

        final jsonWithFormatting = Map<String, dynamic>.from(testJson);
        jsonWithFormatting['content'] = formattedContent;

        // act
        final result = PolicyModel.fromJson(jsonWithFormatting);

        // assert
        expect(result.content, equals(formattedContent));
        expect(result.content.contains('\n'), isTrue);
        expect(result.content.contains('#'), isTrue);
      });

      test('should handle version with various formats', () {
        // arrange
        final versions = ['1.0', '2.1.3', '1.0.0-beta', '2023.12.15'];
        
        for (final version in versions) {
          final jsonWithVersion = Map<String, dynamic>.from(testJson);
          jsonWithVersion['version'] = version;

          // act
          final result = PolicyModel.fromJson(jsonWithVersion);

          // assert
          expect(result.version, equals(version));
        }
      });
    });
  });
}
