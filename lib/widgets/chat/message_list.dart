import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/widgets/chat/message_bubble.dart';
import 'package:flutter_go_chat/services/db_service.dart';
import 'package:drift/drift.dart';


class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;

    if (inherited.currentChatId == null) {
      return SizedBox.shrink();
    }

    final Stream<List<Message>> messagesStream = db.watchAllMessages(inherited.currentChatId!);

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: StreamBuilder<List<Message>>(
        stream: messagesStream,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("ОШипка: ${snapshot.error}"));
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return Center(child: Text("Начните общение"));
          }

          return ListView.builder(
        scrollDirection: Axis.vertical,
        reverse: false,
        itemCount: messages.length,
        itemBuilder: (_, index) {
          return MessageBubble(
            text: messages[index].content ?? "Сообщение удалено", 
            isMe: messages[index].senderId == inherited.currentUserId
          );
        },
      );
        }
      )
      
      
    );
  }
}