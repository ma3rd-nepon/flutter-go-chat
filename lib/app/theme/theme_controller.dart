import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/json_loader.dart';
import 'package:flutter_go_chat/app/theme/theme_builder.dart';

enum AppThemeType { dark, light }
enum AppAccentType {blue, orange}

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final instance = ThemeController._();

  ThemeData _theme = ThemeData.dark();
  ThemeData get theme => _theme;

  AppThemeType currentTheme = AppThemeType.dark;
  AppAccentType currentAccent = AppAccentType.blue;

  Future<void> init() async {
    await setTheme(currentTheme, currentAccent);
  }

  Future<void> setTheme(
    AppThemeType? theme,
    AppAccentType? accent
  ) async {
    if (theme != null) currentTheme = theme; 
    if (accent != null) currentAccent = accent;

    final basePath = "assets/themes/base/${currentTheme.name}.json";
    final accentPath = "assets/themes/accent/${currentAccent.name}.json";

    final base = await JsonLoader.load(basePath);
    final acc = await JsonLoader.load(accentPath);

    _theme = ThemeBuilder.build(base: base, accent: acc);
    
    notifyListeners();
  }
}