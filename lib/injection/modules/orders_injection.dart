import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter_library/features/orders/data/datasources/order_remote_datasource_impl.dart';
import 'package:flutter_library/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter_library/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_order_history_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_user_orders_usecase.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_bloc.dart';

final sl = GetIt.instance;

void initOrdersDependencies() {
  // Data source
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetActiveOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetOrderHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(repository: sl()));

  // BLoC
  sl.registerFactory(
    () => OrdersBloc(
      getUserOrdersUseCase: sl(),
      getActiveOrdersUseCase: sl(),
      getOrderHistoryUseCase: sl(),
      cancelOrderUseCase: sl(),
    ),
  );
}
