import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';

class AppColors {
  AppColors._();

  static String path = "assets/themes/theme_orange.json";
  static final colors =
      (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>).map(
        (key, color) => MapEntry(key, int.parse(color as String)),
      );

  static int color(String name) => colors[name] ?? 0xFF000000;

  static final background = Color(color("background"));
  static final surface = Color(color("surface"));
  static final surfaceVariant = Color(color("surface_variant"));
  static final surfaceHover = Color(color("surface_hover"));
  static final surfaceTransparent = Color(color("surface_transparent"));

  static final primary = Color(color("primary"));
  static final primaryVariant = Color(color("primary_variant"));
  static final secondary = Color(color("secondary"));

  static final textPrimary = Color(color("text_primary"));
  static final textSecondary = Color(color("text_secondary"));
  static final textHint = Color(color("text_hint"));

  static final online = Color(color("online"));
  static final error = Color(color("error"));
  static final warning = Color(color("warning"));

  static final chatListBackground = Color(color("chat_list_background"));
  static final chatBackground = Color(color("chat_background"));
  static final myMessageBubble = Color(color("my_message_bubble"));
  static final otherMessageBubble = Color(color("other_message_bubble"));
  static final inputBar = Color(color("input_bar"));

  static final surfaceIcon = Color(color("surface_icon"));
}

enum ThemeList {
  orange;
  // red,
  // blue,
  // lightBlue,
  // green;

  ThemeData get theme => switch (this) {
    ThemeList.orange => AppTheme.orangeTheme,
    // ThemeList.red => AppTheme.redTheme,
    // ThemeList.blue => AppTheme.blueTheme,
    // ThemeList.lightBlue => AppTheme.lightBlueTheme,
    // ThemeList.green => AppTheme.greenTheme,
  };
}

class AppTheme {
  AppTheme._();

  static ThemeData get orangeTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: const Color.fromARGB(255, 250, 55, 29),
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily!,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
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
      backgroundColor: AppColors.surface,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      indicatorColor: AppColors.primaryVariant,
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: AppColors.textHint),
    ),

    // Text
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontSize: 24),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      labelSmall: TextStyle(color: AppColors.textHint, fontSize: 11),
    ),

    // Icon
    iconTheme: IconThemeData(color: AppColors.textSecondary),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color.fromARGB(255, 241, 89, 0),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
    ),
  );
}
