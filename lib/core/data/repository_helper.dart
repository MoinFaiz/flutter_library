import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/error_handler.dart';
import 'package:flutter_library/core/error/failures.dart';

/// Common utilities for repository implementations
class RepositoryHelper {
  /// Handles cache validation and fetching pattern
  static Future<Either<Failure, List<T>>> handleCachedFetch<T>(
    Future<bool> Function() isCacheValid,
    Future<List<T>> Function() getCachedData,
    Future<List<T>> Function() getRemoteData,
    Future<void> Function(List<T> data) cacheData,
  ) async {
    return await ErrorHandler.safeExecute(() async {
      // Check cache validity
      final isValid = await isCacheValid();
      
      if (isValid) {
        try {
          return await getCachedData();
        } catch (e) {
          // If cache fails, continue to remote fetch
        }
      }
      
      // Fetch from remote
      final remoteData = await getRemoteData();
      
      // Cache the data
      await cacheData(remoteData);
      
      return remoteData;
    });
  }

  /// Handles data with favorites pattern
  static Future<List<T>> applyDataTransformation<T>(
    List<T> data,
    Future<List<T>> Function(List<T> data) transform,
  ) async {
    return await transform(data);
  }

  /// Handles toggle operations with server sync
  static Future<Either<Failure, T>> handleToggleOperation<T>(
    Future<bool> Function() getCurrentStatus,
    Future<void> Function(bool newStatus) updateRemote,
    Future<void> Function() updateLocal,
    Future<void> Function() invalidateCache,
    Future<T> Function() getUpdatedData,
  ) async {
    return await ErrorHandler.safeExecute(() async {
      // Get current status
      final currentStatus = await getCurrentStatus();
      final newStatus = !currentStatus;
      
      // Update remote first
      await updateRemote(newStatus);
      
      // Update local as backup
      await updateLocal();
      
      // Invalidate cache
      await invalidateCache();
      
      // Return updated data
      return await getUpdatedData();
    });
  }
}
