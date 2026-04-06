import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:flutter_library/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:flutter_library/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_books_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_ids_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_bloc.dart';

final sl = GetIt.instance;

void initFavoritesDependencies() {
  // Data sources
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetFavoriteBooksUseCase(
      bookRepository: sl(),
      favoritesRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => GetFavoriteIdsUseCase(favoritesRepository: sl()),
  );
  sl.registerLazySingleton(
    () => ToggleFavoriteUseCase(favoritesRepository: sl()),
  );

  // BLoC
  sl.registerFactory(
    () => FavoritesBloc(
      getFavoriteBooksUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );
}
