import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import '../entities/policy.dart';
import '../repositories/policy_repository.dart';

/// Use case for getting a policy document
class GetPolicyUseCase {
  final PolicyRepository _repository;

  GetPolicyUseCase(this._repository);

  /// Returns the policy — from valid cache if available, otherwise from the server.
  Future<Either<Failure, Policy>> execute(String policyId) async {
    // Check cache first
    final cachedResult = await _repository.getCachedPolicy(policyId);
    final cachedPolicy = cachedResult.fold((_) => null, (p) => p);

    if (cachedPolicy != null) {
      final expiredResult = await _repository.isCacheExpired(policyId);
      final isExpired = expiredResult.fold((_) => true, (v) => v);

      if (!isExpired) {
        return Right(cachedPolicy);
      }
    }

    // Fetch from server
    final policyResult = await _repository.getPolicy(policyId);

    // Cache on success (ignore cache write errors — policy is still usable)
    policyResult.fold(
      (_) {},
      (policy) => _repository.cachePolicy(policy),
    );

    return policyResult;
  }
}

