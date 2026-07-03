import "package:flutter/material.dart";
import "package:flutter_go_chat/services/db_service.dart";

class ChatInherited extends InheritedWidget { // сделать синхру через chatId
  final DatabaseService db;
  final int currentUserId;                          // кто я
  final String? currentChatId;                       // какой чат открыт (String, потому что INTEGER в SQLite = int в Dart, но для id лучше int)
  final List<Map<String, dynamic>> chats;           // список чатов
  final List<Map<String, dynamic>> messages;         // сообщения текущего чата
  final Function(int? chatId) setChat;               // переключить чат
  final Function(String text) sendMessage;   
  final String currentChatStatus = "был(а) недавно";

  const ChatInherited({
    super.key,
    required super.child,
    required this.db,
    required this.currentUserId,
    required this.currentChatId,
    required this.chats,
    required this.messages,
    required this.setChat,
    required this.sendMessage
  });

  static ChatInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatInherited>()!;
  }

  @override
  bool updateShouldNotify(ChatInherited old) {
    return currentChatId != old.currentChatId ||
           chats.length != old.chats.length ||
           messages.length != old.messages.length;
  }
}