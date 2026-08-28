abstract class AppConst {
  // INITIAL THEME
  static const initialBaseJson = {
        "background": 0xDD121212,
        "background_secondary": 0xFF181818,
        "surface": 0xDD1B1D20,
        "surface_variant": 0xFF25282C,
        "surface_elevated": 0xFF2C3138,
        "surface_hover": 0x14FFFFFF,
        "surface_pressed": 0x22FFFFFF,
        "surface_selected": 0x1AFF9F43,
        "surface_focus": 0x33FF9F43,
        "surface_transparent": 0x00FFFFFF,
        "chat_background": 0xDD101418,
        "chat_list_background": 0xDD171A1E,
        "input_bar": 0xFF1A1E24,
        "input_background": 0xFF23272E,
        "input_focus": 0xFFFF9F43,
        "tab_active": 0xFFFF9F43,
        "tab_inactive": 0xFF8B9198,
        "sidebar_background": 0xFF171A1E,
        "sidebar_hover": 0xFF232830,
        "sidebar_selected": 0xFF2C323A,
        "audio": 0xFF42A5F5,
        "video": 0xFFE57373,
        "document": 0xFFAB47BC,
        "archive": 0xFF78909C,
      };
  static const initialAccentJson = {
        "primary": 0xFF4DA3FF,
        "primary_hover": 0xFF69B3FF,
        "primary_pressed": 0xFF2E8FFF,
        "primary_variant": 0xFF1976D2,
        "secondary": 0xFFB3D9FF,
        "secondary_variant": 0xFFD6EAFF,
        "text_primary": 0xFFF2F2F2,
        "text_secondary": 0xFFB3B8C0,
        "text_tertiary": 0xFF8D939B,
        "text_hint": 0xFF6D737A,
        "text_disabled": 0xFF5A5A5A,
        "icon_primary": 0xFFEAEAEA,
        "icon_secondary": 0xFF9AA0A8,
        "icon_active": 0xFF4DA3FF,
        "icon_disabled": 0xFF5A5A5A,
        "border": 0xFF343A40,
        "border_light": 0xFF444B54,
        "border_active": 0xFF4DA3FF,
        "my_message_bubble": 0xFF2B7CD3,
        "my_message_hover": 0xFF3D8CE0,
        "other_message_bubble": 0xFF2A2E33,
        "other_message_hover": 0xFF343941,
        "message_selected": 0x334DA3FF,
        "online": 0xFF4CAF50,
        "away": 0xFFFFC107,
        "busy": 0xFFF44336,
        "offline": 0xFF6B7280,
        "badge": 0xFF4DA3FF,
        "badge_text": 0xFFFFFFFF,
        "mention": 0xFF80C3FF,
        "unread": 0xFF4DA3FF,
        "call_accept": 0xFF4CAF50,
        "call_decline": 0xFFE53935,
        "success": 0xFF4CAF50,
        "warning": 0xFFFFC107,
        "error": 0xFFCF6679,
        "info": 0xFF42A5F,
      };

  // SOME DIGITS
  static const double borderWidthL = 2.0;
  static const double borderWidthM = 1.5;
  static const double radius = 0.0;
  static const cut = 12.0;
}

abstract class AppFonts {
  static const String displayFont = "Unbounded";
  static const String bodyFont = "Manrope";
  static const String monoFont = "JetBrainsMono";
}