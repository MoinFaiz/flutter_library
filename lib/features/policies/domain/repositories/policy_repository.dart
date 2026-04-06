import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import '../entities/policy.dart';

/// Repository interface for policy operations
abstract class PolicyRepository {
  /// Get a policy by its ID. Returns [Left] with a [Failure] on any error.
  Future<Either<Failure, Policy>> getPolicy(String policyId);

  /// Get cached policy if available. Returns [Left] with a [Failure] on error,
  /// [Right(null)] when no cached policy exists.
  Future<Either<Failure, Policy?>> getCachedPolicy(String policyId);

  /// Cache a policy locally.
  Future<Either<Failure, void>> cachePolicy(Policy policy);

  /// Clear all cached policies.
  Future<Either<Failure, void>> clearCache();

  /// Returns true if the cached policy is expired (or absent).
  Future<Either<Failure, bool>> isCacheExpired(String policyId);
}
