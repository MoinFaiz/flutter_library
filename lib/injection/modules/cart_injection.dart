import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource_impl.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource_impl.dart';
import 'package:flutter_library/features/cart/data/repositories/cart_notification_repository_impl.dart';
import 'package:flutter_library/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_notifications_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_total_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_received_requests_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_unread_notifications_count_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/mark_notification_as_read_usecase.dart' as cart_notif;
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/remove_from_cart_usecase.dart' as cart_remove;
import 'package:flutter_library/features/cart/domain/usecases/send_purchase_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_rental_request_usecase.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_bloc.dart';

final sl = GetIt.instance;

void initCartDependencies() {
  // Data sources
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<CartNotificationRemoteDataSource>(
    () => CartNotificationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CartNotificationLocalDataSource>(
    () => CartNotificationLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CartNotificationRepository>(
    () => CartNotificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCartItemsUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(repository: sl()));
  sl.registerLazySingleton(() => cart_remove.RemoveFromCartUseCase(repository: sl()));
  sl.registerLazySingleton(() => SendRentalRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => SendPurchaseRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => AcceptRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => RejectRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetReceivedRequestsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCartTotalUseCase(repository: sl()));
  sl.registerLazySingleton(() => AcceptCartRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectCartRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetCartNotificationsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsCountUseCase(repository: sl()));
  sl.registerLazySingleton(() => cart_notif.MarkNotificationAsReadUseCase(repository: sl()));

  // BLoCs
  sl.registerFactory(
    () => CartBloc(
      getCartItemsUseCase: sl(),
      addToCartUseCase: sl(),
      removeFromCartUseCase: sl(),
      sendRentalRequestUseCase: sl(),
      sendPurchaseRequestUseCase: sl(),
      getReceivedRequestsUseCase: sl(),
      acceptRequestUseCase: sl(),
      rejectRequestUseCase: sl(),
      getCartTotalUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CartNotificationBloc(
      getCartNotificationsUseCase: sl(),
      getUnreadNotificationsCountUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
    ),
  );
}
