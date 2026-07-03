import 'package:flutter/material.dart';
import 'package:flutter_go_chat/services/db_service.dart';
import 'package:flutter_go_chat/widgets/chat/chat_tabs.dart';
import 'package:flutter_go_chat/widgets/chat/chat_list_view.dart';
import 'package:flutter_go_chat/widgets/chat/chat_body.dart';


class ChatsScreenMobile extends StatefulWidget {
  final int currentUserId;
  const ChatsScreenMobile({super.key, required this.currentUserId});

  @override
  State<ChatsScreenMobile> createState() => _ChatsScreenMobileState();
}

class _ChatsScreenMobileState extends State<ChatsScreenMobile> {
  final controller = TextEditingController();
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _messages = [];
  int? _currentChatId;
  late final DatabaseService _db;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService();
    _db.init().then((_) => _loadChats());
  }

  Future<void> _loadChats() async {
    final chats = await _db.getUserChats(widget.currentUserId);
    setState(() => _chats = chats);
  }

  Future<void> _setChat(int? chatId) async {
    if (chatId != null) {
      final messages = await _db.getChatHistory(chatId);
      setState(() {
        _currentChatId = chatId;
        _messages = messages;
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

    await _db.sendMessage(
      chatId: _currentChatId!,
      senderId: widget.currentUserId,
      content: text
    );

    await _setChat(_currentChatId!); // refresh message list ???

    // setState(() {
    //   items[items.keys.elementAt(selectedIndex!)]!.insert(0, MessageBubble(text: text, isMe: true));
    //   controller.clear();
    // });
  }

  // void setIndex(int? index, String? chatName) {
  //   setState(() {
  //     selectedIndex = index;
  //     selectedChatName = chatName;
  //   });
  // }

  // void _CloseChat() {
  //   Tabs.of(context).setIndex(null, null);
  // }

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
          currentChatId: _currentChatId?.toString(),
          chats: _chats,
          messages: _messages,
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
