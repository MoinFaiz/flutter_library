import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/settings/data/datasources/theme_local_datasource.dart';
import 'package:flutter_library/features/settings/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final mode = localDataSource.getCachedThemeMode();
      return Right(mode);
    } catch (e) {
      return const Right(ThemeMode.system);
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode) async {
    try {
      await localDataSource.cacheThemeMode(mode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save theme: ${e.toString()}'));
    }
  }
}
