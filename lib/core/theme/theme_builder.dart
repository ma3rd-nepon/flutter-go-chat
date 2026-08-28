import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_const.dart';
import '../../ui/novakit.dart';
import 'theme_extension.dart';

class ThemeBuilder {
  static ThemeData buildInitialTheme() { return build(base: AppConst.initialBaseJson, accent: AppConst.initialAccentJson); }

  static ThemeData build({
    required Map<String, int> base,
    required Map<String, int> accent,
  }) {
    final palette = ThemePalette(base: base, accent: accent);

    return ThemeData(
      brightness: .dark,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      fontFamily: GoogleFonts.inter().fontFamily!,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.background,
        selectedIconTheme: IconThemeData(color: palette.iconActive),
        unselectedIconTheme: IconThemeData(color: palette.iconDisabled),
        indicatorColor: palette.primaryVariant,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.background,
        selectedItemColor: palette.iconActive,
        unselectedItemColor: palette.iconDisabled,
      ),

      // // NovaButton
      // novaButtonTheme: NovaButtonThemeData(
      //   style: NovaButton.styleFrom(
      //     backgroundColor: palette.primaryVariant,
      //     foregroundColor: palette.textPrimary,
      //   ),
      // ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputBar,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: palette.textHint),
      ),

      // Text
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: palette.textPrimary, fontSize: 24),
        titleMedium: TextStyle(color: palette.textSecondary, fontSize: 16),
        bodyLarge: TextStyle(color: palette.textTertiary, fontSize: 14),
        bodyMedium: TextStyle(color: palette.textSecondary, fontSize: 13),
        labelSmall: TextStyle(color: palette.textPrimary, fontSize: 11),
      ),

      // Icon
      iconTheme: IconThemeData(color: palette.iconPrimary),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: palette.surfaceTransparent,
          shadowColor: palette.surfaceTransparent,
          surfaceTintColor: palette.surfaceTransparent,
          foregroundColor: palette.iconSecondary,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: palette.surfaceVariant,
        thickness: 1,
      ),

      extensions: [AppThemeExtension(colors: palette)],
    );
  }
}
