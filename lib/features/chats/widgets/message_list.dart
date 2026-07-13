import "package:flutter/material.dart";
import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/features/chats/widgets/message_bubble.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    if (inherited.currentChatId == null) {
      return SizedBox.shrink();
    }

    final Stream<List<Message>> messagesStream = db.watchAllMessages(
      inherited.currentChatId!,
    );

    return Container(
      width: double.infinity,
      color: colors.chatBackground,
      child: StreamBuilder<List<Message>>(
        stream: messagesStream,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.unexpectError(snapshot.error.toString())));
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return Center(child: Text(context.l10n.emptyChats));
          }

          return ListView.builder(
            controller: inherited.scrollController,
            scrollDirection: Axis.vertical,
            reverse: false,
            itemCount: messages.length,
            itemBuilder: (_, index) {
              return MessageBubble(
                message: messages[index],
                isMe: messages[index].senderId == inherited.currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}
