// import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:supernova_client/core/constants/app_const.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ThemePalette colors;

  const AppThemeExtension({required this.colors});

  @override
  AppThemeExtension copyWith({ThemePalette? colors}) {
    return AppThemeExtension(colors: colors ?? this.colors);
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;

    return t < 0.5 ? this : other;
  }
}

class ThemePalette {
  final Map<String, int> base;
  final Map<String, int> accent;

  const ThemePalette({required this.base, required this.accent});

  factory ThemePalette.fallback() {
    return const ThemePalette(
      base: AppConst.initialBaseJson,
      accent: AppConst.initialAccentJson
    );
  }

  //
  // BASE
  //

  Color get background => Color(base["background"]!);
  Color get backgroundSecondary => Color(base["background_secondary"]!);

  Color get surface => Color(base["surface"]!);
  Color get surfaceVariant => Color(base["surface_variant"]!);
  Color get surfaceElevated => Color(base["surface_elevated"]!);

  Color get surfaceShadow => Color(base["surface_shadow"]!);

  //
  // STATES
  //

  Color get surfaceHover => Color(base["surface_hover"]!);
  Color get surfacePressed => Color(base["surface_pressed"]!);
  Color get surfaceSelected => Color(base["surface_selected"]!);
  Color get surfaceFocus => Color(base["surface_focus"]!);

  Color get surfaceTransparent => Color(base["surface_transparent"]!);

  //
  // CHAT
  //

  Color get chatBackground => Color(base["chat_background"]!);

  Color get chatListBackground => Color(base["chat_list_background"]!);

  //
  // INPUT
  //

  Color get inputBar => Color(base["input_bar"]!);

  Color get inputBackground => Color(base["input_background"]!);

  Color get inputFocus => Color(base["input_focus"]!);

  //
  // NAVIGATION
  //

  Color get tabActive => Color(base["tab_active"]!);
  Color get tabInactive => Color(base["tab_inactive"]!);

  Color get sidebarBackground => Color(base["sidebar_background"]!);

  Color get sidebarHover => Color(base["sidebar_hover"]!);

  Color get sidebarSelected => Color(base["sidebar_selected"]!);

  //
  // FILE TYPES
  //

  Color get audio => Color(base["audio"]!);
  Color get video => Color(base["video"]!);
  Color get document => Color(base["document"]!);
  Color get archive => Color(base["archive"]!);

  //
  // ACCENT
  //

  Color get primary => Color(accent["primary"]!);
  Color get primaryHover => Color(accent["primary_hover"]!);

  Color get primaryPressed => Color(accent["primary_pressed"]!);

  Color get primaryVariant => Color(accent["primary_variant"]!);

  Color get secondary => Color(accent["secondary"]!);

  Color get secondaryVariant => Color(accent["secondary_variant"]!);

  //
  // TEXT
  //

  Color get textPrimary => Color(accent["text_primary"]!);

  Color get textSecondary => Color(accent["text_secondary"]!);

  Color get textTertiary => Color(accent["text_tertiary"]!);

  Color get textHint => Color(accent["text_hint"]!);

  Color get textDisabled => Color(accent["text_disabled"]!);

  //
  // ICONS
  //

  Color get iconPrimary => Color(accent["icon_primary"]!);

  Color get iconSecondary => Color(accent["icon_secondary"]!);

  Color get iconActive => Color(accent["icon_active"]!);

  Color get iconDisabled => Color(accent["icon_disabled"]!);

  //
  // BORDERS
  //

  Color get border => Color(accent["border"]!);

  Color get borderLight => Color(accent["border_light"]!);

  Color get borderActive => Color(accent["border_active"]!);

  //
  // CHAT BUBBLES
  //

  Color get myMessageBubble => Color(accent["my_message_bubble"]!);

  Color get myMessageHover => Color(accent["my_message_hover"]!);

  Color get otherMessageBubble => Color(accent["other_message_bubble"]!);

  Color get otherMessageHover => Color(accent["other_message_hover"]!);

  Color get messageSelected => Color(accent["message_selected"]!);

  //
  // STATUS
  //

  Color get online => Color(accent["online"]!);
  Color get away => Color(accent["away"]!);
  Color get busy => Color(accent["busy"]!);
  Color get offline => Color(accent["offline"]!);

  //
  // NOTIFICATIONS
  //

  Color get badge => Color(accent["badge"]!);
  Color get badgeText => Color(accent["badge_text"]!);

  Color get mention => Color(accent["mention"]!);

  Color get unread => Color(accent["unread"]!);

  //
  // CALLS
  //

  Color get callAccept => Color(accent["call_accept"]!);

  Color get callDecline => Color(accent["call_decline"]!);

  //
  // FEEDBACK
  //

  Color get success => Color(accent["success"]!);

  Color get warning => Color(accent["warning"]!);

  Color get error => Color(accent["error"]!);

  Color get info => Color(accent["info"]!);
}

extension NovaThemeExtension on BuildContext {
  ThemePalette get colors =>
      Theme.of(this).extension<AppThemeExtension>()?.colors ??
      ThemePalette.fallback();

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
