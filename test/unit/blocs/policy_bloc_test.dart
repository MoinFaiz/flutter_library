import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_bloc.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_event.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_state.dart';
import 'package:flutter_library/features/policies/domain/usecases/get_policy_usecase.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class MockGetPolicyUseCase extends Mock implements GetPolicyUseCase {}

void main() {
  group('PolicyBloc Tests', () {
    late PolicyBloc policyBloc;
    late MockGetPolicyUseCase mockGetPolicyUseCase;

    setUp(() {
      mockGetPolicyUseCase = MockGetPolicyUseCase();
      policyBloc = PolicyBloc(mockGetPolicyUseCase);
    });

    tearDown(() {
      policyBloc.close();
    });

    final mockPolicy = Policy(
      id: 'privacy-policy',
      title: 'Privacy Policy',
      content: 'This is the privacy policy content...',
      lastUpdated: DateTime(2023, 12, 1),
      version: '1.0.0',
    );

    test('initial state should be PolicyInitial', () {
      expect(policyBloc.state, isA<PolicyInitial>());
    });

    group('LoadPolicy', () {
      blocTest<PolicyBloc, PolicyState>(
        'emits [PolicyLoading, PolicyLoaded] when policy is loaded successfully',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => Right(mockPolicy));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyLoaded>().having((state) => state.policy, 'policy', mockPolicy),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'emits [PolicyLoading, PolicyError] when loading policy fails',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Network error')));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyError>().having((state) => state.message, 'message', 'Network error'),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'emits [PolicyLoading, PolicyError] when policy not found',
        build: () {
          when(() => mockGetPolicyUseCase.execute('invalid-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Policy not found')));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('invalid-policy')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyError>().having((state) => state.message, 'message', 'Policy not found'),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'loads different policy types correctly',
        build: () {
          final termsPolicy = Policy(
            id: 'terms-of-service',
            title: 'Terms of Service',
            content: 'These are the terms of service...',
            lastUpdated: DateTime(2023, 11, 15),
            version: '2.1.0',
          );
          when(() => mockGetPolicyUseCase.execute('terms-of-service'))
              .thenAnswer((_) async => Right(termsPolicy));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('terms-of-service')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyLoaded>().having((state) => state.policy.id, 'policy.id', 'terms-of-service'),
        ],
      );
    });

    group('RefreshPolicy', () {
      blocTest<PolicyBloc, PolicyState>(
        'emits [PolicyLoaded] when policy is refreshed successfully (no loading state)',
        build: () {
          final updatedPolicy = Policy(
            id: 'privacy-policy',
            title: 'Privacy Policy',
            content: 'Updated privacy policy content...',
            lastUpdated: DateTime(2023, 12, 15),
            version: '1.1.0',
          );
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => Right(updatedPolicy));
          return policyBloc;
        },
        seed: () => PolicyLoaded(mockPolicy),
        act: (bloc) => bloc.add(RefreshPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyLoaded>().having((state) => state.policy, 'policy', isA<Policy>()
              .having((p) => p.version, 'version', '1.1.0')
              .having((p) => p.content, 'content', contains('Updated'))),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'emits [PolicyError] when refreshing policy fails',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Connection timeout')));
          return policyBloc;
        },
        seed: () => PolicyLoaded(mockPolicy),
        act: (bloc) => bloc.add(RefreshPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyError>().having((state) => state.message, 'message', 'Connection timeout'),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'handles network error during refresh gracefully',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'No internet connection')));
          return policyBloc;
        },
        seed: () => PolicyLoaded(mockPolicy),
        act: (bloc) => bloc.add(RefreshPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyError>().having((state) => state.message, 'message', contains('No internet connection')),
        ],
      );
    });

    group('Policy content validation', () {
      blocTest<PolicyBloc, PolicyState>(
        'handles policy with long content correctly',
        build: () {
          final longContentPolicy = Policy(
            id: 'data-policy',
            title: 'Data Usage Policy',
            content: 'A' * 10000, // Very long content
            lastUpdated: DateTime(2023, 12, 1),
            version: '1.0.0',
          );
          when(() => mockGetPolicyUseCase.execute('data-policy'))
              .thenAnswer((_) async => Right(longContentPolicy));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('data-policy')),
        verify: (bloc) {
          final state = bloc.state;
          if (state is PolicyLoaded) {
            expect(state.policy.content.length, equals(10000));
            expect(state.policy.title, equals('Data Usage Policy'));
          }
        },
      );

      blocTest<PolicyBloc, PolicyState>(
        'handles policy with special characters correctly',
        build: () {
          final specialCharPolicy = Policy(
            id: 'international-policy',
            title: 'International Policy (©2023)',
            content: 'Policy content with special chars: ñáéíóú, 中文, العربية, русский',
            lastUpdated: DateTime(2023, 12, 1),
            version: '1.0.0',
          );
          when(() => mockGetPolicyUseCase.execute('international-policy'))
              .thenAnswer((_) async => Right(specialCharPolicy));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('international-policy')),
        verify: (bloc) {
          final state = bloc.state;
          if (state is PolicyLoaded) {
            expect(state.policy.title, contains('©'));
            expect(state.policy.content, contains('中文'));
            expect(state.policy.content, contains('العربية'));
            expect(state.policy.content, contains('русский'));
          }
        },
      );
    });

    group('Error handling edge cases', () {
      blocTest<PolicyBloc, PolicyState>(
        'handles empty policy ID gracefully',
        build: () {
          when(() => mockGetPolicyUseCase.execute(''))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Invalid policy ID')));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyError>().having((state) => state.message, 'message', contains('Invalid policy ID')),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'handles null response gracefully',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Policy data is null')));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyError>().having((state) => state.message, 'message', contains('Policy data is null')),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'handles timeout exception',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Request timeout')));
          return policyBloc;
        },
        act: (bloc) => bloc.add(LoadPolicy('privacy-policy')),
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyError>().having((state) => state.message, 'message', 'Request timeout'),
        ],
      );
    });

    group('State persistence', () {
      blocTest<PolicyBloc, PolicyState>(
        'maintains loaded policy state when refreshing with same data',
        build: () {
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => Right(mockPolicy));
          return policyBloc;
        },
        seed: () => PolicyLoaded(mockPolicy),
        act: (bloc) => bloc.add(RefreshPolicy('privacy-policy')),
        verify: (bloc) {
          final state = bloc.state;
          if (state is PolicyLoaded) {
            expect(state.policy.id, equals(mockPolicy.id));
            expect(state.policy.version, equals(mockPolicy.version));
          }
        },
      );
    });

    group('Multiple events', () {
      blocTest<PolicyBloc, PolicyState>(
        'handles multiple load events correctly',
        build: () {
          final policy1 = Policy(
            id: 'policy-1',
            title: 'Policy 1',
            content: 'Content 1',
            lastUpdated: DateTime(2023, 12, 1),
            version: '1.0.0',
          );
          final policy2 = Policy(
            id: 'policy-2',
            title: 'Policy 2',
            content: 'Content 2',
            lastUpdated: DateTime(2023, 12, 2),
            version: '1.0.0',
          );
          
          when(() => mockGetPolicyUseCase.execute('policy-1'))
              .thenAnswer((_) async => Right(policy1));
          when(() => mockGetPolicyUseCase.execute('policy-2'))
              .thenAnswer((_) async => Right(policy2));
          return policyBloc;
        },
        act: (bloc) async {
          bloc.add(LoadPolicy('policy-1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(LoadPolicy('policy-2'));
        },
        skip: 2, // Skip first policy load states
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyLoaded>().having((state) => state.policy.id, 'policy.id', 'policy-2'),
        ],
      );

      blocTest<PolicyBloc, PolicyState>(
        'handles load followed by refresh correctly',
        build: () {
          final initialPolicy = mockPolicy;
          
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => Right(initialPolicy));
          return policyBloc;
        },
        act: (bloc) async {
          bloc.add(LoadPolicy('privacy-policy'));
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Update the mock for refresh
          when(() => mockGetPolicyUseCase.execute('privacy-policy'))
              .thenAnswer((_) async => Right(Policy(
                id: 'privacy-policy',
                title: 'Privacy Policy',
                content: 'Refreshed content',
                lastUpdated: DateTime(2023, 12, 15),
                version: '1.1.0',
              )));
          
          bloc.add(RefreshPolicy('privacy-policy'));
        },
        expect: () => [
          isA<PolicyLoading>(),
          isA<PolicyLoaded>().having((state) => state.policy.version, 'version', '1.0.0'),
          isA<PolicyLoaded>().having((state) => state.policy.version, 'version', '1.1.0'),
        ],
      );
    });

    group('Use case interaction', () {
      test('calls GetPolicyUseCase with correct parameters', () async {
        when(() => mockGetPolicyUseCase.execute('test-policy'))
            .thenAnswer((_) async => Right(mockPolicy));

        policyBloc.add(LoadPolicy('test-policy'));
        
        await untilCalled(() => mockGetPolicyUseCase.execute('test-policy'));
        
        verify(() => mockGetPolicyUseCase.execute('test-policy')).called(1);
      });

      test('calls GetPolicyUseCase for refresh with correct parameters', () async {
        when(() => mockGetPolicyUseCase.execute('test-policy'))
            .thenAnswer((_) async => Right(mockPolicy));

        policyBloc.add(RefreshPolicy('test-policy'));
        
        await untilCalled(() => mockGetPolicyUseCase.execute('test-policy'));
        
        verify(() => mockGetPolicyUseCase.execute('test-policy')).called(1);
      });
    });
  });
}
