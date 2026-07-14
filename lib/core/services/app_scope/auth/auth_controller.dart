import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/wss_http/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_go_chat/core/services/wss_http/wss_service.dart';
import 'package:flutter_go_chat/core/services/app_scope/auth/auth_state.dart';
import 'package:dio/dio.dart';

class AuthController extends ChangeNotifier {
  AuthController({ApiService? httpService, WebSocketService? wssService})
    : _http = httpService ?? ApiService(),
      _wss = wssService ?? WebSocketService();

  AuthState currentState = AuthState.unauthorized;

  String? currentUserId;
  String? username;
  String? avatarUrl;

  String? _accessToken;
  final ApiService _http;
  final WebSocketService _wss;

  late SharedPreferences _prefs;

  bool isLoading = false;
  bool needRegister = false;

  void switchRegister() {
    needRegister = !needRegister;

    notifyListeners();
  }

  Future<String> login(String username, String password) async {
    currentState = AuthState.authorizing;
    notifyListeners();

    try {
      // if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,31}$').hasMatch(username)) {
      //   return 'error bad username';
      // }
      // if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password)) {
      //   return 'error bad password';
      // }
      debugPrint("1");

      final result = await _http.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      if (result == null) {
        return 'error: auth service unavailable';
      }

      debugPrint("2");

      if (result['error'] != null) {
        return 'error : ${result['error']}';
      }

      final token = result['token']?.toString();
      if (token == null || token.isEmpty) {
        return 'error: no token';
      }

      debugPrint("3");

      await _http.setToken(token);
      _accessToken = token;
      _wss.connect(token);

      debugPrint("4");

      final user = result['user'];
      if (user is Map) {
        currentUserId = user['id'] is String ? user['id'] as String : null;
        username = user['username']?.toString() ?? "error";
        avatarUrl = user['avatarUrl']?.toString();
      }

      currentState = AuthState.authorized;

      debugPrint("5");
    } catch (e) {
      debugPrint('ERROR: $e');
      currentState = AuthState.unauthorized;
      return 'unexpected error';
    }

    notifyListeners();
    return 'success';
  }

  Future<String> register(String username, String password) async {
    currentState = AuthState.authorizing;
    notifyListeners();

    debugPrint(username);
    debugPrint(password);

    try {
      if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,31}$').hasMatch(username)) {
        return 'bad username';
      }
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password)) {
        return 'bad password';
      }

      final result = await _http.post(
        '/register',
        data: {'username': username, 'password': password},
      );

      if (result == null) {
        return 'error during register';
      }

      if (result['error'] != null) {
        return 'error : ${result['error']}';
      }

      final token = result['token']?.toString();
      if (token == null || token.isEmpty) {
        return 'error: no token';
      }

      await _http.setToken(token);
      _accessToken = token;
      _wss.connect(token);

      final user = result['user'];
      if (user is Map) {
        currentUserId = user['id'] is String ? user['id'] as String : null;
        username = user['username']?.toString() ?? "error";
        avatarUrl = user['avatarUrl']?.toString();
      }

      debugPrint('user registered');
      currentState = AuthState.authorized;
    } catch (e) {
      debugPrint('ERROR: $e');
      currentState = AuthState.unauthorized;
      return 'error';
    }

    notifyListeners();
    return 'success';
  }

  Future<void> logout() async {
    await _http.clearToken();
    _wss.disconnect();

    currentUserId = null;
    username = null;
    avatarUrl = null;
    _accessToken = null;
    currentState = AuthState.unauthorized;

    debugPrint('token removed');
    notifyListeners();
  }

  Future<void> restoreSession() async {
    if (currentState == .authorized) { return; }
    
    currentState = AuthState.authorizing;
    notifyListeners();

    try {
      _prefs = await SharedPreferences.getInstance();
      final token = _prefs.getString('token');

      if (token == null) {
        currentState = AuthState.unauthorized;
        debugPrint('no token in memory');
      } else {
        debugPrint('token reading');
        _accessToken = token;
        await _http.setToken(token);
        _wss.connect(token);

        final result = await _http.get(
          '/users/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (result == null) {
          debugPrint("error during reading token");
        }
        final user = result!['user'];
        if (user is Map) {
          currentUserId = user['id'] is String ? user['id'] as String : null;
          username = user['username']?.toString() ?? "error";
          avatarUrl = user['avatarUrl']?.toString();
          currentState = AuthState.authorized;
        }
      }
    } catch (e) {
      debugPrint('ERROR: $e');
      currentState = AuthState.unauthorized;
    }

    notifyListeners();
  }
}
