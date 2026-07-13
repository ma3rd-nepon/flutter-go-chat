import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter_go_chat/core/layers/wallpaper/wallaper_type.dart';
import 'package:flutter_go_chat/app/theme/theme_controller.dart';
import 'package:flutter_go_chat/app/theme/theme_list.dart';
import 'package:flutter_go_chat/core/layers/particles/particle_preset.dart';
import 'package:flutter_go_chat/core/services/app_scope/settings/settings_data.dart';

/// Full control of app
class SettingsController extends ChangeNotifier {
  // Language
  String currentLocale = 'en';
  Locale get locale => Locale(currentLocale);

  // // Theme (WIP)
  // ThemeData _theme = ThemeData.dark();
  // ThemeData get theme => _theme;

  // AppThemeType currentTheme = AppThemeType.dark;
  // AppAccentType currentAccent = AppAccentType.blue;

  // SettingsController() {
  //   init();
  // }

  AppThemeType get currentTheme => ThemeController.instance.currentTheme;
  AppAccentType get currentAccent => ThemeController.instance.currentAccent;

  // Other
  bool useGlass = false;
  double glassBlur = 13;
  double glassOpacity = 1.0;

  WallpaperType wallpaperType = WallpaperType.gradient;
  Map<String, dynamic> wallpaperContent =
      {}; // [color, gradient, asset, network_url]

  String? particleEffectId;
  List<ParticlePreset> particlePresets = ParticlePreset.values;

  bool shadersEnabled = false;
  String? shaderId;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString('settings');
    if (jsonString != null) {
      final settings = SettingsData.fromJson(jsonDecode(jsonString));

      currentLocale = settings.cl;
      useGlass = settings.ug;
      glassBlur = settings.gb;
      glassOpacity = settings.go;
      wallpaperType = settings.wt;
      wallpaperContent = {
        "color": settings.wc["color"],
        "gradient": settings.wc["gradient"],
        "asset": settings.wc["asset"],
        "network_url": settings.wc["network_url"],
      };
      particleEffectId = settings.pei;
      shadersEnabled = settings.se;
      shaderId = settings.si;

      final newTheme = AppThemeType.values.firstWhere(
        (e) => e.name == settings.ct,
      );

      final newAccent = AppAccentType.values.firstWhere(
        (e) => e.name == settings.ca,
      );
      await ThemeController.instance.setTheme(newTheme, newAccent);
    }

    notifyListeners();
  }

  Future<void> save() async {
    final settings = SettingsData(
      cl: currentLocale,
      ug: useGlass,
      gb: glassBlur,
      go: glassOpacity,
      wt: wallpaperType,
      wc: wallpaperContent,
      pei: particleEffectId,
      se: shadersEnabled,
      si: shaderId,
      ct: currentTheme.name,
      ca: currentAccent.name,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('settings', settings.toRawJson());

    notifyListeners();
  }

  void toggleGlass(bool value) {
    useGlass = value;

    notifyListeners();
  }

  void changeLanguage(String newLocale) {
    debugPrint("change to $newLocale");
    if (currentLocale == newLocale) return;
    currentLocale = newLocale;

    notifyListeners();
  }

  // Future<void> init() async {
  //   await setTheme(currentTheme, currentAccent);
  // }

  // Future<void> setTheme(
  //   AppThemeType? theme,
  //   AppAccentType? accent
  // ) async {
  //   if (theme == null && accent == null) return;

  //   currentTheme = theme ?? currentTheme;
  //   currentAccent = accent ?? currentAccent;

  //   final basePath = "assets/themes/base/${currentTheme.name}.json";
  //   final accentPath = "assets/themes/accent/${currentAccent.name}.json";

  //   final base = await JsonLoader.load(basePath);
  //   final acc = await JsonLoader.load(accentPath);

  //   _theme = ThemeBuilder.build(base: base, accent: acc);

  //   notifyListeners();
  // }

  Future<void> changeTheme(AppThemeType? theme, AppAccentType? accent) async {
    await ThemeController.instance.setTheme(theme, accent);
  }

  void changeParticlePreset(ParticlePreset preset) {
    particleEffectId = preset.id;

    notifyListeners();
  }

  void changeWallpaperType(WallpaperType newType) {
    if (newType == wallpaperType) return;
    wallpaperType = newType;

    notifyListeners();
  }

  void changeWallpaperContent(String content) {}
}
