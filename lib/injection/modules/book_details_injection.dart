import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/book_details/data/datasources/book_operations_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/repositories/book_operations_repository_impl.dart';
import 'package:flutter_library/features/book_details/data/repositories/rental_status_repository_impl.dart';
import 'package:flutter_library/features/book_details/data/repositories/reviews_repository_impl.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';
import 'package:flutter_library/features/book_details/domain/repositories/rental_status_repository.dart';
import 'package:flutter_library/features/book_details/domain/repositories/reviews_repository.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/delete_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_reviews_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_user_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/report_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_rating_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/submit_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/update_review_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/vote_review_usecase.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';

final sl = GetIt.instance;

void initBookDetailsDependencies() {
  // Data sources
  sl.registerLazySingleton<BookOperationsRemoteDataSource>(
    () => BookOperationsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RentalStatusLocalDataSource>(
    () => RentalStatusLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<RentalStatusRemoteDataSource>(
    () => RentalStatusRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ReviewsLocalDataSource>(
    () => ReviewsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<BookOperationsRepository>(
    () => BookOperationsRepositoryImpl(
      remoteDataSource: sl(),
      rentalStatusLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<RentalStatusRepository>(
    () => RentalStatusRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => RentBookUseCase(repository: sl<BookOperationsRepository>()));
  sl.registerLazySingleton(() => BuyBookUseCase(repository: sl<BookOperationsRepository>()));
  sl.registerLazySingleton(() => ReturnBookUseCase(repository: sl<BookOperationsRepository>()));
  sl.registerLazySingleton(() => RenewBookUseCase(repository: sl<BookOperationsRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(repository: sl<BookOperationsRepository>()));
  sl.registerLazySingleton(() => GetRentalStatusUseCase(repository: sl<RentalStatusRepository>()));
  sl.registerLazySingleton(() => GetReviewsUseCase(repository: sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => UpdateReviewUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => DeleteReviewUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => SubmitRatingUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => GetUserRatingUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => VoteReviewUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => ReportReviewUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton(() => GetUserReviewUseCase(sl<ReviewsRepository>()));

  // BLoCs
  sl.registerFactory(
    () => BookDetailsBloc(
      getBookByIdUseCase: sl(),
      rentBookUseCase: sl(),
      buyBookUseCase: sl(),
      returnBookUseCase: sl(),
      renewBookUseCase: sl(),
      removeFromCartUseCase: sl(),
      getRentalStatusUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReviewsBloc(
      getReviewsUseCase: sl(),
      submitReviewUseCase: sl(),
      updateReviewUseCase: sl(),
      deleteReviewUseCase: sl(),
      submitRatingUseCase: sl(),
      getUserRatingUseCase: sl(),
      voteReviewUseCase: sl(),
      reportReviewUseCase: sl(),
      getUserReviewUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RentalStatusBloc(
      getRentalStatusUseCase: sl(),
      rentBookUseCase: sl(),
      buyBookUseCase: sl(),
      returnBookUseCase: sl(),
      renewBookUseCase: sl(),
      removeFromCartUseCase: sl(),
    ),
  );
}
