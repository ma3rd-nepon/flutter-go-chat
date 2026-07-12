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
              // Row(children: [
              //   Expanded(child: TextField(decoration: InputDecoration(hintText: "set wallpaper URL"), controller: wallpController)),
              //   IconButton(
              //     icon: Icon(AppIcons.easterEgg),
              //     onPressed: () { g.changeWallpaperType(wallpController.text.trim()); wallpController.clear(); },
              //   )
              // ]),
              DropdownMenu<String>(
                label: Text("Particle Effect"),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: "network", label: "Network"),
                  DropdownMenuEntry(value: "snow", label: "Snow"),
                  DropdownMenuEntry(value: "rain", label: "Rain"),
                  DropdownMenuEntry(value: "dust", label: "Dust"),
                  DropdownMenuEntry(value: "starrain", label: "Star Rain"),
                ],
                onSelected: (value) {
                  g.changeParticleEffect(value!);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
