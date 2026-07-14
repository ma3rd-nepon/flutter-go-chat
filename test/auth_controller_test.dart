import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_go_chat/core/services/app_scope/auth/auth_controller.dart';
import 'package:flutter_go_chat/core/services/app_scope/auth/auth_state.dart';
import 'package:flutter_go_chat/core/services/wss_http/http_service.dart';
import 'package:flutter_go_chat/core/services/wss_http/wss_service.dart';

class FakeApiService extends ApiService {
  String? savedToken;

  @override
  Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    if (endpoint == '/api/login') {
      return {'token': 'abc123'};
    }

    if (endpoint == '/api/register') {
      return {'token': 'abc123', 'user': {'id': 7}};
    }

    return null;
  }

  @override
  Future<void> setToken(String token) async {
    savedToken = token;
  }
}

class FakeWebSocketService extends WebSocketService {
  String? lastToken;
  bool connected = false;

  @override
  void connect(String token, {String url = 'localhost:8080'}) { // 'supernova-fzu6.onrender.com'
    lastToken = token;
    connected = true;
  }

  @override
  bool get isConnected => connected;
}

void main() {
  test('login stores token and connects websocket on success', () async {
    final api = FakeApiService();
    final wss = FakeWebSocketService();
    final controller = AuthController(httpService: api, wssService: wss);

    final result = await controller.login('Alice123', 'Password123');

    expect(result, 'success');
    expect(api.savedToken, 'abc123');
    expect(wss.lastToken, 'abc123');
    expect(controller.currentState, AuthState.authorized);
  });
}
