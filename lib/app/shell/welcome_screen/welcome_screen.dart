import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final String name = "SuperNova*";

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Text(context.l10n.welcome(name)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => g.redirect(context, "/login", null), child: Text(context.l10n.start))
          ]
          )
        )
      )
    );
  }
}
