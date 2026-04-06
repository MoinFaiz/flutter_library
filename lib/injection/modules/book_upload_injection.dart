import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource.dart';
import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource_impl.dart';
import 'package:flutter_library/features/book_upload/data/repositories/book_upload_repository_impl.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/search_books_for_upload_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_book_by_isbn_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_copy_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_image_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_metadata_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/update_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/update_copy_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/delete_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/delete_copy_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_user_books_usecase.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';

final sl = GetIt.instance;

void initBookUploadDependencies() {
  // Data source
  sl.registerLazySingleton<BookUploadRemoteDataSource>(
    () => BookUploadRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<BookUploadRepository>(
    () => BookUploadRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchBooksForUploadUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetBookByIsbnUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadCopyUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadImageUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetGenresUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetLanguagesUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateCopyUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteCopyUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUserBooksUseCase(repository: sl()));

  // BLoC
  sl.registerFactory(
    () => BookUploadBloc(
      searchBooksUseCase: sl(),
      getBookByIsbnUseCase: sl(),
      uploadBookUseCase: sl(),
      uploadImageUseCase: sl(),
      getGenresUseCase: sl(),
      getLanguagesUseCase: sl(),
    ),
  );
}
