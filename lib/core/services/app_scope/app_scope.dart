import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/auth/auth_controller.dart';
import 'package:flutter_go_chat/core/services/app_scope/navigation/nav_controller.dart';
import 'package:flutter_go_chat/core/services/app_scope/settings/settings_controller.dart';
import 'package:flutter_go_chat/core/services/app_scope/ui/ui_controller.dart';

class AppScope extends InheritedWidget {
  final AuthController authController;
  final UIController uiController;
  final NavigationController navController;
  final SettingsController settingsController;

  const AppScope({
    super.key,
    required super.child,
    required this.authController,
    required this.navController,
    required this.settingsController,
    required this.uiController,
  });

  void redirect(BuildContext context, String url, Object? args) async {
    await Navigator.pushNamed(context, url, arguments: args);
  }

  Object? goBack(BuildContext context) {
    Object? result;
    if (Navigator.of(context).canPop()) Navigator.pop(context, result);
    return result;
  }

  void throwError(BuildContext context, String errorMessage) {
    redirect(
      context,
      '/error',
      "from ${ModalRoute.of(context)?.settings.name ?? "unknown route"}: $errorMessage",
    );
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > 800;

  static AppScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!;
  }

  static AppScope read(BuildContext context) {
    final scope =
        context.getElementForInheritedWidgetOfExactType<AppScope>()?.widget
            as AppScope?;

    assert(scope != null);

    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope old) {
    return authController != old.authController ||
        navController != old.navController ||
        uiController != old.uiController ||
        settingsController != old.settingsController;
    // return authConnector.currentUserId != old.authConnector.currentUserId ||
    //     particleEffectId != old.particleEffectId ||
    //     wallpaperType != old.wallpaperType ||
    //     barHidden != old.barHidden;
  }
}
