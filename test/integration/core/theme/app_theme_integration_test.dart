import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/theme/app_theme.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_theme_extension.dart';

void main() {
  group('AppTheme Tests', () {
    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.lightTheme;
      });

      test('should have correct brightness', () {
        expect(lightTheme.brightness, equals(Brightness.light));
      });

      test('should use Material 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('should have correct primary colors', () {
        expect(lightTheme.colorScheme.primary, equals(AppColors.primaryLight));
        expect(lightTheme.colorScheme.onPrimary, equals(AppColors.onPrimaryLight));
      });

      test('should have correct secondary colors', () {
        expect(lightTheme.colorScheme.secondary, equals(AppColors.secondaryLight));
        expect(lightTheme.colorScheme.onSecondary, equals(AppColors.onSecondaryLight));
      });

      test('should have correct surface colors', () {
        expect(lightTheme.colorScheme.surface, equals(AppColors.surfaceLight));
        expect(lightTheme.colorScheme.onSurface, equals(AppColors.onSurfaceLight));
      });

      test('should have correct error colors', () {
        expect(lightTheme.colorScheme.error, equals(AppColors.errorLight));
        expect(lightTheme.colorScheme.onError, equals(AppColors.onErrorLight));
      });

      test('should have app theme extension', () {
        final extension = lightTheme.extension<AppThemeExtension>();
        expect(extension, isNotNull);
        expect(extension, equals(AppThemeExtension.light));
      });

      test('should have correct app bar theme', () {
        final appBarTheme = lightTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, equals(AppColors.primaryLight));
        expect(appBarTheme.foregroundColor, equals(AppColors.onPrimaryLight));
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.centerTitle, isTrue);
      });

      test('should have correct card theme', () {
        final cardTheme = lightTheme.cardTheme;
        expect(cardTheme.elevation, equals(4));
        expect(cardTheme.shadowColor, equals(AppColors.cardShadow));
      });

      test('should have correct elevated button theme', () {
        final buttonTheme = lightTheme.elevatedButtonTheme;
        expect(buttonTheme, isNotNull);
        
        final style = buttonTheme.style;
        expect(style, isNotNull);
        
        // Check button colors
        final backgroundColor = style!.backgroundColor?.resolve({});
        final foregroundColor = style.foregroundColor?.resolve({});
        expect(backgroundColor, equals(AppColors.primaryLight));
        expect(foregroundColor, equals(AppColors.onPrimaryLight));
        
        // Check elevation
        final elevation = style.elevation?.resolve({});
        expect(elevation, equals(2));
        
        // Check shape
        final shape = style.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
      });

      test('should have correct input decoration theme', () {
        final inputTheme = lightTheme.inputDecorationTheme;
        expect(inputTheme, isNotNull);
        
        expect(inputTheme.border, isA<OutlineInputBorder>());
        expect(inputTheme.focusedBorder, isA<OutlineInputBorder>());
      });
    });

    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.darkTheme;
      });

      test('should have correct brightness', () {
        expect(darkTheme.brightness, equals(Brightness.dark));
      });

      test('should use Material 3', () {
        expect(darkTheme.useMaterial3, isTrue);
      });

      test('should have correct primary colors', () {
        expect(darkTheme.colorScheme.primary, equals(AppColors.primaryDark));
        expect(darkTheme.colorScheme.onPrimary, equals(AppColors.onPrimaryDark));
      });

      test('should have correct secondary colors', () {
        expect(darkTheme.colorScheme.secondary, equals(AppColors.secondaryDark));
        expect(darkTheme.colorScheme.onSecondary, equals(AppColors.onSecondaryDark));
      });

      test('should have correct surface colors', () {
        expect(darkTheme.colorScheme.surface, equals(AppColors.surfaceDark));
        expect(darkTheme.colorScheme.onSurface, equals(AppColors.onSurfaceDark));
      });

      test('should have correct error colors', () {
        expect(darkTheme.colorScheme.error, equals(AppColors.errorDark));
        expect(darkTheme.colorScheme.onError, equals(AppColors.onErrorDark));
      });

      test('should have app theme extension', () {
        final extension = darkTheme.extension<AppThemeExtension>();
        expect(extension, isNotNull);
        expect(extension, equals(AppThemeExtension.dark));
      });

      test('should have correct app bar theme', () {
        final appBarTheme = darkTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, equals(AppColors.surfaceDark));
        expect(appBarTheme.foregroundColor, equals(AppColors.onSurfaceDark));
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.centerTitle, isTrue);
      });

      test('should have correct card theme', () {
        final cardTheme = darkTheme.cardTheme;
        expect(cardTheme.elevation, equals(4));
        expect(cardTheme.shadowColor, equals(AppColors.cardShadow));
      });

      test('should have correct elevated button theme', () {
        final buttonTheme = darkTheme.elevatedButtonTheme;
        expect(buttonTheme, isNotNull);
        
        final style = buttonTheme.style;
        expect(style, isNotNull);
        
        // Check button colors
        final backgroundColor = style!.backgroundColor?.resolve({});
        final foregroundColor = style.foregroundColor?.resolve({});
        expect(backgroundColor, equals(AppColors.primaryDark));
        expect(foregroundColor, equals(AppColors.onPrimaryDark));
        
        // Check elevation
        final elevation = style.elevation?.resolve({});
        expect(elevation, equals(2));
        
        // Check shape
        final shape = style.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
      });
    });

    group('Theme Consistency', () {
      test('should have different colors for light and dark themes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        expect(lightTheme.brightness, equals(Brightness.light));
        expect(darkTheme.brightness, equals(Brightness.dark));
        
        expect(lightTheme.colorScheme.primary, isNot(equals(darkTheme.colorScheme.primary)));
        expect(lightTheme.colorScheme.surface, isNot(equals(darkTheme.colorScheme.surface)));
      });

      test('should have consistent structure between themes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // Both should use Material 3
        expect(lightTheme.useMaterial3, equals(darkTheme.useMaterial3));
        
        // Both should have app theme extensions
        expect(lightTheme.extension<AppThemeExtension>(), isNotNull);
        expect(darkTheme.extension<AppThemeExtension>(), isNotNull);
        
        // Both should have similar component themes
        expect(lightTheme.appBarTheme.centerTitle, equals(darkTheme.appBarTheme.centerTitle));
        expect(lightTheme.cardTheme.elevation, equals(darkTheme.cardTheme.elevation));
      });

      test('should have theme extensions with correct theme type', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        final lightExtension = lightTheme.extension<AppThemeExtension>();
        final darkExtension = darkTheme.extension<AppThemeExtension>();
        
        expect(lightExtension, equals(AppThemeExtension.light));
        expect(darkExtension, equals(AppThemeExtension.dark));
        expect(lightExtension, isNot(equals(darkExtension)));
      });
    });

    group('Widget Integration', () {
      testWidgets('light theme should be applied to widgets correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: const Card(child: Text('Content')),
            ),
          ),
        );

        final context = tester.element(find.byType(Scaffold));
        final theme = Theme.of(context);
        
        expect(theme.brightness, equals(Brightness.light));
        expect(theme.colorScheme.primary, equals(AppColors.primaryLight));
      });

      testWidgets('dark theme should be applied to widgets correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: const Card(child: Text('Content')),
            ),
          ),
        );

        final context = tester.element(find.byType(Scaffold));
        final theme = Theme.of(context);
        
        expect(theme.brightness, equals(Brightness.dark));
        expect(theme.colorScheme.primary, equals(AppColors.primaryDark));
      });

      testWidgets('theme extension should be accessible in widgets', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                final extension = Theme.of(context).extension<AppThemeExtension>();
                return Text('Extension: ${extension != null ? 'Found' : 'Not Found'}');
              },
            ),
          ),
        );

        expect(find.text('Extension: Found'), findsOneWidget);
      });
    });

    group('Theme Data Validation', () {
      test('light theme should have all required color scheme properties', () {
        final theme = AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;
        
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
        expect(colorScheme.error, isNotNull);
        expect(colorScheme.onError, isNotNull);
      });

      test('dark theme should have all required color scheme properties', () {
        final theme = AppTheme.darkTheme;
        final colorScheme = theme.colorScheme;
        
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
        expect(colorScheme.error, isNotNull);
        expect(colorScheme.onError, isNotNull);
      });

      test('themes should have proper contrast ratios (mock check)', () {
        // This is a simplified contrast check - in a real app you might want
        // to use actual contrast ratio calculations
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // Light theme should have dark text on light backgrounds
        expect(lightTheme.brightness, equals(Brightness.light));
        expect(lightTheme.colorScheme.onSurface, isNot(equals(lightTheme.colorScheme.surface)));
        
        // Dark theme should have light text on dark backgrounds
        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(darkTheme.colorScheme.onSurface, isNot(equals(darkTheme.colorScheme.surface)));
      });
    });
  });
}
