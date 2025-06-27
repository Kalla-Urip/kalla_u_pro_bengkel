// lib/core/util/global_navigator.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';

/// A singleton class to manage global navigation and snackbar display.
/// This allows accessing the Navigator and showing SnackBars from anywhere
/// in the app, like inside a Dio interceptor.
class GlobalNavigator {
  // Private constructor
  GlobalNavigator._();

  /// The global key for the navigator state.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// A convenience getter for the current context.
  static BuildContext? get context => navigatorKey.currentContext;

  /// Shows a custom error SnackBar globally.
  ///
  /// [message]: The message to be displayed.
  static void showSnackBar(String message) {
    if (context != null) {
      Utils.showErrorSnackBar(context!, message);
    }
  }

  /// Navigates to the login screen and removes all previous routes.
  static void navigateToLogin() {
    if (context != null) {
      // Use go_router's `go` method to navigate to the login route.
      // This will replace the entire navigation stack with the login screen.
      context!.go(AppRoutes.login);
    }
  }
}
