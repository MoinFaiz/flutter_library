import 'package:get_it/get_it.dart';

import 'package:flutter_library/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_library/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_library/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_email_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_phone_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/verify_phone_number_usecase.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void initProfileDependencies() {
  // Data source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteAvatarUseCase(repository: sl()));
  sl.registerLazySingleton(() => SendEmailVerificationUseCase(repository: sl()));
  sl.registerLazySingleton(() => SendPhoneVerificationUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerifyPhoneNumberUseCase(repository: sl()));

  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateAvatarUseCase: sl(),
      deleteAvatarUseCase: sl(),
      sendEmailVerificationUseCase: sl(),
      sendPhoneVerificationUseCase: sl(),
      verifyPhoneNumberUseCase: sl(),
    ),
  );
}
