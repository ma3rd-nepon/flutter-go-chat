import 'package:flutter/material.dart';
import 'package:flutter_go_chat/services/db_service.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/widgets/chat/chat_list_view.dart';
import 'package:flutter_go_chat/widgets/chat/chat_body.dart';
import 'package:drift/drift.dart';


class ChatsScreenMobile extends StatefulWidget {
  final int currentUserId;
  const ChatsScreenMobile({super.key, required this.currentUserId});

  @override
  State<ChatsScreenMobile> createState() => _ChatsScreenMobileState();
}

class _ChatsScreenMobileState extends State<ChatsScreenMobile> {
  final controller = TextEditingController();
  int? _currentChatId;
  late final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setChat(int? chatId) async {
    if (chatId != null) {
      setState(() {
        _currentChatId = chatId;
      });
    } else {
      setState(() {
        _currentChatId = chatId;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    // final text = controller.text.trim();
    if (text.isEmpty || _currentChatId == null) return;
    final message = MessagesCompanion(
      chatId: Value(_currentChatId!),
      senderId: Value(widget.currentUserId),
      content: Value(text),
      createdAt: Value(DateTime.now())
    );

    await _db.sendMessage(message);

  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ChatInherited(
          db: _db,
          currentUserId: widget.currentUserId,
          currentChatId: _currentChatId,
          setChat: _setChat,
          sendMessage: _sendMessage,
          child: IndexedStack(
            alignment: AlignmentDirectional.centerStart,
            index: _currentChatId == null ? 0 : 1,
            children: [
              ChatListView(),
              ChatBody()
            ],
          ),
        ),
      ),
    );
  }
}
