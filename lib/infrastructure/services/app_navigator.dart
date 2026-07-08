import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey =>
      _navigatorKey;

  static void navigateTo(String routeName,
      {Object? arguments}) {
    final navigator = _navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(routeName,
          arguments: arguments);
    }
  }
}
