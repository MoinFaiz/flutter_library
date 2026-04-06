import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/error_handler.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<String>>> getFavoriteBookIds() async {
    try {
      final favoriteIds = await localDataSource.getFavoriteBookIds();
      return Right(favoriteIds);
    } on CacheException {
      return const Left(CacheFailure('Failed to get favorite book IDs'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String bookId) async {
    try {
      // Update local first for immediate response
      await localDataSource.addToFavorites(bookId);
      
      // Sync with remote in background (fire and forget for better UX)
      // In production, you might want to handle remote failures and retry
      remoteDataSource.addToFavorites(bookId).catchError((error) {
        // Log error but don't fail the operation
        // Could implement retry logic or queue for later sync
        // Debug logging - consider using a proper logging framework in production
        // print('Failed to sync add favorite to server: $error');
      });
      
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to add to favorites'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String bookId) async {
    try {
      // Update local first for immediate response
      await localDataSource.removeFromFavorites(bookId);
      
      // Sync with remote in background (fire and forget for better UX)
      remoteDataSource.removeFromFavorites(bookId).catchError((error) {
        // Log error but don't fail the operation
        // Debug logging - consider using a proper logging framework in production
        // print('Failed to sync remove favorite to server: $error');
      });
      
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to remove from favorites'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> invalidateFavoritesCache() async {
    return await ErrorHandler.safeExecute(() async {
      await localDataSource.invalidateFavoritesCache();
    });
  }

  @override
  Future<Either<Failure, bool>> isFavoritesCacheValid() async {
    return await ErrorHandler.safeExecute(() async {
      return await localDataSource.isFavoritesCacheValid();
    });
  }
}
