import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tile.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/services/db_service.dart';
import 'package:drift/drift.dart';

class ChatListView extends StatelessWidget {

  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;
    final chats = db.watchAllChats(inherited.currentUserId);

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: StreamBuilder<List<Chat>>(
        stream: chats,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // redesign
          }
          if (snapshot.hasError) {
            return Center(child: Text("Ошипка: ${snapshot.error}"));
          }
          
          final chatList = snapshot.data ?? [];

          if (chatList.isEmpty) {
            return Center(child: Text("Начните общение"));
          }

          return ListView.builder(
        reverse: true,
        itemCount: chatList.length,
        itemBuilder: (_, index) {
          final chat = chatList[index];
          return ChatTile(
            chatId: chat.id,
            name: chat.name ?? "Name Error",
            lastMsg: MessagesCompanion(content: Value("zxczxczxc"), senderId: Value(inherited.currentUserId)) as Message,
            type: chat.type,
            onTap: () => inherited.setChat(chat.id)
          );
        },
      );
        }
      )
    );
  }
}