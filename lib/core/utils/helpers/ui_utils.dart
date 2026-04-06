import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/error/error_handler.dart';

/// UI utility functions for common patterns
class UIUtils {
  /// Show a snackbar with error message
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(message);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
              )
            : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Get responsive grid count based on available width
  /// Use with LayoutBuilder for automatic scaling
  static int getGridCrossAxisCountFromWidth(double width) {
    if (width < 600) {
      return 2; // Phone
    } else if (width < 900) {
      return 3; // Tablet portrait
    } else {
      return 4; // Tablet landscape / Desktop
    }
  }

  /// Get responsive grid count from BuildContext
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getGridCrossAxisCountFromWidth(width);
  }

  /// Get responsive padding - scales with available space
  static EdgeInsets getResponsivePaddingFromWidth(double width) {
    if (width < 600) {
      return const EdgeInsets.all(16); // Phone
    } else {
      return const EdgeInsets.all(24); // Tablet / Desktop
    }
  }

  /// Get responsive padding from BuildContext
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getResponsivePaddingFromWidth(width);
  }

  /// Get responsive book card width - calculates based on available width
  static double getHorizontalBookCardWidthFromWidth(double availableWidth) {
    if (availableWidth < 600) {
      return AppConstants.horizontalBookCardWidth; // Phone
    } else if (availableWidth < 900) {
      return AppConstants.horizontalBookCardWidth * 1.2; // Tablet portrait
    } else {
      return AppConstants.horizontalBookCardWidth * 1.4; // Tablet landscape / Desktop
    }
  }

  /// Get responsive book card width from BuildContext
  static double getHorizontalBookCardWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getHorizontalBookCardWidthFromWidth(width);
  }

  /// Get responsive book card height based on width
  static double getHorizontalBookCardHeightFromWidth(double cardWidth) {
    return cardWidth / AppConstants.horizontalBookCardAspectRatio;
  }

  /// Create theme-aware skeleton container
  static Widget createSkeletonContainer(
    BuildContext context, {
    required double height,
    double? width,
    double? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.skeletonBorderRadius,
        ),
      ),
    );
  }

  /// Safe pop with result handling
  static void safePop<T>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  /// Debounced function execution
  static void debounce(
    String key,
    Duration duration,
    VoidCallback action,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(duration, action);
  }

  static final Map<String, Timer> _debounceTimers = {};
}
