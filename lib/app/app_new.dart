import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'package:flutter_go_chat/app/theme/theme_controller.dart';
import 'package:flutter_go_chat/l10n/app_locale.dart';
import 'package:flutter_go_chat/app/shell/welcome_screen/welcome_screen.dart';
import 'package:flutter_go_chat/app/shell/login_screen/login_screen.dart';
import 'package:flutter_go_chat/app/shell/error_screen/error_screen.dart';
import 'package:flutter_go_chat/app/shell/startup_screen/startup_screen.dart';
import 'package:flutter_go_chat/app/shell/window.dart';
import 'package:flutter_go_chat/app/shell/main_ui_screen/main_ui_screen.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

/*
пофиксить закрытие чата и смену влкадок при смене юи (а хотя нахуя?)
*/
class _AppShellState extends State<AppShell> with WindowListener {
  // bool _isPortrait = true;
  bool _isMaximized = false;

  // final uiManager = PageManager();

  String? errorText;

  // WallpaperType wallpaperType = WallpaperType.gradient;
  // List<String> wallpaperContent = []; // [color, gradient, asset, url]
  // String? particleEffectId;

  final authCon = AuthController();
  final navCon = NavigationController();
  final setCon = SettingsController();
  final uiCon = UIController();

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      const options = WindowOptions(
        size: Size(1024, 768),
        minimumSize: Size(600, 400),
        center: true,
        titleBarStyle: TitleBarStyle.hidden, // ← скрыть стандартный заголовок
        windowButtonVisibility: false, // ← скрыть кнопки Windows
      );

      windowManager.waitUntilReadyToShow(options, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      windowManager.addListener(this);
    }

    setCon.load();
  }

  // void loginSuccess(int newUserId) {
  //   _isLoggedIn = true;
  //   currentUserId = newUserId;
  //   setState(() {});
  // }

  // void barToggle() {
  //   setState(() => barHidden = !barHidden);
  // }

  // void changeWallpaperType(WallpaperType type) {
  //   setState(() => wallpaperType = type);
  // }

  // void changeWallpaperContent(String content) {
  //   final l = [WallpaperType.color, WallpaperType.gradient, WallpaperType.asset, WallpaperType.url];
  //   setState(() => wallpaperContent[l.indexOf(wallpaperType)] = content);
  // }

  // void changeParticleEffect(String id) {
  //   setState(() => particleEffectId = id);
  // }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  void toggleMaximize() {
    if (_isMaximized) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, setCon]),
      builder: (context, build) {
        return MaterialApp(
          locale: setCon.locale,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: AppLocale.delegates,
          theme: controller.theme,
          home: StartupScreen(authController: authCon),
          routes: {
            '/welcome': (context) => WelcomeScreen(),
            '/login': (context) => LoginScreen(),
            '/error': (context) => ErrorScreen(),
            '/main_ui': (context) =>
                MainUIScreen(currentUserId: authCon.currentUserId!),
          },
          builder: (context, child) {
            final isDesktop = MediaQuery.sizeOf(context).width > 800;
            return Column(
              children: [
                isDesktop
                    ? WindowControls(maximize: toggleMaximize)
                    : SizedBox.shrink(),
                Expanded(
                  child: AppScope(
                    authController: authCon,
                    navController: navCon,
                    settingsController: setCon,
                    uiController: uiCon,
                    child: child!,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
        
        // GlobalScreenManager(Ф
        //   isLoggedIn: _isLoggedIn,
        //   loginSuccess: loginSuccess,
        //   uiManager: uiManager,
        //   currentUserId: currentUserId,
        //   child: AnimatedBuilder(
        //     animation: controller,
        //     builder: (context, build) {
        //       return MaterialApp(
        //         theme: controller.theme,
        //         home: StartupScreen(isLoggedIn: _isLoggedIn),
        //         routes: {
        //           '/welcome': (context) => WelcomeScreen(),
        //           '/login': (context) => LoginScreen(),
        //           '/error': (context) => ErrorScreen(),
        //           '/main_ui': (context) => MainUIScreen(
        //             navManager: uiManager,
        //             currentUserId: currentUserId!,
        //           ),
        //         },
        //         builder: (context, child) {
        //           return Column( 
        //             children: [
        //               isDesktop
        //                   ? WindowControls(maximize: toggleMaximize)
        //                   : SizedBox.shrink(),
        //               Expanded(child: child!),
        //             ],
        //           );
        //         },
        //       );
        //     },
        //   ),
        // );