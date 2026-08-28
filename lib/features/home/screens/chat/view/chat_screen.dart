import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' show Value;
import 'package:supernova_client/features/auth/cubit/auth_cubit.dart';
import 'package:supernova_client/features/auth/cubit/auth_state.dart';

import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';

import '../../../../../core/utils/database/db_service.dart';
import '../../../../../core/novacore.dart';
import '../../../../../ui/novakit.dart';
import '../../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) {
          return CircularProgressIndicator();
        }

        return ChatLayout(user: state.fullUser.$1);
      },
    );
  }
}

class ChatLayout extends StatefulWidget {
  const ChatLayout({super.key, required this.user});

  final User user;

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  Chat? _currentChat;
  late final UserMini userMini;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    userMini = UserMini(
      id: widget.user.id,
      username: widget.user.username,
      avatarUrl: widget.user.avatarUrl,
      displayName: widget.user.displayName,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void setChat(String? chatId) async {
    if (chatId == null) {
      setState(() {
        _currentChat = null;
      });
    } else {
      final newChat = await context.read<HomeCubit>().getChat(chatId);
      if (newChat == null) {
        return;
      } else {
        await context.read<HomeCubit>().batchChat(newChat.id);
        setState(() => _currentChat = newChat);
      }
    }
  }

  void _sendMessage(String text) async {
    // TODO Map<> content вместо text
    if (text.isEmpty || _currentChat == null) return;
    final message = MessagesCompanion(
      chatId: Value(_currentChat!.id),
      sender: Value(userMini),
      messageText: Value(text),
      kind: const Value('text'),
    );

    await context.read<HomeCubit>().sendMessage(message);

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
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (cntxt, state) {
        if (state is HomeLoadedState) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  SizedBox(
                    width: 380,
                    child: ChatList(
                      state: state,
                      selectedChat: _currentChat,
                      onTap: setChat,
                    ),
                  ),

                  NovaDivider.vertical(),

                  Expanded(
                    child: ChatBody(
                      state: state,
                      selectedChat: _currentChat,
                      sendMsg: _sendMessage,
                      setChat: setChat,
                      scrollController: scrollController,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.state,
    required this.selectedChat,
    required this.onTap,
  });

  final HomeLoadedState state;
  final Chat? selectedChat;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final chats = state.chats;
    final user = state.user;

    if (chats.isNotEmpty) {
      return ListView.builder(
        reverse: false,
        itemCount: chats.length,
        itemBuilder: (_, index) {
          final pair = chats[index];
          return ChatListTile(
            chat: pair.$1,
            isOpened: selectedChat?.id == pair.$1.id,
            lastMessage: pair.$2,
            onTap: () async {
              onTap(pair.$1.id);
            },
            isMe: user.id == pair.$2?.sender?.id,
          );
        },
      );
    } else {
      return Center(child: Text("Nothing here yet. Create your first chat!"));
    }
  }
}

// class ChatListView extends StatelessWidget {
//   const ChatListView({super.key, required this.chats});

//   List<(Chat, Message?)> chats;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       reverse: true,
//       itemCount: chats.length,
//       itemBuilder: (_, index) {
//         final pair = chats[index];
//         return ChatListTile(
//           chat: pair.$1,
//           lastMessage: pair.$2,
//           onTap: setChat(pair.$1.id)
//         );
//       },
//     );
//   }
// }

class ChatListTile extends StatefulWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.lastMessage,
    required this.isOpened,
    required this.onTap,
    required this.isMe,
  });

  final Chat chat;
  final bool isOpened;
  final Message? lastMessage;
  final VoidCallback onTap;
  final bool isMe;

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            height: 100,
            width: 300,
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: .circular(12),
              color: widget.isOpened
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
                    mainAxisAlignment: .spaceBetween,
                    crossAxisAlignment: .center,
                    children: [
                      Text(widget.chat.title ?? 'Chat Title'),
                      const SizedBox(height: 10),
                      widget.chat.type == 'private'
                          ? Text('was recently', style: TextStyle(fontSize: 13))
                          : SizedBox(height: 14),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .end,
                    children: [
                      widget.isMe
                          ? Icon(AppIcons.sent, size: 12)
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      widget.isMe ? Text('You') : SizedBox.shrink(),
                      Expanded(
                        child: Text(
                          widget.lastMessage?.messageText ?? '',
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),

                      const Spacer(),

                      widget.isMe
                          ? Text(
                              "${widget.lastMessage?.createdAt.hour.toString().padLeft(2, '0')}:${widget.lastMessage?.createdAt.minute.toString().padLeft(2, '0')}",
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

class ChatBody extends StatelessWidget {
  ChatBody({
    super.key,
    required this.state,
    required this.selectedChat,
    required this.sendMsg,
    required this.setChat,
    required this.scrollController,
  });

  final HomeLoadedState state;
  final Chat? selectedChat;
  final Function(String) sendMsg;
  final Function(String?) setChat;
  final ScrollController scrollController;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Widget get textFieldWidget => TextField(
    autofocus: true,
    focusNode: _focusNode,
    controller: _controller,
    decoration: InputDecoration(hintText: "Enter a Message"),
    onSubmitted: (_) => sendMsg(_controller.text.trim()),
  );

  void _notImp() => debugPrint("Not implemented");

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (selectedChat == null) {
      return Center(child: Text("Select a chat to start messaging"));
    } else {
      return Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            color: colors.chatBackground,
            height: 80,
            padding: const .all(8),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              children: [
                IconButton(
                  icon: Icon(AppIcons.back),
                  onPressed: () => setChat(null),
                ),
                Column(
                  children: [
                    Text(
                      selectedChat!.type == "private"
                          ? state.user.displayName
                          : selectedChat!.title!,
                    ),
                    SizedBox(height: 10),
                    Text(
                      selectedChat!.type == "private"
                          ? state.user.status
                          : "${selectedChat!.memberCount} members",
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(AppIcons.search),
                      iconSize: 20,
                      onPressed: () => _notImp(),
                    ),
                    IconButton(
                      icon: Icon(AppIcons.calls),
                      iconSize: 20,
                      onPressed: () => _notImp(),
                    ),
                    IconButton(
                      icon: Icon(AppIcons.panel),
                      iconSize: 20,
                      onPressed: () => _notImp(),
                    ),
                    IconButton(
                      icon: Icon(AppIcons.home),
                      iconSize: 20,
                      onPressed: () => _notImp(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            fit: .loose,
            child: MessageList(
              chat: selectedChat!,
              user: state.user,
              scrollController: scrollController,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: colors.inputBar,
                  child: textFieldWidget,
                ),
              ),
              IconButton(
                icon: Icon(AppIcons.send),
                iconSize: 25,
                onPressed: () => sendMsg(_controller.text.trim()),
              ),
            ],
          ),
        ],
      );
    }
  }
}

class MessageList extends StatelessWidget {
  MessageList({
    super.key,
    required this.chat,
    required this.user,
    required this.scrollController,
  });

  final _db = DatabaseService();
  final User user;
  final ScrollController scrollController;
  final Chat? chat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (chat == null) {
      return SizedBox.shrink();
    } else {
      final Stream<List<Message>> messageStream = _db.watchAllMessages(
        chat!.id,
      );

      return Container(
        width: double.infinity,
        color: colors.chatBackground,
        child: StreamBuilder<List<Message>>(
          stream: messageStream,
          builder: (_, snapshot) {
            if (snapshot.connectionState == .waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final messages = snapshot.data ?? [];

            if (messages.isEmpty) {
              return Center(child: Text("No messages here yet"));
            }

            return ListView.builder(
              controller: scrollController,
              scrollDirection: .vertical,
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (_, index) {
                return MessageBubble(
                  message: messages[index],
                  isMe: messages[index].sender?.id == user.id,
                );
              },
            );
          },
        ),
      );
    }
  }
}
