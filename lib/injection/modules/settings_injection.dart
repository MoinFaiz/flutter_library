import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/settings/data/datasources/theme_local_datasource.dart';
import 'package:flutter_library/features/settings/data/datasources/theme_local_datasource_impl.dart';
import 'package:flutter_library/features/settings/data/repositories/theme_repository_impl.dart';
import 'package:flutter_library/features/settings/domain/repositories/theme_repository.dart';
import 'package:flutter_library/features/settings/domain/usecases/get_theme_mode_usecase.dart';
import 'package:flutter_library/features/settings/domain/usecases/set_theme_mode_usecase.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

void initSettingsDependencies() {
  // Data source
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => SetThemeModeUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => SettingsBloc(
      getThemeModeUseCase: sl(),
      setThemeModeUseCase: sl(),
    ),
  );
}
