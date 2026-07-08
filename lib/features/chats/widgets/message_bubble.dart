import "package:flutter/material.dart";
import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/core/services/database/db_service.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  String get text => message.content ?? "Сообщение удалено";

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe? .end : .start,
        children: [
          isMe
              ? SizedBox.shrink()
              : CircleAvatar(
                  backgroundColor: colors.otherMessageBubble,
                  child: Text(message.senderId.toString()),
                ),
          SizedBox(width: 5),
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe
                  ? colors.myMessageBubble
                  : colors.otherMessageBubble,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                isMe ? SizedBox.shrink() : Text("user ID: ${message.senderId}", style: TextStyle(fontSize: 11)), // emir sdelay norm db
                isMe ? SizedBox.shrink() : SizedBox(height: 3),
                Text(text, style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
