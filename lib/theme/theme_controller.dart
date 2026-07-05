import 'package:flutter/material.dart';
import 'package:flutter_go_chat/theme/app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final instance = ThemeController._();

  Themes currentTheme = Themes.light;
  AccentColor currentAccent = AccentColor.lightBlue;
  ThemeData getTheme() { return AppTheme.theme; }

  Future<void> setTheme(Themes theme, AccentColor accent) async {
    currentTheme = theme;
    currentAccent = accent;
    await AppColors.init(currentTheme, currentAccent);
    notifyListeners();
  }
}