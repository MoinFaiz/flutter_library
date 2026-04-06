import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';

void main() {
  group('Policy Entity', () {
    const tId = 'policy_123';
    const tTitle = 'Terms and Conditions';
    const tContent = 'This is the policy content with detailed terms and conditions.';
    final tLastUpdated = DateTime(2023, 5, 15, 10, 30);
    const tVersion = '1.2.0';

    final tPolicy = Policy(
      id: tId,
      title: tTitle,
      content: tContent,
      lastUpdated: tLastUpdated,
      version: tVersion,
    );

    group('constructor', () {
      test('should create Policy with all required fields', () {
        // act & assert
        expect(tPolicy.id, equals(tId));
        expect(tPolicy.title, equals(tTitle));
        expect(tPolicy.content, equals(tContent));
        expect(tPolicy.lastUpdated, equals(tLastUpdated));
        expect(tPolicy.version, equals(tVersion));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: tId,
          title: tTitle,
          content: tContent,
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy1, equals(policy2));
        expect(policy1.hashCode, equals(policy2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: 'different_id',
          title: tTitle,
          content: tContent,
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy1, isNot(equals(policy2)));
        expect(policy1.hashCode, isNot(equals(policy2.hashCode)));
      });

      test('should not be equal when titles differ', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: tId,
          title: 'Different Title',
          content: tContent,
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy1, isNot(equals(policy2)));
      });

      test('should not be equal when content differs', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: tId,
          title: tTitle,
          content: 'Different content',
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy1, isNot(equals(policy2)));
      });

      test('should not be equal when lastUpdated differs', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: tId,
          title: tTitle,
          content: tContent,
          lastUpdated: DateTime(2023, 6, 15, 10, 30),
          version: tVersion,
        );

        // assert
        expect(policy1, isNot(equals(policy2)));
      });

      test('should not be equal when version differs', () {
        // arrange
        final policy1 = tPolicy;
        final policy2 = Policy(
          id: tId,
          title: tTitle,
          content: tContent,
          lastUpdated: tLastUpdated,
          version: '2.0.0',
        );

        // assert
        expect(policy1, isNot(equals(policy2)));
      });
    });

    group('toString', () {
      test('should return correct string representation', () {
        // act
        final result = tPolicy.toString();

        // assert
        expect(result, contains('Policy{'));
        expect(result, contains('id: $tId'));
        expect(result, contains('title: $tTitle'));
        expect(result, contains('lastUpdated: $tLastUpdated'));
        expect(result, contains('version: $tVersion'));
      });
    });

    group('edge cases', () {
      test('should handle empty content', () {
        // arrange
        final policy = Policy(
          id: tId,
          title: tTitle,
          content: '',
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy.content, isEmpty);
        expect(policy.id, equals(tId));
      });

      test('should handle long content', () {
        // arrange
        final longContent = 'A' * 10000; // 10k characters
        final policy = Policy(
          id: tId,
          title: tTitle,
          content: longContent,
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy.content, equals(longContent));
        expect(policy.content.length, equals(10000));
      });

      test('should handle special characters in title and content', () {
        // arrange
        const specialTitle = 'Title with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*()';
        const specialContent = 'Content with unicode: 😀🎉 and special chars: àáâãäåæçèéêë';
        
        final policy = Policy(
          id: tId,
          title: specialTitle,
          content: specialContent,
          lastUpdated: tLastUpdated,
          version: tVersion,
        );

        // assert
        expect(policy.title, equals(specialTitle));
        expect(policy.content, equals(specialContent));
      });

      test('should handle very old and future dates', () {
        // arrange
        final oldDate = DateTime(1900, 1, 1);
        final futureDate = DateTime(2100, 12, 31);
        
        final oldPolicy = Policy(
          id: tId,
          title: tTitle,
          content: tContent,
          lastUpdated: oldDate,
          version: tVersion,
        );
        
        final futurePolicy = Policy(
          id: tId,
          title: tTitle,
          content: tContent,
          lastUpdated: futureDate,
          version: tVersion,
        );

        // assert
        expect(oldPolicy.lastUpdated, equals(oldDate));
        expect(futurePolicy.lastUpdated, equals(futureDate));
      });

      test('should handle different version formats', () {
        final versionFormats = [
          '1.0',
          '1.0.0',
          '1.0.0-beta',
          '1.0.0-alpha.1',
          '2.1.3-rc.2+build.123',
          'v1.0.0',
        ];

        for (final version in versionFormats) {
          final policy = Policy(
            id: tId,
            title: tTitle,
            content: tContent,
            lastUpdated: tLastUpdated,
            version: version,
          );

          expect(policy.version, equals(version));
        }
      });
    });
  });
}
