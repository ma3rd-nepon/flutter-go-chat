import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AppLocale {
  AppLocale._();

  static Map<String, String> _locales = {};

  static Future<void> init(Language type) async {
    _locales.clear();

    final localeJson = await rootBundle.loadString(
      "assets/locales/${type.jsonName}",
    );

    _locales = (jsonDecode(localeJson) as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, value as String);
    });
  }

  static String locale(String name) => _locales[name] ?? "Unknown key";
}

enum LocaleKey {
  commonOk("common.ok"),
  commonCancel("common.cancel"),

  chatSearch("chat.search"),

  settingsLanguage("settings.language");

  const LocaleKey(this.key);

  final String key;
}

enum Language {
  ru("ru.json"),
  en("en.json");

  const Language(this.jsonName);

  final String jsonName;
}