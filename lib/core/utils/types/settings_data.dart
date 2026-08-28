import '../../theme/theme_list.dart';

class SettingsData {
  final String currentLocale;
  final AppBaseThemeType currentBase;
  final AppAccentThemeType currentAccent;

  const SettingsData({
    required this.currentLocale,
    required this.currentBase,
    required this.currentAccent,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      currentLocale: json['current_locale'] ?? 'en',
      currentBase: AppBaseThemeType.values.firstWhere(
        (e) => e.name == json['current_base'],
        orElse: () => AppBaseThemeType.values.first,
      ),
      currentAccent: AppAccentThemeType.values.firstWhere(
        (e) => e.name == json['current_accent'],
        orElse: () => AppAccentThemeType.values.first,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "current_locale": currentLocale,
    "current_base": currentBase.name,
    "current_accent": currentAccent.name,
  };
}
