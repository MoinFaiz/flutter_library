import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// Standardized component styles for consistent theming across the app
class AppComponentStyles {
  
  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.onPrimaryLight,
    elevation: AppDimensions.elevationSm,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get primaryButtonStyleDark => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.onPrimaryDark,
    elevation: AppDimensions.elevationSm,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryLight,
    side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get secondaryButtonStyleDark => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryDark,
    side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: AppColors.primaryLight,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get textButtonStyleDark => TextButton.styleFrom(
    foregroundColor: AppColors.primaryDark,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  // Padding Standards
  static EdgeInsets get compactPadding => EdgeInsets.symmetric(
    horizontal: AppDimensions.spaceSm,
    vertical: AppDimensions.spaceXs,
  );

  static EdgeInsets get defaultPadding => EdgeInsets.all(AppDimensions.spaceMd);

  static EdgeInsets get loosePadding => EdgeInsets.all(AppDimensions.spaceLg);

  static EdgeInsets get cardPadding => EdgeInsets.all(AppDimensions.cardPadding);

  // Margin Standards
  static EdgeInsets get defaultMargin => EdgeInsets.all(AppDimensions.spaceMd);

  static EdgeInsets get compactMargin => EdgeInsets.symmetric(
    horizontal: AppDimensions.spaceSm,
    vertical: AppDimensions.spaceXs,
  );

  static ButtonStyle get destructiveButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.errorLight,
    foregroundColor: AppColors.onErrorLight,
    elevation: AppDimensions.elevationSm,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  static ButtonStyle get destructiveButtonStyleDark => ElevatedButton.styleFrom(
    backgroundColor: AppColors.errorDark,
    foregroundColor: AppColors.onErrorDark,
    elevation: AppDimensions.elevationSm,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    minimumSize: const Size(0, AppDimensions.buttonHeightMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    textStyle: AppTypography.buttonMedium,
  );

  // Small Button Styles
  static ButtonStyle get primaryButtonSmall => primaryButtonStyle.copyWith(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
    ),
    minimumSize: WidgetStateProperty.all(const Size(0, AppDimensions.buttonHeightSm)),
    textStyle: WidgetStateProperty.all(AppTypography.buttonSmall),
  );

  static ButtonStyle get secondaryButtonSmall => secondaryButtonStyle.copyWith(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
    ),
    minimumSize: WidgetStateProperty.all(const Size(0, AppDimensions.buttonHeightSm)),
    textStyle: WidgetStateProperty.all(AppTypography.buttonSmall),
  );

