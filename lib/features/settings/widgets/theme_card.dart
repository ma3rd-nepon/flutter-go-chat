import 'package:flutter/material.dart';
import 'package:flutter_go_chat/app/theme/theme_controller.dart';

class ThemeCard extends StatelessWidget {
  final Color bgcolor;
  final AppThemeType theme;
  final AppAccentType accent;
  final itemCount = 2;
  
  const ThemeCard({
    super.key,
    required this.bgcolor,
    required this.theme,
    required this.accent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 100,
      child: ListView.builder(itemBuilder: (_, index) {
        return ElevatedButton(onPressed: () async { await ThemeController.instance.setTheme(theme, accent);} , child: Text("change theme"));
      })
    );
  }
}