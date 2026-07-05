import 'package:flutter/material.dart';
import 'package:flutter_go_chat/theme/app_theme.dart';
import 'package:flutter_go_chat/theme/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isOrange = true;

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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("Change Theme"),
            ElevatedButton(
              onPressed: () async {
                await ThemeController.instance.setTheme(Themes.light, AccentColor.lightBlue);
              },
              child: Text("PUSH MEE"),
            ),
          ],
        ),
      ),
    );
  }
}
