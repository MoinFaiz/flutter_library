import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/book_details/domain/repositories/rental_status_repository.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';

/// Implementation of RentalStatusRepository
class RentalStatusRepositoryImpl implements RentalStatusRepository {
  final RentalStatusRemoteDataSource remoteDataSource;
  final RentalStatusLocalDataSource localDataSource;

  RentalStatusRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, RentalStatus>> getRentalStatus(String bookId) async {
    try {
      // Clear expired cache first
      await localDataSource.clearExpiredCache();
      
      // Try to get from cache first
      final cachedStatus = await localDataSource.getCachedRentalStatus(bookId);
      if (cachedStatus != null) {
        return Right(cachedStatus);
      }
      
      // If not in cache, fetch from remote
      final status = await remoteDataSource.getRentalStatus(bookId);
      
      // Cache the result with shorter TTL for rental status (3 minutes)
      await localDataSource.cacheRentalStatus(status, ttl: const Duration(minutes: 3));
      
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rental status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RentalStatus>>> getRentalStatusBatch(List<String> bookIds) async {
    try {
      if (bookIds.isEmpty) {
        return const Right([]);
      }
      
      // Clear expired cache first
      await localDataSource.clearExpiredCache();
      
      // Try to get from cache first
      final cachedStatuses = await localDataSource.getCachedRentalStatusBatch(bookIds);
      final cachedBookIds = cachedStatuses.map((s) => s.bookId).toSet();
      final remainingBookIds = bookIds.where((id) => !cachedBookIds.contains(id)).toList();
      
      List<RentalStatusModel> allStatuses = List.from(cachedStatuses);
      
      // Fetch remaining from remote
      if (remainingBookIds.isNotEmpty) {
        final remoteStatuses = await remoteDataSource.getRentalStatusBatch(remainingBookIds);
        
        // Cache the remote results with shorter TTL
        for (final status in remoteStatuses) {
          await localDataSource.cacheRentalStatus(status, ttl: const Duration(minutes: 3));
        }
        
        allStatuses.addAll(remoteStatuses);
      }
      
      return Right(allStatuses);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rental status batch: $e'));
    }
  }

  @override
  Future<Either<Failure, RentalStatus>> updateRentalStatus(RentalStatus status) async {
    try {
      // Convert to model for data source
      final statusModel = _convertToModel(status);
      final updatedStatus = await remoteDataSource.updateRentalStatus(statusModel);
      
      // Invalidate cache for this book and update with new status
      await localDataSource.clearCacheForBook(status.bookId);
      await localDataSource.cacheRentalStatus(updatedStatus, ttl: const Duration(minutes: 3));
      
      return Right(updatedStatus);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update rental status: $e'));
    }
  }

  /// Invalidate cache for a specific book
  Future<void> invalidateCacheForBook(String bookId) async {
    await localDataSource.clearCacheForBook(bookId);
  }

  /// Invalidate all cached rental statuses
  Future<void> invalidateAllCache() async {
    await localDataSource.clearCache();
  }

  /// Convert RentalStatus entity to RentalStatusModel
  RentalStatusModel _convertToModel(RentalStatus status) {
    return RentalStatusModel(
      bookId: status.bookId,
      status: status.status,
      dueDate: status.dueDate,
      rentedDate: status.rentedDate,
      returnDate: status.returnDate,
      daysRemaining: status.daysRemaining,
      canRenew: status.canRenew,
      isInCart: status.isInCart,
      isPurchased: status.isPurchased,
      lateFee: status.lateFee,
      notes: status.notes,
    );
  }
}
