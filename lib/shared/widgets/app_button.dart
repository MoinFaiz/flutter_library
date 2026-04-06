import 'package:flutter/material.dart';
import '../../core/theme/app_component_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Standardized button sizes
enum ButtonSize { small, medium, large }

/// Standardized button variants
enum ButtonVariant { primary, secondary, text, destructive }

/// A standardized button widget that ensures consistent styling across the app
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  /// Primary button constructor
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = ButtonVariant.primary;

  /// Secondary button constructor
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = ButtonVariant.secondary;

  /// Text button constructor
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = ButtonVariant.text;

  /// Destructive button constructor
  const AppButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = ButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget button = _buildButton(context, isDark);
    
    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }
    
    return button;
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    final buttonStyle = _getButtonStyle(isDark);
    final buttonChild = _buildButtonChild();

    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingIndicatorSize(),
        height: _getLoadingIndicatorSize(),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppDimensions.spaceSm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle(bool isDark) {
    switch (variant) {
      case ButtonVariant.primary:
        switch (size) {
          case ButtonSize.small:
            return isDark 
              ? AppComponentStyles.primaryButtonStyleDark.merge(AppComponentStyles.primaryButtonSmall)
              : AppComponentStyles.primaryButtonStyle.merge(AppComponentStyles.primaryButtonSmall);
          case ButtonSize.medium:
            return isDark 
              ? AppComponentStyles.primaryButtonStyleDark 
              : AppComponentStyles.primaryButtonStyle;
          case ButtonSize.large:
            return isDark 
              ? AppComponentStyles.primaryButtonStyleDark.merge(AppComponentStyles.primaryButtonLarge)
              : AppComponentStyles.primaryButtonStyle.merge(AppComponentStyles.primaryButtonLarge);
        }
      case ButtonVariant.secondary:
        switch (size) {
          case ButtonSize.small:
            return isDark 
              ? AppComponentStyles.secondaryButtonStyleDark.merge(AppComponentStyles.secondaryButtonSmall)
              : AppComponentStyles.secondaryButtonStyle.merge(AppComponentStyles.secondaryButtonSmall);
          case ButtonSize.medium:
            return isDark 
              ? AppComponentStyles.secondaryButtonStyleDark 
              : AppComponentStyles.secondaryButtonStyle;
          case ButtonSize.large:
            return isDark 
              ? AppComponentStyles.secondaryButtonStyleDark.merge(_getLargeButtonStyle())
              : AppComponentStyles.secondaryButtonStyle.merge(_getLargeButtonStyle());
        }
      case ButtonVariant.text:
        return isDark 
          ? AppComponentStyles.textButtonStyleDark 
          : AppComponentStyles.textButtonStyle;
      case ButtonVariant.destructive:
        return isDark 
          ? AppComponentStyles.destructiveButtonStyleDark 
          : AppComponentStyles.destructiveButtonStyle;
    }
  }

  ButtonStyle _getLargeButtonStyle() {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceXl,
          vertical: AppDimensions.spaceLg,
        ),
      ),
      minimumSize: WidgetStateProperty.all(
        const Size(0, AppDimensions.buttonHeightLg),
      ),
    );
  }

  double _getLoadingIndicatorSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }
}