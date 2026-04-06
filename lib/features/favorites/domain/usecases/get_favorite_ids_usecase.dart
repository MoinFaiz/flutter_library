import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/usecase/usecase.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';

/// Returns the set of book IDs the current user has favorited.
/// Used by presentation-layer BLoCs to enrich book lists with favorite status.
class GetFavoriteIdsUseCase extends UseCase<Set<String>, NoParams> {
  final FavoritesRepository favoritesRepository;

  GetFavoriteIdsUseCase({required this.favoritesRepository});

  @override
  Future<Either<Failure, Set<String>>> call([NoParams? params]) async {
    final result = await favoritesRepository.getFavoriteBookIds();
    return result.map((ids) => ids.toSet());
  }
}
