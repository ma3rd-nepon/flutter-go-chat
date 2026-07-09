import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/page_manager.dart';

class GlobalScreenManager extends InheritedWidget {
  final bool isLoggedIn;
  final Function(int) loginSuccess;
  final PageManager uiManager;
  final int? currentUserId;
  final VoidCallback barToggle;
  final bool barHidden;
  final String? wallpaperUrl;
  final Function(String?) changeWallpaper;

  const GlobalScreenManager({
    super.key, 
    required super.child,
    required this.isLoggedIn,
    required this.loginSuccess,
    required this.uiManager,
    required this.currentUserId,
    required this.barToggle,
    required this.barHidden,
    required this.wallpaperUrl,
    required this.changeWallpaper
  });

  void redirect(BuildContext context, String url, Object? args) async {
    await Navigator.pushNamed(context, url, arguments: args);
  }

  Object? goBack(BuildContext context) {
    Object? result;
    if (Navigator.of(context).canPop()) Navigator.pop(context, result);
    return result;
  }

  void throwError(context, String errorMessage) {
    redirect(context, '/error', "from ${ModalRoute.of(context)?.settings.name ?? "unknown route"}: $errorMessage");
  }

  bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width > 800;

  static GlobalScreenManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlobalScreenManager>()!;
  }

  @override
  bool updateShouldNotify(GlobalScreenManager old) {
    return currentUserId != old.currentUserId;
  }
}