import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';

/// Use case for toggling favorite status of a book.
/// Returns the new isFavorite status (true = added, false = removed).
class ToggleFavoriteUseCase {
  final FavoritesRepository favoritesRepository;

  ToggleFavoriteUseCase({required this.favoritesRepository});

  Future<Either<Failure, bool>> call(String bookId) async {
    try {
      final idsResult = await favoritesRepository.getFavoriteBookIds();

      return await idsResult.fold(
        (failure) async => Left(failure),
        (ids) async {
          final isCurrentlyFavorite = ids.contains(bookId);
          final Either<Failure, void> toggleResult;

          if (isCurrentlyFavorite) {
            toggleResult = await favoritesRepository.removeFromFavorites(bookId);
          } else {
            toggleResult = await favoritesRepository.addToFavorites(bookId);
          }

          return toggleResult.map((_) => !isCurrentlyFavorite);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to toggle favorite: ${e.toString()}'));
    }
  }
}
