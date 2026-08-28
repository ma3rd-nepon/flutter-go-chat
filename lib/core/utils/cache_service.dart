import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'database/db_service.dart' show User;
import '../theme/theme_list.dart';
import 'types/settings_data.dart';

abstract class CacheService {
  Future<void> init();
  
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> clearToken();

  Future<void> saveUser(User user);
  User? getUser();
  Future<void> clearUser();
  
  Future<void> saveSettingsData(SettingsData data);
  SettingsData getSettingsData();
  Future<void> clearSettingsData();
}

class MemoryService implements CacheService {
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString('user_token', token);
  }

  @override
  String? getToken() {
    return _prefs.getString('user_token');
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove('user_token');
  }

  @override
  Future<void> saveUser(User user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  @override
  User? getUser() {
    final data = _prefs.getString('user_data');
    if (data == null) return null;

    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove('user_data');
  }

  @override
  Future<void> saveSettingsData(SettingsData data) async {
    await _prefs.setString('settings_data', jsonEncode(data.toJson()));
  }

  @override
  SettingsData getSettingsData() {
    final data = _prefs.getString('settings_data');
    if (data == null) {
      final Map<String, String> baseSettings = {
        'current_locale': 'en',
        'current_base': AppBaseThemeType.dark.name,
        'current_accent': AppAccentThemeType.blue.name
      };

      return SettingsData.fromJson(baseSettings);
    }

    return SettingsData.fromJson(
      jsonDecode(data)
    );
  }

  @override
  Future<void> clearSettingsData() async {
    await _prefs.remove('settings_data');
  }
}