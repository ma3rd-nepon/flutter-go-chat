import "package:flutter/material.dart";
import "package:flutter_go_chat/theme/app_theme.dart";
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/widgets/chat/message_list.dart';

class ChatBody extends StatelessWidget {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;

    if (inherited.currentChatId == null) return const SizedBox.shrink();
    void sendMsg() => (value) {
      final text = _controller.text.trim();
      inherited.sendMessage(text);
      _controller.clear();
      _focusNode.requestFocus();
    };

    return Column(
      mainAxisAlignment: .center,
      children: [
        Container(
          color: AppColors.chatBackground,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: .center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () => inherited.setChat(null),
              ),
              Column(
                children: [
                  FutureBuilder(
                    future: db.getChat(inherited.currentChatId!),
                    builder: (_, snapshot) {
                      String text = "";
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        text = "...";
                      }
                      if (snapshot.hasError) {
                        text = "Error: ${snapshot.error}";
                      }
                      
                      if (text.isEmpty) {
                        text = snapshot.data?.name ?? "...";
                      }

                      return Text(text);
                    },
                  ),
                  SizedBox(height: 10),
                  Text(inherited.currentChatStatus), // websocket poll
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(Icons.call),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(Icons.tab),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(Icons.house),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(flex: 9, child: MessageList()),
        Row(
          children: [
            Expanded(
              child: Container(
                color: AppColors.inputBar,
                child: TextField(
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Enter a message"),
                  onSubmitted: (_) => sendMsg(),
                ),
              ),
            ),
            IconButton(
            onPressed: () => sendMsg(),
              icon: Icon(Icons.send),
              iconSize: 25,
            ),
          ],
        ),
      ],
    );
  }
}
