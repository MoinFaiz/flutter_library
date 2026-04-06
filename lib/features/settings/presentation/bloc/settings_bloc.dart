import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/settings/domain/usecases/get_theme_mode_usecase.dart';
import 'package:flutter_library/features/settings/domain/usecases/set_theme_mode_usecase.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetThemeModeUseCase getThemeModeUseCase;
  final SetThemeModeUseCase setThemeModeUseCase;

  SettingsBloc({
    required this.getThemeModeUseCase,
    required this.setThemeModeUseCase,
  }) : super(const SettingsState()) {
    on<LoadThemeMode>(_onLoadThemeMode);
    on<ChangeThemeMode>(_onChangeThemeMode);
  }

  Future<void> _onLoadThemeMode(
    LoadThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await getThemeModeUseCase();
    result.fold(
      (_) => emit(const SettingsState()),
      (mode) => emit(state.copyWith(themeMode: mode)),
    );
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.mode));
    await setThemeModeUseCase(event.mode);
  }
}
