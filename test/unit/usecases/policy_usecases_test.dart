import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/policies/domain/usecases/get_policy_usecase.dart';
import 'package:flutter_library/features/policies/domain/repositories/policy_repository.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';

class MockPolicyRepository extends Mock implements PolicyRepository {}

void main() {
  group('Policy Use Cases Tests', () {
    late MockPolicyRepository mockRepository;
    late GetPolicyUseCase getPolicyUseCase;

    setUpAll(() {
      registerFallbackValue(Policy(
        id: 'fallback',
        title: 'Fallback Policy',
        content: 'Fallback content',
        lastUpdated: DateTime.now(),
        version: '1.0.0',
      ));
    });

    setUp(() {
      mockRepository = MockPolicyRepository();
      getPolicyUseCase = GetPolicyUseCase(mockRepository);
    });

    final mockPolicy = Policy(
      id: 'privacy-policy',
      title: 'Privacy Policy',
      content: 'This is the privacy policy content...',
      lastUpdated: DateTime(2023, 12, 1),
      version: '1.0.0',
    );

    group('GetPolicyUseCase', () {
      test('should return policy from cache when cache is valid', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy));
        when(() => mockRepository.isCacheExpired('privacy-policy'))
            .thenAnswer((_) async => const Right(false));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert
        expect(result, equals(Right(mockPolicy)));
        verify(() => mockRepository.getCachedPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.isCacheExpired('privacy-policy')).called(1);
        verifyNever(() => mockRepository.getPolicy(any()));
        verifyNever(() => mockRepository.cachePolicy(any()));
      });

      test('should fetch from server when cache is expired', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy));
        when(() => mockRepository.isCacheExpired('privacy-policy'))
            .thenAnswer((_) async => const Right(true));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy));
        when(() => mockRepository.cachePolicy(mockPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert
        expect(result, equals(Right(mockPolicy)));
        verify(() => mockRepository.getCachedPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.isCacheExpired('privacy-policy')).called(1);
        verify(() => mockRepository.getPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.cachePolicy(mockPolicy)).called(1);
      });

      test('should fetch from server when no cache exists', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy));
        when(() => mockRepository.cachePolicy(mockPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert
        expect(result, equals(Right(mockPolicy)));
        verify(() => mockRepository.getCachedPolicy('privacy-policy')).called(1);
        verifyNever(() => mockRepository.isCacheExpired(any()));
        verify(() => mockRepository.getPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.cachePolicy(mockPolicy)).called(1);
      });

      test('should return cached policy when server fails and cache exists', () async {
        // Arrange - set up cache to be empty first, then have cached data available in catch block
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy)); // Return cached policy
        when(() => mockRepository.isCacheExpired('privacy-policy'))
            .thenAnswer((_) async => const Right(true)); // Cache is expired, so server call will be made
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert
        expect(result, equals(Right(mockPolicy)));
        verify(() => mockRepository.getPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.getCachedPolicy('privacy-policy')).called(2);
      });

      test('should rethrow exception when server fails and no cache exists', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(() => getPolicyUseCase.execute('privacy-policy'),
            throwsA(isA<Exception>()));
        verify(() => mockRepository.getPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.getCachedPolicy('privacy-policy')).called(2);
      });

      test('should handle different policy types correctly', () async {
        // Arrange
        final termsPolicy = Policy(
          id: 'terms-of-service',
          title: 'Terms of Service',
          content: 'Terms and conditions content...',
          lastUpdated: DateTime(2023, 11, 15),
          version: '2.1.0',
        );
        
        when(() => mockRepository.getCachedPolicy('terms-of-service'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('terms-of-service'))
            .thenAnswer((_) async => Right(termsPolicy));
        when(() => mockRepository.cachePolicy(termsPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('terms-of-service');

        // Assert
        expect(result.getOrElse(() => throw Exception('Expected Right')).id, equals('terms-of-service'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).title, equals('Terms of Service'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).version, equals('2.1.0'));
        verify(() => mockRepository.getPolicy('terms-of-service')).called(1);
      });

      test('should handle empty policy ID gracefully', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy(''))
            .thenThrow(Exception('Invalid policy ID'));

        // Act & Assert
        expect(() => getPolicyUseCase.execute(''),
            throwsA(isA<Exception>()));
      });

      test('should handle policy with special characters', () async {
        // Arrange
        final specialPolicy = Policy(
          id: 'international-policy',
          title: 'International Policy (Ãƒâ€šÃ‚Â©2023)',
          content: 'Policy content with special chars: ÃƒÆ’Ã‚Â±ÃƒÆ’Ã‚Â¡ÃƒÆ’Ã‚Â©ÃƒÆ’Ã‚Â­ÃƒÆ’Ã‚Â³ÃƒÆ’Ã‚Âº, ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡, ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¨Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©, Ãƒâ€˜Ã¢â€šÂ¬Ãƒâ€˜Ã†â€™Ãƒâ€˜Ã‚ÂÃƒâ€˜Ã‚ÂÃƒÂÃ‚ÂºÃƒÂÃ‚Â¸ÃƒÂÃ‚Â¹',
          lastUpdated: DateTime(2023, 12, 1),
          version: '1.0.0',
        );
        
        when(() => mockRepository.getCachedPolicy('international-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('international-policy'))
            .thenAnswer((_) async => Right(specialPolicy));
        when(() => mockRepository.cachePolicy(specialPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('international-policy');

        // Assert
        expect(result.getOrElse(() => throw Exception('Expected Right')).title, contains('Ãƒâ€šÃ‚Â©'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).content, contains('ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).content, contains('ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¨Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).content, contains('Ãƒâ€˜Ã¢â€šÂ¬Ãƒâ€˜Ã†â€™Ãƒâ€˜Ã‚ÂÃƒâ€˜Ã‚ÂÃƒÂÃ‚ÂºÃƒÂÃ‚Â¸ÃƒÂÃ‚Â¹'));
      });

      test('should handle large policy content', () async {
        // Arrange
        final largePolicy = Policy(
          id: 'data-usage-policy',
          title: 'Data Usage Policy',
          content: 'A' * 50000, // Very large content
          lastUpdated: DateTime(2023, 12, 1),
          version: '1.0.0',
        );
        
        when(() => mockRepository.getCachedPolicy('data-usage-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('data-usage-policy'))
            .thenAnswer((_) async => Right(largePolicy));
        when(() => mockRepository.cachePolicy(largePolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('data-usage-policy');

        // Assert
        expect(result.getOrElse(() => throw Exception('Expected Right')).content.length, equals(50000));
        expect(result.getOrElse(() => throw Exception('Expected Right')).title, equals('Data Usage Policy'));
      });

      test('should handle concurrent requests for same policy', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Right(mockPolicy);
        });
        when(() => mockRepository.cachePolicy(mockPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final futures = List.generate(3, (_) => getPolicyUseCase.execute('privacy-policy'));
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result, equals(Right(mockPolicy)));
        }
        verify(() => mockRepository.getPolicy('privacy-policy')).called(3);
      });

      test('should handle repository timeout gracefully', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenThrow(Exception('Request timeout'));

        // Act & Assert
        expect(() => getPolicyUseCase.execute('privacy-policy'),
            throwsA(predicate((e) => e.toString().contains('Request timeout'))));
      });
    });

    group('Policy Caching Integration', () {
      test('should handle cache write failures gracefully', () async {
        // Arrange
        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(mockPolicy));
        when(() => mockRepository.cachePolicy(mockPolicy))
            .thenThrow(Exception('Cache write error'));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert - Should still return the policy even if caching fails
        expect(result, equals(Right(mockPolicy)));
        verify(() => mockRepository.getPolicy('privacy-policy')).called(1);
        verify(() => mockRepository.cachePolicy(mockPolicy)).called(1);
      });

      test('should prefer fresh data over expired cache', () async {
        // Arrange
        final cachedPolicy = Policy(
          id: 'privacy-policy',
          title: 'Old Privacy Policy',
          content: 'Old content...',
          lastUpdated: DateTime(2023, 11, 1),
          version: '1.0.0',
        );
        
        final freshPolicy = Policy(
          id: 'privacy-policy',
          title: 'Updated Privacy Policy',
          content: 'Updated content...',
          lastUpdated: DateTime(2023, 12, 1),
          version: '1.1.0',
        );

        when(() => mockRepository.getCachedPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(cachedPolicy));
        when(() => mockRepository.isCacheExpired('privacy-policy'))
            .thenAnswer((_) async => const Right(true));
        when(() => mockRepository.getPolicy('privacy-policy'))
            .thenAnswer((_) async => Right(freshPolicy));
        when(() => mockRepository.cachePolicy(freshPolicy))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await getPolicyUseCase.execute('privacy-policy');

        // Assert
        expect(result, equals(Right(freshPolicy)));
        expect(result.getOrElse(() => throw Exception('Expected Right')).title, equals('Updated Privacy Policy'));
        expect(result.getOrElse(() => throw Exception('Expected Right')).version, equals('1.1.0'));
      });
    });
  });
}
