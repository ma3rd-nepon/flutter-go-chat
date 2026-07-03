import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/widgets/chat/message_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final messages = inherited.messages;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        reverse: false,
        itemCount: messages.length,
        itemBuilder: (_, index) {
          return MessageBubble(
            text: messages[index]['content'], 
            isMe: messages[index]['sender_id'] == inherited.currentUserId
          );
        },
      ),
    );
  }
}
