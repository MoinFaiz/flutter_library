import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/usecase/usecase.dart';
import 'package:flutter_library/features/settings/domain/repositories/theme_repository.dart';

class GetThemeModeUseCase extends UseCase<ThemeMode, NoParams> {
  final ThemeRepository repository;

  GetThemeModeUseCase(this.repository);

  @override
  Future<Either<Failure, ThemeMode>> call([NoParams? params]) =>
      repository.getThemeMode();
}
