import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_go_chat/core/services/app_scope/auth/auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthState currentState = .unauthorized;

  int? currentUserId;
  String? username;
  String? avatarUrl;

  String? accessToken;
  String? refreshToken;

  bool isLoading = false;

  Future<void> login(int newUserId) async {
    currentUserId = newUserId;
    currentState = .authorized;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', "$newUserId");

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');

    currentUserId = null;
    currentState = .unauthorized;

    notifyListeners();
  }

  Future<void> restoreSession() async {
  currentState = .authorizing;
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId');

    if (userId == null) {
      currentState = .unauthorized;
    } else {
      currentUserId = int.tryParse(userId);
      currentState = .authorized;
    }
  } catch (_) {
    currentState = .unauthorized;
  }

  notifyListeners();
}
}