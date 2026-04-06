import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/policies/domain/usecases/get_policy_usecase.dart';
import 'package:flutter_library/features/policies/domain/repositories/policy_repository.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockPolicyRepository extends Mock implements PolicyRepository {}

void main() {
  group('GetPolicyUseCase', () {
    late GetPolicyUseCase useCase;
    late MockPolicyRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(Policy(
        id: 'test',
        title: 'test',
        content: 'test',
        version: '1.0',
        lastUpdated: DateTime.now(),
      ));
    });

    setUp(() {
      mockRepository = MockPolicyRepository();
      useCase = GetPolicyUseCase(mockRepository);
    });

    const tPolicyId = 'privacy_policy';
    
    final tPolicy = Policy(
      id: 'privacy_policy',
      title: 'Privacy Policy',
      content: 'This is our privacy policy content...',
      version: '1.0',
      lastUpdated: DateTime(2023, 1, 1),
    );

    test('should get policy from repository when successful', () async {
      // arrange
      when(() => mockRepository.getCachedPolicy(tPolicyId))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.getPolicy(tPolicyId))
          .thenAnswer((_) async => Right(tPolicy));
      when(() => mockRepository.cachePolicy(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase.execute(tPolicyId);

      // assert
      verify(() => mockRepository.getCachedPolicy(tPolicyId));
      verify(() => mockRepository.getPolicy(tPolicyId));
      verify(() => mockRepository.cachePolicy(any()));
      final policy = result.getOrElse(() => throw Exception('Expected Right'));
      expect(policy.id, equals(tPolicy.id));
      expect(policy.title, equals(tPolicy.title));
      expect(policy.content, equals(tPolicy.content));
    });

    test('should return cached policy when valid cache exists', () async {
      // arrange
      when(() => mockRepository.getCachedPolicy(tPolicyId))
          .thenAnswer((_) async => Right(tPolicy));
      when(() => mockRepository.isCacheExpired(tPolicyId))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase.execute(tPolicyId);

      // assert
      verify(() => mockRepository.getCachedPolicy(tPolicyId));
      verify(() => mockRepository.isCacheExpired(tPolicyId));
      verifyNever(() => mockRepository.getPolicy(any()));
      expect(result, equals(Right(tPolicy)));
    });

    test('should fetch from server when cache is expired', () async {
      // arrange
      when(() => mockRepository.getCachedPolicy(tPolicyId))
          .thenAnswer((_) async => Right(tPolicy));
      when(() => mockRepository.isCacheExpired(tPolicyId))
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.getPolicy(tPolicyId))
          .thenAnswer((_) async => Right(tPolicy));
      when(() => mockRepository.cachePolicy(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase.execute(tPolicyId);

      // assert
      verify(() => mockRepository.getCachedPolicy(tPolicyId));
      verify(() => mockRepository.isCacheExpired(tPolicyId));
      verify(() => mockRepository.getPolicy(tPolicyId));
      verify(() => mockRepository.cachePolicy(any()));
      expect(result, equals(Right(tPolicy)));
    });

    test('should return failure when repository fails and no cache available', () async {
      // arrange
      when(() => mockRepository.getCachedPolicy(tPolicyId))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.getPolicy(tPolicyId))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Policy not found')));

      // act
      final result = await useCase.execute(tPolicyId);

      // assert
      verify(() => mockRepository.getCachedPolicy(tPolicyId));
      verify(() => mockRepository.getPolicy(tPolicyId));
      expect(result, isA<Left>());
    });
  });
}