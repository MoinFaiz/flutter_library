import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_library/core/network/network_info.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/navigation/navigation_service_impl.dart';

import 'package:flutter_library/core/logging/data/datasources/logging_local_data_source.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_local_data_source_impl.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_remote_data_source.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_remote_data_source_impl.dart';
import 'package:flutter_library/core/logging/data/repositories/logging_repository_impl.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/fetch_logging_config.dart';
import 'package:flutter_library/core/logging/domain/usecases/log_message.dart';
import 'package:flutter_library/core/logging/domain/usecases/sync_logs.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_audit_event.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_performance.dart';
import 'package:flutter_library/core/network/api_client.dart';

import 'package:flutter_library/core/logging/services/app_logger.dart';
import 'package:flutter_library/core/logging/services/logging_config_service.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP client — single source of truth for base URL, timeouts, and interceptors
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // Network
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Navigation
  sl.registerLazySingleton<NavigationService>(() => NavigationServiceImpl());

  // Logging — data sources
  sl.registerLazySingleton<LoggingLocalDataSource>(
    () => LoggingLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<LoggingRemoteDataSource>(
    () => LoggingRemoteDataSourceImpl(dio: sl()),
  );

  // Logging — repository
  sl.registerLazySingleton<LoggingRepository>(
    () => LoggingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Logging — use cases
  sl.registerLazySingleton(() => LogMessage(sl()));
  sl.registerLazySingleton(() => TrackAuditEvent(sl()));
  sl.registerLazySingleton(() => TrackPerformance(sl()));
  sl.registerLazySingleton(() => SyncLogs(sl()));
  sl.registerLazySingleton(() => FetchLoggingConfig(sl()));

  // Logging — services
  sl.registerLazySingleton(
    () => AppLogger(
      logMessage: sl(),
      trackAuditEvent: sl(),
      trackPerformance: sl(),
      repository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => LoggingConfigService(
      fetchConfig: sl(),
      syncLogs: sl(),
    ),
  );
}
