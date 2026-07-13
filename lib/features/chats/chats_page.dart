import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_list_view.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_body.dart';
import 'package:drift/drift.dart';

class ChatsPage extends StatefulWidget {
  final int currentUserId;
  const ChatsPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  int? _currentChatId;
  late final _db = DatabaseService();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _setChat(int? chatId) async {
    setState(() {
      _currentChatId = chatId;
    });
    AppScope.read(context).uiController.toggleBar(true);
  }

  void _sendMessage(String text) async {
    if (text.isEmpty || _currentChatId == null) return;
    final message = MessagesCompanion(
      chatId: Value(_currentChatId!),
      senderId: Value(widget.currentUserId),
      content: Value(text),
      type: const Value("text"),
    );

    await _db.sendMessage(message);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ChatInherited(
            db: _db,
            currentUserId: widget.currentUserId,
            currentChatId: _currentChatId,
            setChat: _setChat,
            sendMessage: _sendMessage,
            scrollController: scrollController,
            child: IndexedStack(
              alignment: AlignmentDirectional.centerStart,
              index: _currentChatId == null ? 0 : 1,
              children: [
                ChatListView(isDesktop: g.isDesktop(context)),
                ChatBody(isDesktop: g.isDesktop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
