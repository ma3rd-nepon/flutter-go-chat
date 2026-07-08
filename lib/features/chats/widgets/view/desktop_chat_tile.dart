import "package:flutter/material.dart";
import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
class ChatTile extends StatefulWidget {
  final Chat chat;
  final Message? lastMsg;
  final VoidCallback onTap;
  final int width;
  final int height;

  const ChatTile({
    super.key,
    required this.lastMsg,
    required this.chat,
    required this.onTap,
    required this.width,
    required this.height
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final bool isMe = widget.lastMsg?.senderId == inherited.currentUserId;
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: MouseRegion(
        onHover: (event) => setState(() {
          _hover = true;
        }),
        onExit: (event) => setState(() {
          _hover = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: widget.height.toDouble(),
            width: widget.width.toDouble(),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: inherited.currentChatId == widget.chat.id
                  ? colors.surfaceSelected
                  : _hover
                  ? colors.surfaceHover
                  : colors.surfaceVariant,
            ),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: .center,
                    children: [
                      Image.asset(
                        'assets/images/rabbit.png',
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .start,
                        children: [
                          const SizedBox(height: 5),
                          Text(widget.chat.name ?? "NAME ERROR"),
                          const SizedBox(height: 10),
                          widget.chat.type == "private" ? Text("был(а) недавно") : SizedBox(height: 14), // websocket poll
                          // widget.chatStatus ? "онлайн" : "был(а) недавно",
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .end,
                          children: [
                            isMe ? Icon(AppIcons.sent) : SizedBox.shrink(),
                            // ? false
                            //       ? Icon(AppIcons.read)
                            //       : Icon(AppIcons.sent)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isMe ? Text("Вы: ") : SizedBox.shrink(),
                      FittedBox(child: Text(widget.lastMsg?.content ?? "None")),
                      const Spacer(),
                      FittedBox(child: Text("${widget.lastMsg?.createdAt.hour}:${widget.lastMsg?.createdAt.minute}")), // last Msg time
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(AppIcons.calls), onPressed: () {}),
                      IconButton(
                        icon: Icon(AppIcons.videoCall),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      isMe
                          ? SizedBox.shrink()
                          : CircleAvatar(
                              backgroundColor: colors.badge,
                              radius: 12,
                              child: Text(
                                "${widget.lastMsg?.content?.split(' ').length}",
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
