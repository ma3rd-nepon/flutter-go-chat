import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/app/shell/login_screen/widgets/password_field.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';
import 'package:flutter_go_chat/core/services/wss_http/wss_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthController? _auth;

  @override
  void initState() {
    super.initState();

    _auth ??= AppScope.read(context).authController;

    _auth?.addListener(updateState);
  }

  void updateState() {
    if (mounted) setState(() {});
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  _auth = AppScope.read(context).authController;
}

  @override
  void dispose() {
    _auth?.removeListener(updateState);

    _loginController.dispose();
    _passwordController.dispose();
    
    super.dispose();
  }

  Future<void> startLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await AppScope.read(
        context,
      ).authController.login(login, password);

      if (result.contains("error")) {
        debugPrint(result);
        _loginController.clear();
        _passwordController.clear();
        return;
      }

      setState(() {});

      // if (WebSocketService().isConnected) {
      //   AppScope.of(context).redirect(context, '/main_ui', null);
      // } else {
      //   setState(() {});
      //   debugPrint("wss not connected");
      //   _loginController.clear();
      //   _passwordController.clear();
      // }
    } catch (e) {
      debugPrint("ERROR: $e"); // notification on screen (WIP)
    }
  }

  Future<void> startRegister() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await AppScope.read(
        context,
      ).authController.register(login, password);

      if (result.contains("error")) {
        debugPrint(result);
        _loginController.clear();
        _passwordController.clear();
        return;
      }

      if (WebSocketService().isConnected) {
        AppScope.of(context).redirect(context, '/main_ui', null);
      } else {
        setState(() {});
        debugPrint("wss not connected");
        _loginController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      debugPrint("ERROR: $e"); // notification on screen (WIP)
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);
    _auth = g.authController;
    String startText = context.l10n.signIn;

    final child = Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              Image.asset('assets/images/rabbit.png', width: 44, height: 44),
              const SizedBox(height: 15),
              Text(startText),
              const SizedBox(height: 8),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    hintText: context.l10n.enterLogin,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 250,
                child: PasswordField(controller: _passwordController),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  AppScope.read(context).authController.needRegister
                      ? "Registration"
                      : g.isDesktop(context)
                      ? context.l10n.signInDesktop
                      : context.l10n.signInMobile,
                ),
                onPressed: () {
                  AppScope.read(context).authController.needRegister
                      ? startRegister()
                      : startLogin();
                },
              ),

              const SizedBox(height: 10),

              IconButton(
                onPressed: () =>
                    AppScope.read(context).authController.switchRegister(),
                icon: Icon(Icons.refresh_outlined),
              ),
            ],
          ),
        ),
      ),
    );

    return g.isDesktop(context)
        ? child
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              g.goBack(context);
            },

            child: child,
          );
  }
}
