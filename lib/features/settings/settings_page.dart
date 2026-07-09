import 'package:flutter/material.dart';
import 'package:flutter_go_chat/app/theme/theme_controller.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';
import 'package:flutter_go_chat/core/icons/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final wallpController = TextEditingController();

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
                mainAxisAlignment: .center,
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
                  const SizedBox(width: 3),
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
                mainAxisAlignment: .center,
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
                  const SizedBox(width: 3),
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
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: "set wallpaper URL"), controller: wallpController)),
                IconButton(
                  icon: Icon(AppIcons.easterEgg),
                  onPressed: () { g.changeWallpaper(wallpController.text.trim()); wallpController.clear(); },
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
