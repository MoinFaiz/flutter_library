import 'package:flutter/material.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';

/// Implementation of NavigationService using Navigator
class NavigationServiceImpl implements NavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get the navigator key for MaterialApp
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  NavigatorState? get _navigator => _navigatorKey.currentState;
  
  @override
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return _navigator?.pushNamed<T>(routeName, arguments: arguments) ?? Future.value(null);
  }
  
  @override
  Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments}) {
    return _navigator?.pushReplacementNamed<T, dynamic>(routeName, arguments: arguments) ?? Future.value(null);
  }
  
  @override
  Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments}) {
    return _navigator?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    ) ?? Future.value(null);
  }
  
  @override
  void goBack<T>([T? result]) {
    return _navigator?.pop<T>(result);
  }
  
  @override
  bool canGoBack() {
    return _navigator?.canPop() ?? false;
  }
  
  @override
  String? getCurrentRouteName() {
    if (_navigator?.context == null) return null;
    return ModalRoute.of(_navigator!.context)?.settings.name;
  }
  
  @override
  Future<T?> showDialogCustom<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    if (_navigator?.context == null) return Future.value(null);
    return showDialog<T>(
      context: _navigator!.context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }
  
  @override
  Future<T?> showBottomSheetCustom<T>({
    required Widget child,
    bool isScrollControlled = false,
  }) {
    if (_navigator?.context == null) return Future.value(null);
    return showModalBottomSheet<T>(
      context: _navigator!.context,
      isScrollControlled: isScrollControlled,
      builder: (context) => child,
    );
  }
}
