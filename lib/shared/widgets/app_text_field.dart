import 'package:flutter/material.dart';
import '../../core/theme/app_component_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

/// Standardized input field sizes
enum InputSize { small, medium, large }

/// A standardized input field widget that ensures consistent styling across the app
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputSize size;
  final bool required;
  final String? helperText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.size = InputSize.medium,
    this.required = false,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
  });

  /// Email input constructor
  const AppTextField.email({
    super.key,
    this.label = 'Email',
    this.hintText = 'Enter your email',
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.size = InputSize.medium,
    this.required = false,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
  }) : keyboardType = TextInputType.emailAddress,
       obscureText = false,
       maxLines = 1,
       minLines = null,
       maxLength = null;

  /// Password input constructor
  const AppTextField.password({
    super.key,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.size = InputSize.medium,
    this.required = false,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
  }) : keyboardType = TextInputType.visiblePassword,
       obscureText = true,
       maxLines = 1,
       minLines = null,
       maxLength = null;

  /// Multiline text area constructor
  const AppTextField.multiline({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.size = InputSize.medium,
    this.required = false,
    this.helperText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
  }) : keyboardType = TextInputType.multiline,
       obscureText = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _buildLabel(context),
          const SizedBox(height: AppDimensions.spaceSm),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: _getTextStyle(context),
          decoration: _getInputDecoration(context, isDark),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            helperText!,
            style: AppTypography.caption.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final theme = Theme.of(context);
    
    return RichText(
      text: TextSpan(
        style: AppTypography.labelMedium.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: label),
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case InputSize.small:
        return AppTypography.bodySmall;
      case InputSize.medium:
        return AppTypography.bodyMedium;
      case InputSize.large:
        return AppTypography.bodyLarge;
    }
  }

  InputDecoration _getInputDecoration(BuildContext context, bool isDark) {
    final baseDecoration = isDark 
        ? AppComponentStyles.inputDecorationDark 
        : AppComponentStyles.inputDecoration;

    return baseDecoration.copyWith(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      contentPadding: _getContentPadding(),
    );
  }

  EdgeInsets _getContentPadding() {
    switch (size) {
      case InputSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSm,
          vertical: AppDimensions.spaceSm,
        );
      case InputSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceMd,
        );
      case InputSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLg,
          vertical: AppDimensions.spaceLg,
        );
    }
  }
}