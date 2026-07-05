import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AppColors {
  AppColors._();

  static Map<String, int> _colors = {};

  static Future<void> init(Themes theme, AccentColor accent) async {
    _colors.clear();
    final themeJson = await rootBundle.loadString(
      "assets/themes/base/${theme.jsonName}",
    );
    final accentJson = await rootBundle.loadString(
      "assets/themes/accent/${accent.jsonName}",
    );

    final tmap = (jsonDecode(themeJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, int.parse(value as String)),
    );
    final amap = (jsonDecode(accentJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, int.parse(value as String)),
    );

    _colors.addAll(tmap);
    _colors.addAll(amap);
  }

  static int color(String name) => _colors[name] ?? 0xFF000000;

  static Color get background => Color(color("background"));
  static Color get backgroundSecondary => Color(color("background_secondary"));

  static Color get surface => Color(color("surface"));
  static Color get surfaceVariant => Color(color("surface_variant"));
  static Color get surfaceElevated => Color(color("surface_elevated"));

  static Color get surfaceHover => Color(color("surface_hover"));
  static Color get surfacePressed => Color(color("surface_pressed"));
  static Color get surfaceSelected => Color(color("surface_selected"));
  static Color get surfaceFocus => Color(color("surface_focus"));

  static Color get surfaceTransparent => Color(color("surface_transparent"));

  static Color get primary => Color(color("primary"));
  static Color get primaryHover => Color(color("primary_hover"));
  static Color get primaryPressed => Color(color("primary_pressed"));
  static Color get primaryVariant => Color(color("primary_variant"));

  static Color get secondary => Color(color("secondary"));
  static Color get secondaryVariant => Color(color("secondary_variant"));

  static Color get textPrimary => Color(color("text_primary"));
  static Color get textSecondary => Color(color("text_secondary"));
  static Color get textTertiary => Color(color("text_tertiary"));
  static Color get textHint => Color(color("text_hint"));
  static Color get textDisabled => Color(color("text_disabled"));

  static Color get iconPrimary => Color(color("icon_primary"));
  static Color get iconSecondary => Color(color("icon_secondary"));
  static Color get iconActive => Color(color("icon_active"));
  static Color get iconDisabled => Color(color("icon_disabled"));

  static Color get border => Color(color("border"));
  static Color get borderLight => Color(color("border_light"));
  static Color get borderActive => Color(color("border_active"));

  static Color get chatBackground => Color(color("chat_background"));
  static Color get chatListBackground => Color(color("chat_list_background"));

  static Color get myMessageBubble => Color(color("my_message_bubble"));
  static Color get myMessageHover => Color(color("my_message_hover"));

  static Color get otherMessageBubble => Color(color("other_message_bubble"));
  static Color get otherMessageHover => Color(color("other_message_hover"));

  static Color get messageSelected => Color(color("message_selected"));

  static Color get inputBar => Color(color("input_bar"));
  static Color get inputBarBackground => Color(color("input_background"));
  static Color get inputFocus => Color(color("input_focus"));

  static Color get tabActive => Color(color("tab_active"));
  static Color get tabInActive => Color(color("tab_inactive"));

  static Color get sideBarBackground => Color(color("sidebar_background"));
  static Color get sideBarHover => Color(color("sidebar_hover"));
  static Color get sideBarSelected => Color(color("sidebar_selected"));

  static Color get statusOnline => Color(color("online"));
  static Color get statusAway => Color(color("away"));
  static Color get statusBusy => Color(color("busy"));
  static Color get statusOffline => Color(color("offline"));

  static Color get badge => Color(color("badge"));
  static Color get badgeText => Color(color("badge_text"));

  static Color get mention => Color(color("mention"));
  static Color get unread => Color(color("unread"));

  static Color get fileAudio => Color(color("audio"));
  static Color get fileVideo => Color(color("video"));
  static Color get fileDocument => Color(color("document"));
  static Color get fileArchive => Color(color("archive"));

  static Color get callAccept => Color(color("call_accept"));
  static Color get callDecline => Color(color("call_decline"));

  static Color get feedbackSuccess => Color(color("success"));
  static Color get feedbackWarning => Color(color("warning"));
  static Color get feedbackError => Color(color("error"));
  static Color get feedbackInfo => Color(color("info"));
}

enum Themes {
  light("base_light.json"),
  dark("base_dark.json");

  const Themes(this.jsonName);

  final String jsonName;
}

enum AccentColor {
  orange("accent_orange.json"),
  lightBlue("accent_lightblue.json");

  const AccentColor(this.jsonName);

  final String jsonName;
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily!,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // NavigationRail
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.background,
      selectedIconTheme: IconThemeData(color: AppColors.iconActive),
      unselectedIconTheme: IconThemeData(color: AppColors.iconDisabled),
      indicatorColor: AppColors.primaryVariant,
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.iconActive,
      unselectedItemColor: AppColors.iconDisabled,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryVariant,
        foregroundColor: AppColors.textPrimary,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBar,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.textHint),
    ),

    // Text
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontSize: 24),
      titleMedium: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      bodyLarge: TextStyle(color: AppColors.textTertiary, fontSize: 14),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      labelSmall: TextStyle(color: AppColors.textPrimary, fontSize: 11),
    ),

    // Icon
    iconTheme: IconThemeData(color: AppColors.iconPrimary),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceTransparent,
        shadowColor: AppColors.surfaceTransparent,
        surfaceTintColor: AppColors.surfaceTransparent,
        foregroundColor: AppColors.iconSecondary,
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
    ),
  );
}
