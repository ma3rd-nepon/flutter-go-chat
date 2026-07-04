import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tile.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/services/db_service.dart';

class ChatListView extends StatelessWidget {

  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: StreamBuilder<List<(Chat, Message?)>>(
        stream: db.watchAllChats(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // redesign
          }
          if (snapshot.hasError) {
            return Center(child: Text("ERROR ChatListView: ${snapshot.error}"));
          }
          
          final chatList = snapshot.data ?? [];

          if (chatList.isEmpty) {
            return Center(child: Text("Начните общение"));
          }

          return ListView.builder(
        reverse: true,
        itemCount: chatList.length,
        itemBuilder: (_, index) {
          final pair = chatList[index];
          return ChatTile(
            chat: pair.$1,
            lastMsg: pair.$2,
            onTap: () => inherited.setChat(pair.$1.id)
          );
        },
      );
        }
      )
    );
  }
}