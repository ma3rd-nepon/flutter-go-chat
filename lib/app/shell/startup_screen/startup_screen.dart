import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';

import 'package:flutter_go_chat/app/shell/welcome_screen/welcome_screen.dart';
import 'package:flutter_go_chat/app/shell/login_screen/login_screen.dart';
import 'package:flutter_go_chat/app/shell/error_screen/error_screen.dart';
import 'package:flutter_go_chat/app/shell/main_ui_screen/main_ui_screen.dart';

class StartupScreen extends StatefulWidget {
  final AuthController authController;
  final bool isDesktop;
  final Orientation orientation;
  const StartupScreen({
    super.key,
    this.isDesktop = true,
    required this.authController,
    this.orientation = Orientation.portrait,
  });

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    debugPrint("INIT STATE START SCREEN");

    widget.authController.addListener(updateState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authController.restoreSession();
    });

    debugPrint("INIT STATE START SCREEN ENDED");
  }

  void updateState() {
    if (mounted) setState(() {});
    debugPrint("UPDATE STATE START SCREEN");
  }

  @override
  void dispose() {
    debugPrint("DISPOSE START SCREEN");
    widget.authController.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authController;

    switch (auth.currentState) {
      case AuthState.authorizing:
        debugPrint("BUILD CIRCULAR PROGRESS");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AuthState.unauthorized:
        debugPrint("BUILD LOGIN");
        return const LoginScreen();

      case AuthState.authorized:
        debugPrint("BUILD MAIN UI");
        return MainUIScreen(
          currentUserId: auth.currentUserId!,
        );
      default:
        debugPrint("BUILD DEFAULT");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}