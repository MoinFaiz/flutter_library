import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/error/failures.dart';

abstract class ThemeRepository {
  Future<Either<Failure, ThemeMode>> getThemeMode();
  Future<Either<Failure, void>> setThemeMode(ThemeMode mode);
}
