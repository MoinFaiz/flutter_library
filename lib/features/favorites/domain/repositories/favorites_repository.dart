import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';

/// Repository interface for favorites management
/// Handles both local persistence and remote synchronization
abstract class FavoritesRepository {
  Future<Either<Failure, List<String>>> getFavoriteBookIds();
  Future<Either<Failure, void>> addToFavorites(String bookId);
  Future<Either<Failure, void>> removeFromFavorites(String bookId);
  
  // Favorites cache management
  Future<Either<Failure, void>> invalidateFavoritesCache();
  Future<Either<Failure, bool>> isFavoritesCacheValid();
}
