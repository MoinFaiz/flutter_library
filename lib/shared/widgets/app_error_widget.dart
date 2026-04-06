import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_colors.dart';

/// Enhanced error widget for showing error states with better UX
/// 
/// Features:
/// - Smooth animations on appearance
/// - Clear error icon with color coding
/// - Descriptive message and optional subtitle
/// - Action button for recovery (retry, home, etc)
/// - Responsive design
class AppErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional error subtitle/description
  final String? subtitle;

  /// Callback for retry or action button
  final VoidCallback? onRetry;

  /// Icon to display (defaults to error_outline)
  final IconData? icon;

  /// Label for the action button (defaults to 'Retry')
  final String? actionLabel;

  /// Whether to show animated entrance
  final bool animateEntrance;

  /// Custom icon color (defaults to error color)
  final Color? iconColor;

  /// Custom action button style
  final ButtonStyle? buttonStyle;

  /// Whether to show error background decoration
  final bool showBackground;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
    this.icon,
    this.actionLabel,
    this.animateEntrance = true,
    this.iconColor,
    this.buttonStyle,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = iconColor ?? Theme.of(context).colorScheme.error;

    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon with background circle
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: errorColor.withValues(alpha: 0.1),
              ),
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Icon(
                icon ?? Icons.error_outline,
                size: AppDimensions.avatarXl,
                color: errorColor,
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLg),

            // Error Message
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
              textAlign: TextAlign.center,
            ),

            // Optional Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.spaceMd),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: buttonStyle ??
                      ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceLg,
                          vertical: AppDimensions.spaceMd,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                        ),
                      ),
                  icon: const Icon(Icons.refresh),
                  label: Text(actionLabel ?? 'Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Wrap with background if requested
    if (showBackground) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.8)
                : AppColors.surfaceLight.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: AppDimensions.elevationMd,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(AppDimensions.spaceMd),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}

/// Empty state widget for showing "no data" states
/// 
/// Features:
/// - Clear empty state icon
/// - Friendly messaging
/// - Optional action button
/// - Responsive design
class AppEmptyStateWidget extends StatelessWidget {
  /// Title to display
  final String title;

  /// Optional description/subtitle
  final String? description;

  /// Icon to display (defaults to inbox)
  final IconData? icon;

  /// Optional action label and callback
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Custom icon color
  final Color? iconColor;

  /// Whether to show background
  final bool showBackground;

  const AppEmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayIconColor =
        iconColor ?? Theme.of(context).colorScheme.outline;

    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty Icon with background circle
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: displayIconColor.withValues(alpha: 0.1),
              ),
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: AppDimensions.avatarXl,
                color: displayIconColor,
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLg),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: AppDimensions.spaceMd),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spaceLg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLg,
                      vertical: AppDimensions.spaceMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (showBackground) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.8)
                : AppColors.surfaceLight.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: AppDimensions.elevationMd,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(AppDimensions.spaceMd),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}
