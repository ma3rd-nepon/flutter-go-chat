import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/page_manager.dart';
import 'package:flutter_go_chat/core/layers/wallpaper/wallaper_type.dart';

class GlobalScreenManager extends InheritedWidget { // поделить на нотифаеры, добавить список партикл пресетов, добавить список обоев
  final bool isLoggedIn;
  final Function(int) loginSuccess;
  final PageManager uiManager;
  final int? currentUserId;
  final VoidCallback barToggle;
  final bool barHidden;
  final WallpaperType wallpaperType;
  final Function(WallpaperType) changeWallpaperType;
  // final Function(String) changeWallpaperContent;
  final Function(String) changeParticleEffect;
  final String? particleEffectId;

  const GlobalScreenManager({
    super.key, 
    required super.child,
    required this.isLoggedIn,
    required this.loginSuccess,
    required this.uiManager,
    required this.currentUserId,
    required this.barToggle,
    required this.barHidden,
    required this.wallpaperType,
    required this.changeWallpaperType,
    // required this.changeWallpaperContent,
    required this.changeParticleEffect,
    required this.particleEffectId,
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
    redirect(context, '/error', "from ${ModalRoute.of(context)?.settings.name ?? "unknown route"}: $errorMessage");
  }

  bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width > 800;

  static GlobalScreenManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlobalScreenManager>()!;
  }

  @override
  bool updateShouldNotify(GlobalScreenManager old) {
    return currentUserId != old.currentUserId ||
        particleEffectId != old.particleEffectId ||
        wallpaperType != old.wallpaperType ||
        barHidden != old.barHidden;
  }
}