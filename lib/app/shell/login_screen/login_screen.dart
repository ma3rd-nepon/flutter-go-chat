import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/app/shell/login_screen/widgets/password_field.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void startLogin(Function(int) success) {
    final login = _loginController.text.trim();
    // final password = _passwordController.text.trim();

    if (login.isNotEmpty && RegExp(r'^\d+$').hasMatch(login)) {
      success(int.parse(login));
      AppScope.of(context).redirect(context, '/main_ui', null);
    } else {
      setState(() {});
      _loginController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) { 
    final g = AppScope.of(context);
    final Function(int) loginSuccess = g.authController.login;
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
                  decoration: InputDecoration(hintText: context.l10n.enterLogin),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 250,
                child: PasswordField(controller: _passwordController),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: Text(g.isDesktop(context) ? context.l10n.signInDesktop : context.l10n.signInMobile),
                onPressed: () => startLogin(loginSuccess),
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
