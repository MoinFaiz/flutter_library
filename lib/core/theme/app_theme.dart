import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';
import 'app_component_styles.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryVariantLight,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondaryVariantLight,
        surface: AppColors.surfaceLight,
        error: AppColors.errorLight,
        onPrimary: AppColors.onPrimaryLight,
        onSecondary: AppColors.onSecondaryLight,
        onSurface: AppColors.onSurfaceLight,
        onError: AppColors.onErrorLight,
      ),
      extensions: const [
        AppThemeExtension.light,
      ],
      
      // Typography
      textTheme: _buildTextTheme(Brightness.light),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTypography.heading5.copyWith(
          color: AppColors.onPrimaryLight,
          fontWeight: AppTypography.semibold,
        ),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.all(AppDimensions.spaceSm),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppComponentStyles.primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppComponentStyles.secondaryButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppComponentStyles.textButtonStyle,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceMd,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      
      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationSm,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      
      // FAB Theme
      floatingActionButtonTheme: AppComponentStyles.fabTheme,
      
      // Chip Theme
      chipTheme: AppComponentStyles.chipTheme,
      
      // Icon Theme
      iconTheme: const IconThemeData(
        size: AppDimensions.iconMd,
        color: AppColors.onSurfaceLight,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
        color: AppColors.divider,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.modalRadius),
        ),
        contentTextStyle: AppTypography.bodyMedium,
        titleTextStyle: AppTypography.heading4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        primaryContainer: AppColors.primaryVariantDark,
        secondary: AppColors.secondaryDark,
        secondaryContainer: AppColors.secondaryVariantDark,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
        onPrimary: AppColors.onPrimaryDark,
        onSecondary: AppColors.onSecondaryDark,
        onSurface: AppColors.onSurfaceDark,
        onError: AppColors.onErrorDark,
      ),
      extensions: const [
        AppThemeExtension.dark,
      ],
      
      // Typography
      textTheme: _buildTextTheme(Brightness.dark),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTypography.heading5.copyWith(
          color: AppColors.onSurfaceDark,
          fontWeight: AppTypography.semibold,
        ),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.all(AppDimensions.spaceSm),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppComponentStyles.primaryButtonStyleDark,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppComponentStyles.secondaryButtonStyleDark,
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppComponentStyles.textButtonStyleDark,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceMd,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      
      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationSm,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
      
      // FAB Theme
      floatingActionButtonTheme: AppComponentStyles.fabThemeDark,
      
      // Chip Theme
      chipTheme: AppComponentStyles.chipThemeDark,
      
      // Icon Theme
      iconTheme: const IconThemeData(
        size: AppDimensions.iconMd,
        color: AppColors.onSurfaceDark,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
        color: AppColors.divider,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.modalRadius),
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        titleTextStyle: AppTypography.heading4.copyWith(
          color: AppColors.onSurfaceDark,
        ),
      ),
    );
  }
  
  /// Build standardized text theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark;
    
    return TextTheme(
      // Headings
      displayLarge: AppTypography.heading1.copyWith(color: textColor),
      displayMedium: AppTypography.heading2.copyWith(color: textColor),
      displaySmall: AppTypography.heading3.copyWith(color: textColor),
      headlineLarge: AppTypography.heading3.copyWith(color: textColor),
      headlineMedium: AppTypography.heading4.copyWith(color: textColor),
      headlineSmall: AppTypography.heading5.copyWith(color: textColor),
      titleLarge: AppTypography.heading4.copyWith(color: textColor),
      titleMedium: AppTypography.heading5.copyWith(color: textColor),
      titleSmall: AppTypography.heading6.copyWith(color: textColor),
      
      // Body text
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTypography.bodySmall.copyWith(color: textColor),
      
      // Labels
      labelLarge: AppTypography.labelLarge.copyWith(color: textColor),
      labelMedium: AppTypography.labelMedium.copyWith(color: textColor),
      labelSmall: AppTypography.labelSmall.copyWith(color: textColor),
    );
  }
}
