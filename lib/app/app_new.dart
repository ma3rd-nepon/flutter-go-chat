import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'package:flutter_go_chat/app/theme/theme_controller.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';
import 'package:flutter_go_chat/core/services/page_manager.dart';
import 'package:flutter_go_chat/app/shell/welcome_screen/welcome_screen.dart';
import 'package:flutter_go_chat/app/shell/login_screen/login_screen.dart';
import 'package:flutter_go_chat/app/shell/error_screen/error_screen.dart';
import 'package:flutter_go_chat/app/shell/startup_screen/startup_screen.dart';
import 'package:flutter_go_chat/app/shell/window.dart';
import 'package:flutter_go_chat/app/shell/main_ui_screen/main_ui_screen.dart';

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
  bool _isLoggedIn = false;
  bool barHidden = false;
  final uiManager = PageManager();
  int? currentUserId;
  String? errorText;
  String? wallpaperUrl;

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
  }

  void loginSuccess(int newUserId) {
    _isLoggedIn = true;
    currentUserId = newUserId;
    setState(() {});
  }

  void barToggle() {
    setState(() => barHidden = !barHidden);
  }

  void changeWallpaper(String? url) {
    if (url == "") url = null;
    setState(() => wallpaperUrl = url);
  }

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
      animation: controller,
      builder: (context, build) {
        return MaterialApp(
          theme: controller.theme,
          home: StartupScreen(isLoggedIn: _isLoggedIn),
          routes: {
            '/welcome': (context) => WelcomeScreen(),
            '/login': (context) => LoginScreen(),
            '/error': (context) => ErrorScreen(),
            '/main_ui': (context) => MainUIScreen(
              navManager: uiManager,
              currentUserId: currentUserId!,
            ),
          },
          builder: (context, child) {
            final isDesktop = MediaQuery.sizeOf(context).width > 800;
            return Column(
              children: [
                isDesktop
                    ? WindowControls(maximize: toggleMaximize)
                    : SizedBox.shrink(),
                Expanded(
                  child: GlobalScreenManager(
                    isLoggedIn: _isLoggedIn,
                    loginSuccess: loginSuccess,
                    uiManager: uiManager,
                    currentUserId: currentUserId,
                    barToggle: barToggle,
                    barHidden: barHidden,
                    wallpaperUrl: wallpaperUrl,
                    changeWallpaper: changeWallpaper,
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
        
        // GlobalScreenManager(
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