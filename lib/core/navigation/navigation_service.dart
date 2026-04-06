import 'package:flutter/material.dart';

/// Interface for navigation service
abstract class NavigationService {
  /// Navigate to a new screen
  Future<T?> navigateTo<T>(String routeName, {Object? arguments});
  
  /// Navigate to a new screen and replace the current one
  Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments});
  
  /// Navigate to a new screen and clear the stack
  Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments});
  
  /// Go back to the previous screen
  void goBack<T>([T? result]);
  
  /// Check if we can go back
  bool canGoBack();
  
  /// Get the current route name
  String? getCurrentRouteName();
  
  /// Show a dialog
  Future<T?> showDialogCustom<T>({
    required Widget child,
    bool barrierDismissible = true,
  });
  
  /// Show a bottom sheet
  Future<T?> showBottomSheetCustom<T>({
    required Widget child,
    bool isScrollControlled = false,
  });
}
