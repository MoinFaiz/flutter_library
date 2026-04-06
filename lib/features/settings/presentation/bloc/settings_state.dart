import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;

  const SettingsState({this.themeMode = ThemeMode.system});

  SettingsState copyWith({ThemeMode? themeMode}) =>
      SettingsState(themeMode: themeMode ?? this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
