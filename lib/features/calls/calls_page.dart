import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final g = GlobalScreenManager.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            "Hello calls page from ${g.isDesktop(context) ? "Desktop" : "Mobile"} UI",
          ),
        ),
      ),
    );
  }
}
