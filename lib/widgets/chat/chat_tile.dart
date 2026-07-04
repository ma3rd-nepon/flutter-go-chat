import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/services/db_service.dart';
class ChatTile extends StatefulWidget {
  final Chat chat;
  final Message? lastMsg;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.lastMsg,
    required this.chat,
    required this.onTap,
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
            height: 200,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: inherited.currentChatId == widget.chat.id
                  ? AppColors.primaryVariant
                  : _hover
                  ? AppColors.chatListBackground
                  : AppColors.surface,
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
                          widget.chat.type == "private" ? Text("был(а) недавно") : SizedBox(height: 20), // websocket poll
                          // widget.chatStatus ? "онлайн" : "был(а) недавно",
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .end,
                          children: [
                            isMe ? Icon(Icons.check) : SizedBox.shrink(),
                            // ? false
                            //       ? Icon(Icons.done_all)
                            //       : Icon(Icons.check)
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
                      Text(widget.lastMsg?.content ?? "None"),
                      const Spacer(),
                      Text("${widget.lastMsg?.createdAt.hour}:${widget.lastMsg?.createdAt.minute}"), // last Msg time
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(Icons.call), onPressed: () {}),
                      IconButton(
                        icon: Icon(Icons.video_call),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      isMe
                          ? SizedBox.shrink()
                          : CircleAvatar(
                              backgroundColor: AppColors.myMessageBubble,
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
