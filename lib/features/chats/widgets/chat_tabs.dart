import "package:flutter/material.dart";
import "package:flutter_go_chat/core/services/database/db_service.dart";

class ChatInherited extends InheritedWidget { // сделать синхру через chatId
  final DatabaseService db;
  final int currentUserId;                          // кто я
  final int? currentChatId;                       // какой чат открыт (String, потому что INTEGER в SQLite = int в Dart, но для id лучше int)
  final Function(int? chatId) setChat;               // переключить чат
  final Function(String text) sendMessage;   
  final String currentChatStatus = "был(а) недавно";
  final ScrollController scrollController;

  const ChatInherited({
    super.key,
    required super.child,
    required this.db,
    required this.currentUserId,
    required this.currentChatId,
    required this.setChat,
    required this.sendMessage,
    required this.scrollController
  });

  static ChatInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatInherited>()!;
  }

  @override
  bool updateShouldNotify(ChatInherited old) {
    return currentChatId != old.currentChatId;
  }
}