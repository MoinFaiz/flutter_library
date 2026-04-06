import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/policies/data/datasources/policy_local_datasource.dart';
import 'package:flutter_library/features/policies/data/datasources/policy_remote_datasource.dart';
import 'package:flutter_library/features/policies/data/repositories/policy_repository_impl.dart';
import 'package:flutter_library/features/policies/domain/repositories/policy_repository.dart';
import 'package:flutter_library/features/policies/domain/usecases/get_policy_usecase.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_bloc.dart';

final sl = GetIt.instance;

void initPoliciesDependencies() {
  // Data sources
  sl.registerLazySingleton<PolicyRemoteDataSource>(
    () => PolicyRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<PolicyLocalDataSource>(
    () => PolicyLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(sl(), sl()),
  );

  // Use case
  sl.registerLazySingleton(() => GetPolicyUseCase(sl()));

  // BLoC
  sl.registerFactory(() => PolicyBloc(sl()));
}
