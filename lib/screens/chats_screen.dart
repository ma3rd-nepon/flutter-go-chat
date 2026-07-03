import 'package:flutter/material.dart';
import "package:flutter_resizable_container/flutter_resizable_container.dart";
import 'package:flutter_go_chat/theme/app_theme.dart';
import 'package:flutter_go_chat/widgets/chat/message_bubble.dart';
import 'package:flutter_go_chat/widgets/chat/chat_body.dart';
import 'package:flutter_go_chat/widgets/chat/chat_list_view.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';


class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final Map<String, List<MessageBubble>> items = chatList;
  int? selectedIndex;
  String? selectedChatName;

  void _sendMsg() {
    final text = controller.text.trim();
    if (text.isEmpty || selectedIndex == null) return;

    setState(() {
      items[selectedIndex!]!.insert(0, MessageBubble(text: text, isMe: true));
      focusNode.requestFocus();
      controller.clear();
    });
  }

  void _setIndex(int? index, String? chatName) {
    setState(() {
      selectedIndex = index;
      selectedChatName = chatName;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ChatInherited(
          selectedIndex: selectedIndex,
          setIndex: _setIndex,
          currentChatName: selectedChatName,
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: ResizableContainer(
                  direction: Axis.horizontal,
                  children: [
                    ResizableChild(
                      divider: ResizableDivider(
                        thickness: 5,
                        color: AppColors.surfaceVariant,
                      ),
                      size: const ResizableSize.expand(min: 250, max: 400),
                      child: Container(
                        width: double.infinity,
                        color: AppColors.chatBackground,
                        child: Column(
                          crossAxisAlignment: .center,
                          mainAxisAlignment: .center,
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: "Search chats",
                              ),
                            ),
                            Expanded(
                              child: ChatListView(items: items, reverse: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ResizableChild(
                      size: const ResizableSize.expand(min: 500),
                      child: ChatBody(
                        controller: controller,
                        focusNode: focusNode,
                        sendMsg: _sendMsg,
                        items: items,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}