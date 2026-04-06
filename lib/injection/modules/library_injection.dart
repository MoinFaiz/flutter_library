import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/library/data/datasources/library_remote_datasource.dart';
import 'package:flutter_library/features/library/data/datasources/library_remote_datasource_impl.dart';
import 'package:flutter_library/features/library/data/repositories/library_repository_impl.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';

final sl = GetIt.instance;

void initLibraryDependencies() {
  // Data source
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBorrowedBooksUseCase(sl()));
  sl.registerLazySingleton(() => GetAllBorrowedBooksUseCase(sl()));
  sl.registerLazySingleton(() => GetUploadedBooksUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUploadedBooksUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => LibraryBloc(
      getBorrowedBooksUseCase: sl(),
      getUploadedBooksUseCase: sl(),
    ),
  );
}
