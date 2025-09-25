import 'package:flutter/material.dart';

class Nav {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  /// Push a new page
  static Future<T?> push<T>(Widget page) {
    return _navigator!.push(MaterialPageRoute(builder: (_) => page));
  }

  /// Push and remove all previous
  static Future<T?> pushReplacement<T>(Widget page) {
    return _navigator!.pushReplacement(
        MaterialPageRoute(builder: (_) => page));
  }

  /// Pop current page
  static void pop<T extends Object?>([T? result]) {
    _navigator?.pop(result);
  }

  /// Check if we can pop
  static bool canPop() {
    return _navigator?.canPop() ?? false;
  }
}
