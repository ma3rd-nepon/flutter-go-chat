import "package:flutter/material.dart";
import 'dart:math';

import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';

class MobileChatTile extends StatefulWidget {
  final Chat chat;
  final Message? lastMsg;
  final VoidCallback onTap;
  final int width;
  final int height;

  const MobileChatTile({
    super.key,
    required this.lastMsg,
    required this.chat,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  State<MobileChatTile> createState() => _MobileChatTileState();
}

class _MobileChatTileState extends State<MobileChatTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final bool isMe = widget.lastMsg?.senderId == inherited.currentUserId;
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final height = max(widget.height, 50);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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
            height: height.toDouble(),
            width: widget.width.toDouble(),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
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
                        width: 44,
                        height: 44,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          mainAxisAlignment: .start,
                          children: [
                            Text(widget.chat.name ?? context.l10n.nameError),
                            const SizedBox(height: 10),
                            widget.chat.type == "private"
                                ? Text(
                                    context.l10n.wasRecently,
                                    style: TextStyle(fontSize: 13),
                                  )
                                : SizedBox(height: 14), // websocket poll
                            // widget.chatStatus ? "онлайн" : "был(а) недавно",
                          ],
                        ),
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
                      isMe ? Text(context.l10n.you) : SizedBox.shrink(),
                      Expanded(
                        child: Text(
                          widget.lastMsg?.content ?? "None",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      isMe
                          ? Text(
                              "${widget.lastMsg?.createdAt.hour}:${widget.lastMsg?.createdAt.minute}",
                            )
                          : Expanded(
                              flex: 2,
                              child: Align(
                                alignment: .centerEnd,
                                child: CircleAvatar(
                                  backgroundColor: colors.badge,
                                  radius: 12,
                                  child: SizedBox.shrink(),
                                ),
                              ),
                            ), // last Msg time
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
