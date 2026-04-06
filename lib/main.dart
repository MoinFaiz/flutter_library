import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/theme/app_theme.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/route_generator.dart';
import 'package:flutter_library/core/navigation/navigation_service_impl.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_library/injection/injection_container.dart';
import 'package:flutter_library/core/logging/services/logging_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Start logging service
  final loggingService = sl<LoggingConfigService>();
  await loggingService.start();
  
  runApp(const FlutterLibraryApp());
}

class FlutterLibraryApp extends StatelessWidget {
  const FlutterLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<CartBloc>()..add(LoadCartItems()),
        ),
        BlocProvider(
          create: (context) => sl<SettingsBloc>()..add(const LoadThemeMode()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) => MaterialApp(
          title: 'Flutter Library',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsState.themeMode,
          navigatorKey: NavigationServiceImpl.navigatorKey,
          initialRoute: AppRoutes.main,
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
