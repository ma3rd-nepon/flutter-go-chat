import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tile.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';

class ChatListView extends StatelessWidget {

  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final chats = inherited.chats;
    final messages = inherited.messages;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: ListView.builder(
        reverse: true,
        itemCount: chats.length,
        itemBuilder: (_, index) {
          final chat = chats[index];
          return ChatTile(
            chatId: chat['id'],
            name: chat['name'] ?? "Name Error",
            lastMsg: messages.isNotEmpty ? messages.last : {"id": -1, "content": "Error", "sender_id": "228"},
            type: chat['type'],
            onTap: () => inherited.setChat(chat['id'])
          );
        },
      ),
    );
  }
}