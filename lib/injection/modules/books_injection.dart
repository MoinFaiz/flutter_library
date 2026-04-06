import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/home/data/datasources/book_local_datasource.dart';
import 'package:flutter_library/features/home/data/datasources/book_remote_datasource.dart';
import 'package:flutter_library/features/home/data/repositories/book_repository_impl.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';
import 'package:flutter_library/features/home/domain/usecases/get_books_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/get_book_by_id_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/search_books_usecase.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

void initBooksDependencies() {
  // Data sources
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBooksUseCase(bookRepository: sl()));
  sl.registerLazySingleton(() => SearchBooksUseCase(bookRepository: sl()));
  sl.registerLazySingleton(() => GetBookByIdUseCase(repository: sl()));

  // BLoC
  sl.registerFactory(
    () => HomeBloc(
      getBooksUseCase: sl(),
      searchBooksUseCase: sl(),
      toggleFavoriteUseCase: sl(),
      getFavoriteIdsUseCase: sl(),
    ),
  );
}
