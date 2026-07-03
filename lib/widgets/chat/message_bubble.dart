import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({super.key, required this.text, required this.isMe});

  String get message => text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.myMessageBubble
              : AppColors.otherMessageBubble,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text),
      ),
    );
  }
}
