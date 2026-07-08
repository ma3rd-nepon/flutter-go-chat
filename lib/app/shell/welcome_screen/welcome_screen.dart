import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final g = GlobalScreenManager.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Text("Добро пожаловать в supernova*"),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => g.redirect(context, "/login", null), child: Text("Продать почку"))
          ]
          )
        )
      )
    );
  }
}
