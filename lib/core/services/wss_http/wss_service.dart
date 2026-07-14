import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  WebSocketService._internal();

  factory WebSocketService() => _instance;

  IOWebSocketChannel? _channel;

  final StreamController<Map<String, dynamic>> _streamController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _streamController.stream;

  String? _token;
  late final SharedPreferences prefs;
  bool get isConnected => _channel != null;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      connect(_token!);
    }
  }

  void connect(String token, {String url = 'localhost:8080'}) { // 'supernova-fzu6.onrender.com'
    if (isConnected) {
      disconnect();
    }

    _token = token;
    final wsUrl = 'ws://$url/api/ws?token=$_token';
    debugPrint('WebSocket connect: $wsUrl');

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (raw) {
        try {
          final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
          if (!_streamController.isClosed) {
            _streamController.add(data);
          }
        } catch (e) {
          debugPrint('WS parse error: $e');
        }
      },
      onError: (err) {
        debugPrint('WS error: $err');
        _safeReconnect();
      },
      onDone: () {
        debugPrint('WS closed');
        _channel = null;
        _safeReconnect();
      },
    );
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected) {
      debugPrint('WS not connected');
      return;
    }
    _channel!.sink.add(jsonEncode(data));
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _token = null;
  }

  void _safeReconnect() {
    if (_token == null || isConnected) return;
    debugPrint('Reconnecting in 3s...');
    Future.delayed(const Duration(seconds: 3), () {
      if (_token != null && !isConnected) {
        connect(_token!);
      }
    });
  }
}