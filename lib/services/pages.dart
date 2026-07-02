import 'package:flutter/material.dart';
import "package:flutter_resizable_container/flutter_resizable_container.dart";
import 'package:go_dart_e2e/widgets/buttons.dart';
import 'package:go_dart_e2e/theme/app_theme.dart';

// import "package:go_dart_e2e/widgets/buttons.dart";
import "package:go_dart_e2e/widgets/chat.dart";

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final Map<String, List<MessageBubble>> _items = chatList;
  int? _selectedIndex;
  String? _selectedChatName;

  void _sendMsg() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedIndex == null) return;

    setState(() {
      _items[_selectedIndex!]!.insert(0, MessageBubble(text: text, isMe: true));
      _focusNode.requestFocus();
      _controller.clear();
    });
  }

  void _setIndex(int? index, String? chatName) {
    setState(() {
      _selectedIndex = index;
      _selectedChatName = chatName;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Tabs(
          selectedIndex: _selectedIndex,
          setIndex: _setIndex,
          currentChatName: _selectedChatName,
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
                              child: ChatList(items: _items, reverse: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ResizableChild(
                      size: const ResizableSize.expand(min: 500),
                      child: ChatContent(
                        controller: _controller,
                        focusNode: _focusNode,
                        sendMsg: _sendMsg,
                        items: _items,
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

class LoginPage extends StatelessWidget {
  final VoidCallback loginSuccess;

  const LoginPage({super.key, required this.loginSuccess});

  void startLogin() {
    // this will be action with database
    if (true) {
      loginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Image.asset('assets/images/rabbit.png', width: 100, height: 100),
            const SizedBox(height: 15),
            Text("Sign in"),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(hintText: "Enter login"),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(width: 250, child: LoginWidget()),
            const SizedBox(height: 10),
            CustomButton(text: Text("БУРМАЛДА"), onPress: () => startLogin()),
          ],
        ),
      ),
    );
  }
}

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Hello world")));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Hello settings")));
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Hello Profile")));
  }
}

class ChatsPageMobile extends StatefulWidget {
  const ChatsPageMobile({super.key});

  @override
  State<ChatsPageMobile> createState() => _ChatsPageMobileState();
}

class _ChatsPageMobileState extends State<ChatsPageMobile> {
  final _controller = TextEditingController();
  final Map<String, List<MessageBubble>> _items = chatList;
  int? _selectedIndex;
  String? _selectedChatName;

  void _sendMsg() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedIndex == null) return;

    setState(() {
      _items[_items.keys.elementAt(_selectedIndex!)]!.insert(0, MessageBubble(text: text, isMe: true));
      _controller.clear();
    });
  }

  void _setIndex(int? index, String? chatName) {
    setState(() {
      _selectedIndex = index;
      _selectedChatName = chatName;
    });
  }

  // void _CloseChat() {
  //   Tabs.of(context).setIndex(null, null);
  // }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Tabs(
          selectedIndex: _selectedIndex,
          setIndex: _setIndex,
          currentChatName: _selectedChatName,
          scrollDirection: Axis.vertical,
          child: IndexedStack(
            alignment: AlignmentDirectional.centerStart,
            index: _selectedIndex == null ? 0 : 1,
            children: [
              ChatList(items: _items, reverse: false),
              ChatContent(
                controller: _controller,
                sendMsg: _sendMsg,
                items: _items,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