  // Large Button Styles
  static ButtonStyle get primaryButtonLarge => primaryButtonStyle.copyWith(
    padding: WidgetStateProperty.all(
      EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXl,
        vertical: AppDimensions.spaceLg,
      ),
    ),
    minimumSize: WidgetStateProperty.all(const Size(0, AppDimensions.buttonHeightLg)),
    textStyle: WidgetStateProperty.all(AppTypography.buttonLarge),
  );

  // Animated Button Styles with Enhanced Interactions
  static ButtonStyle get primaryButtonStyleAnimated => primaryButtonStyle.copyWith(
    overlayColor: WidgetStatePropertyAll(
      AppColors.primaryLight.withValues(alpha: 0.1),
    ),
    elevation: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return 0;
      if (states.contains(WidgetState.hovered)) return AppDimensions.elevationLg;
      return AppDimensions.elevationSm;
    }),
  );

  static ButtonStyle get primaryButtonStyleAnimatedDark => primaryButtonStyleDark.copyWith(
    overlayColor: WidgetStatePropertyAll(
      AppColors.primaryDark.withValues(alpha: 0.1),
    ),
    elevation: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return 0;
      if (states.contains(WidgetState.hovered)) return AppDimensions.elevationLg;
      return AppDimensions.elevationSm;
    }),
  );

  // Input Decoration Styles
  static InputDecoration get inputDecoration => InputDecoration(
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
  );

  static InputDecoration get inputDecorationDark => inputDecoration.copyWith(
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
  );

  // Component Decorations - Status Badges
  static BoxDecoration get statusBadgeDecoration => BoxDecoration(
    color: AppColors.success.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
      color: AppColors.success,
      width: 1,
    ),
  );

  static BoxDecoration get statusErrorBadgeDecoration => BoxDecoration(
    color: AppColors.errorLight.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
      color: AppColors.errorLight,
      width: 1,
    ),
  );

  static BoxDecoration get statusWarningBadgeDecoration => BoxDecoration(
    color: AppColors.warning.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
      color: AppColors.warning,
      width: 1,
    ),
  );

  // Shadow Decorations - Elevation Styles
  static BoxDecoration get shadowElevationSm => BoxDecoration(
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(25, 0, 0, 0),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration get shadowElevationMd => BoxDecoration(
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(32, 0, 0, 0),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get shadowElevationLg => BoxDecoration(
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(38, 0, 0, 0),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Card Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: AppDimensions.elevationMd,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get cardDecorationDark => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: AppDimensions.elevationMd,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Focus/Hover State Decorations
  static BoxDecoration get focusStateDecoration => BoxDecoration(
    border: Border.all(
      color: AppColors.primaryLight,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
  );

  static BoxDecoration get hoverStateDecoration => BoxDecoration(
    color: AppColors.primaryLight.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
  );

  static BoxDecoration get disabledStateDecoration => BoxDecoration(
    color: AppColors.textSecondary.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
  );

  // Divider Styles
  static Divider get standardDivider => const Divider(
    thickness: AppDimensions.dividerThickness,
    indent: AppDimensions.dividerIndent,
    endIndent: AppDimensions.dividerIndent,
    color: AppColors.divider,
  );

  // Dialog/Modal Styles
  static ShapeBorder get dialogShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.modalRadius),
  );

  static EdgeInsets get dialogPadding => EdgeInsets.all(AppDimensions.modalPadding);

  // Icon Button Styles
  static ButtonStyle get iconButtonStyle => IconButton.styleFrom(
    iconSize: AppDimensions.iconMd,
    padding: EdgeInsets.all(AppDimensions.spaceSm),
    minimumSize: const Size(AppDimensions.iconLg + AppDimensions.spaceMd, AppDimensions.iconLg + AppDimensions.spaceMd),
  );

  // FAB Styles
  static FloatingActionButtonThemeData get fabTheme => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.onPrimaryLight,
    elevation: AppDimensions.elevationMd,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
    ),
  );

  static FloatingActionButtonThemeData get fabThemeDark => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.onPrimaryDark,
    elevation: AppDimensions.elevationMd,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
    ),
  );

  // Chip Styles
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedColor: AppColors.primaryLight,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceMd,
      vertical: AppDimensions.spaceSm,
    ),
    labelStyle: AppTypography.labelMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
    ),
  );

  static ChipThemeData get chipThemeDark => chipTheme.copyWith(
    backgroundColor: AppColors.surfaceDark,
    selectedColor: AppColors.primaryDark,
  );

  // Micro-interaction Button Styles - Enhanced UX
  /// Button style with smooth press animation and feedback
  static ButtonStyle get enhancedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.onPrimaryLight,
    elevation: AppDimensions.elevationSm,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceLg,
      vertical: AppDimensions.spaceMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primaryLight.withValues(alpha: 0.3);
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primaryLight.withValues(alpha: 0.1);
      }
      return null;
    }),
    elevation: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return 0.0;
      if (states.contains(WidgetState.hovered)) return 8.0;
      return AppDimensions.elevationSm;
    }),
  );

  /// Button style for card interactions with subtle animation
  static ButtonStyle get cardInteractionStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryLight,
    padding: EdgeInsets.symmetric(
      horizontal: AppDimensions.spaceMd,
      vertical: AppDimensions.spaceSm,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
    ),
  ).copyWith(
    overlayColor: WidgetStateProperty.all(
      AppColors.primaryLight.withValues(alpha: 0.05),
    ),
    side: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return BorderSide(
          color: AppColors.primaryLight,
          width: 2.0,
        );
      }
      return const BorderSide(color: AppColors.primaryLight, width: 1.0);
    }),
  );

  // Hover/Focus Decoration Styles - Interactive Elements
  /// Container decoration for interactive card hover states
  static BoxDecoration get interactiveCardDecoration => BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
      color: Colors.transparent,
      width: 1.0,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(15, 0, 0, 0),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
  );

  /// Container decoration for interactive card hover - hover state
  static BoxDecoration get interactiveCardHoverDecoration => BoxDecoration(
    color: AppColors.primaryLight.withValues(alpha: 0.02),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    border: Border.all(
      color: AppColors.primaryLight.withValues(alpha: 0.2),
      width: 1.0,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(25, 0, 0, 0),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Loading State Styles
  /// Decoration for loading overlay
  static BoxDecoration get loadingOverlayDecoration => BoxDecoration(
    color: Colors.black.withValues(alpha: 0.2),
  );

  // Animation Configuration Getters
  /// Get animation duration based on context
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
}
