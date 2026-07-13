import 'dart:ui';

enum LocaleList {
  en("English"),
  ru("Русский"),
  uk("Українська"),
  // tt("Татарча"),
  de("Deutsch"),
  fr("Français");

  final String label;
  const LocaleList(this.label);

  Locale get locale => Locale(name);

  static LocaleList fromCode(String code) {
    return values.firstWhere(
      (e) => e.name == code,
      orElse: () => LocaleList.en,
    );
  }
}