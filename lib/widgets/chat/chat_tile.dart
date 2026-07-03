import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';

class ChatTile extends StatefulWidget {
  final int chatId;
  final String name;
  final Map<String, dynamic> lastMsg;
  final String type;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMsg,
    required this.chatId,
    required this.type,
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
    final bool isMe = widget.lastMsg['sender_id'] == inherited.currentUserId;

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
          onTap: () => widget.onTap,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: inherited.currentChatId == widget.chatId.toString()
                  ? AppColors.primaryVariant
                  : _hover
                  ? AppColors.surface
                  : AppColors.chatListBackground,
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
                          Text(widget.name),
                          const SizedBox(height: 10),
                          Text("был(а) недавно"), // websocket poll
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
                      Text(widget.lastMsg['content']),
                      const Spacer(),
                      Text("21:43"), // last Msg time
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
                                "${widget.lastMsg['content'].split(' ').length}",
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
