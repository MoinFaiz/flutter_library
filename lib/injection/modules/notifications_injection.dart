import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource_impl.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:flutter_library/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_library/features/notifications/domain/usecases/accept_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/reject_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/services/pending_request_service.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';

final sl = GetIt.instance;

void initNotificationsDependencies() {
  // Data sources
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => WatchNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptBookRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectBookRequestUseCase(sl()));

  // Service (depends on cart — registered after cart module)
  sl.registerLazySingleton(() => PendingRequestService(
        cartRepository: sl(),
        acceptCartRequestUseCase: sl(),
        rejectCartRequestUseCase: sl(),
      ));

  // BLoC
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
      deleteNotificationUseCase: sl(),
      watchNotificationsUseCase: sl(),
      acceptBookRequestUseCase: sl(),
      rejectBookRequestUseCase: sl(),
      acceptCartRequestUseCase: sl(),
      rejectCartRequestUseCase: sl(),
    ),
  );
}
