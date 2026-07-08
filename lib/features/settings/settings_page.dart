import 'package:flutter/material.dart';
import 'package:flutter_go_chat/app/theme/theme_controller.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final g = GlobalScreenManager.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            spacing: 30,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await ThemeController.instance.setTheme(
                        AppThemeType.light,
                        null,
                      );
                    },
                    child: Text("SET LIGHT THEME"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await ThemeController.instance.setTheme(
                        AppThemeType.dark,
                        null,
                      );
                    },
                    child: Text("SET DARK THEME"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await ThemeController.instance.setTheme(
                        null,
                        AppAccentType.blue,
                      );
                    },
                    child: Text("SET BLUE ACCENT"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await ThemeController.instance.setTheme(
                        null,
                        AppAccentType.orange,
                      );
                    },
                    child: Text("SET ORANGE ACCENT"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
