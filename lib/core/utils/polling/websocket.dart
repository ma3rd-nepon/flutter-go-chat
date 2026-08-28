import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import '../database/db_service.dart'
    show DatabaseService, Message, chatFromMap, messagefromMap;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  WebSocketService._internal();

  factory WebSocketService() => _instance;

  IOWebSocketChannel? _channel;
  bool _connected = false;

  final _messageController = StreamController<Message>.broadcast();

  Stream<Message> get messages => _messageController.stream;

  String? _token;
  final _db = DatabaseService();
  late final SharedPreferences prefs;
  bool get isConnected => _connected;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      connect(_token!);
    }
  }

  void connect(String token, {String url = 'api.supernova-lately.ru'}) {
    // 'supernova-fzu6.onrender.com'
    if (isConnected) {
      disconnect();
    }

    _token = token;
    final wsUrl = 'ws://$url/ws?token=$_token';
    debugPrint('WebSocket connect: $wsUrl');

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (raw) async {
        try {
          _connected = true;
          final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
          switch (data['event']) {
            case 'new_message':
              final msgData = data['data'];
              if (msgData is Map) {
                final message = messagefromMap(msgData);
                await _db.sendMessage(message); // ???? ВХАХЫВ ЧЗХ
              }
            case 'connected':
            // logging.info('WS connected');
              _connected = true;
            case 'message_updated':
              if (data['data'] is Map) {
                final message = messagefromMap(data['data']);
                await _db.sendMessage(message);
              }
            // TODO message update
            case 'chat_created':
              debugPrint('DATA IS - $data');
              final newChat = data['data']['chat'];

              if (newChat is Map) {
                final chat = chatFromMap(newChat);
                await _db.createChat(chat: chat);
              }
            case 'chat_updated':
            // TODO
            case 'chat_deleted':
            // TODO
            case 'member_added':
            // TODO
            case 'member_removed':
            // TODO
            case 'member_restricted':
            // TODO
            case 'member_unrestricted':
            // TODO
            case 'typing_start':
            // TODO
            case 'typing_stop':
            // TODO
            case 'presence_changed':
            // TODO
            case 'notification_created':
            // TODO
            case 'friend_request':
            // TODO
            case 'friend_accepted':
            // TODO
            case 'voice_state_updated':
            // TODO
            case 'messages_read':
            // TODO
          }
        } catch (e, st) {
          debugPrint('WS parse error in $st: $e');
        }
      },
      onError: (err) {
        debugPrint('WS error: $err');
        _connected = false;
        _safeReconnect();
      },
      onDone: () {
        debugPrint('WS closed');
        _channel = null;
        _connected = false;
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
    _connected = false;
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
