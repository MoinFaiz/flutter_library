import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import '../../domain/entities/policy.dart';
import '../../domain/repositories/policy_repository.dart';
import '../datasources/policy_local_datasource.dart';
import '../datasources/policy_remote_datasource.dart';
import '../models/policy_model.dart';

/// Implementation of policy repository
class PolicyRepositoryImpl implements PolicyRepository {
  final PolicyRemoteDataSource _remoteDataSource;
  final PolicyLocalDataSource _localDataSource;

  PolicyRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, Policy>> getPolicy(String policyId) async {
    try {
      final policyModel = await _remoteDataSource.getPolicy(policyId);
      return Right(policyModel.toEntity());
    } catch (remoteError) {
      // Remote failed — try cache fallback
      try {
        final policyModel = await _localDataSource.getCachedPolicy(policyId);
        if (policyModel != null) {
          return Right(policyModel.toEntity());
        }
      } catch (_) {
        // Cache read also failed — fall through to failure
      }
      return Left(ServerFailure(message: 'Failed to load policy: $remoteError'));
    }
  }

  @override
  Future<Either<Failure, Policy?>> getCachedPolicy(String policyId) async {
    try {
      final policyModel = await _localDataSource.getCachedPolicy(policyId);
      return Right(policyModel?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to read cached policy: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cachePolicy(Policy policy) async {
    try {
      final policyModel = PolicyModel.fromEntity(policy);
      await _localDataSource.cachePolicy(policyModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache policy: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear policy cache: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCacheExpired(String policyId) async {
    try {
      return Right(await _localDataSource.isCacheExpired(policyId));
    } catch (e) {
      return const Right(true); // Treat error as expired
    }
  }
}

