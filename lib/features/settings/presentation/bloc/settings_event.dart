import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeMode extends SettingsEvent {
  const LoadThemeMode();
}

class ChangeThemeMode extends SettingsEvent {
  final ThemeMode mode;

  const ChangeThemeMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
