import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/settings/domain/repositories/theme_repository.dart';

class SetThemeModeUseCase {
  final ThemeRepository repository;

  SetThemeModeUseCase(this.repository);

  Future<Either<Failure, void>> call(ThemeMode mode) =>
      repository.setThemeMode(mode);
}
