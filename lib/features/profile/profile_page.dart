import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GlobalScreenManager.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Text("Hello ${g.isDesktop(context) ? "Desktop" : "Mobile"} user!")
        )
      )
    );
  }
}