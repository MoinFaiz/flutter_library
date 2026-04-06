import 'package:flutter/material.dart';

abstract class ThemeLocalDataSource {
  ThemeMode getCachedThemeMode();
  Future<void> cacheThemeMode(ThemeMode mode);
}
