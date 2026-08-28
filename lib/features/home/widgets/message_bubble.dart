import 'package:flutter/material.dart';

import '../../../core/novacore.dart';
import '../../../ui/novakit.dart';
import '../../../core/utils/database/db_service.dart' show Message;

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  String get name => message.sender != null ? message.sender!.displayName : "unknown";

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe ? .end : .start,
        children: [
          isMe
              ? SizedBox.shrink()
              : CircleAvatar(
                  backgroundColor: colors.otherMessageBubble,
                  child: Text(name[0]),
                ),
            SizedBox(width: 5),

            Container(
              margin: const .all(4),
              padding: const .all(8),
              decoration: BoxDecoration(
                color: isMe ? colors.myMessageBubble : colors.otherMessageBubble,
                borderRadius: .circular(8)
              ),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .start,
                children: [
                  isMe ? SizedBox.shrink() : Text(name, style: TextStyle(fontSize: 11)),
                  isMe ? SizedBox.shrink() : SizedBox(height: 3),
                  Text(message.messageText ?? "", style: TextStyle(fontSize: 15)),
                ],
              )
            )
        ],
      ),
    );
  }
}
