import "package:flutter/material.dart";
import "package:go_dart_e2e/theme/app_theme.dart";
import "package:go_dart_e2e/widgets/buttons.dart";

List<MessageBubble> messageList1 = [
  MessageBubble(text: "вляпалась", isMe: false),
  MessageBubble(text: "врезалась", isMe: false),
  MessageBubble(text: "потеряла голову", isMe: true),
  MessageBubble(text: "вкрашилась", isMe: true),
  MessageBubble(text: "втрескалась", isMe: false),
  MessageBubble(text: "я просто в тебя втюрилась", isMe: true),
  MessageBubble(text: "но я не влюблена в тебя", isMe: false),
  MessageBubble(text: "я спрятала улыбку", isMe: false),
  MessageBubble(text: "но ты проходишь мимо", isMe: false),
  MessageBubble(text: "я все еще мечтаю о тебе", isMe: true),
  MessageBubble(text: "привет", isMe: true),
];

List<MessageBubble> messageList2 = [
  MessageBubble(text: "я сигма бой", isMe: false),
  MessageBubble(text: "пошла нахуй дура", isMe: false),
  MessageBubble(text: "чем твое безразличие", isMe: true),
  MessageBubble(text: "твои крики лучше", isMe: true),
  MessageBubble(text: "как раньше", isMe: false),
  MessageBubble(text: "поругайся со мной", isMe: true),
  MessageBubble(text: "можешь покричать на меня", isMe: false),
  MessageBubble(text: "мне так нехватает твоих истерик", isMe: true),
  MessageBubble(text: "сошел с ума", isMe: false),
  MessageBubble(text: "я наверно", isMe: true),
  MessageBubble(text: "привет", isMe: true),
];

Map<String, List<MessageBubble>> chatList = {
  "123": messageList1,
  "222": messageList2,
  "chat": messageList1,
  "haha": messageList2,
  "emir": messageList1,
  "tiktok": messageList2,
  "ppp": messageList1,
  "111": messageList2,
}; // its a big cringe momento but emir still hasn't provided me with a copy of the database

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({super.key, required this.text, required this.isMe});

  String get message => text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.myMessageBubble
              : AppColors.otherMessageBubble,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text),
      ),
    );
  }
}

class ChatListElement extends StatefulWidget {
  final String _chatName;
  final String _chatLastMsg;
  final bool _chatStatus;
  final int _index;
  final bool isMe;

  const ChatListElement({
    super.key,
    required this._chatName,
    required this._chatLastMsg,
    this.isMe = true,
    this._chatStatus = false,
    required this._index,
  });

  @override
  State<ChatListElement> createState() => _ChatListElementState();
}

class _ChatListElementState extends State<ChatListElement> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
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
          onTap: () =>
              Tabs.of(context).setIndex(widget._index, widget._chatName),
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Tabs.of(context).selectedIndex == widget._index
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
                          Text(widget._chatName),
                          const SizedBox(height: 10),
                          Text(
                            widget._chatStatus ? "онлайн" : "был(а) недавно",
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .end,
                          children: [
                            widget.isMe
                                ? widget._chatStatus
                                      ? Icon(Icons.done_all)
                                      : Icon(Icons.check)
                                : SizedBox.shrink(),
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
                      widget.isMe ? Text("Вы: ") : SizedBox.shrink(),
                      Text(widget._chatLastMsg),
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
                      CustomIconButton(icon: Icon(Icons.call), onPress: () {}),
                      CustomIconButton(
                        icon: Icon(Icons.video_call),
                        onPress: () {},
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: AppColors.myMessageBubble,
                        radius: 12,
                        child: Text("${widget._chatLastMsg.split(" ").length}"),
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

class WidgetList extends StatelessWidget {
  final List<Widget> _items;
  final bool reverse;

  const WidgetList({super.key, required this._items, this.reverse = false});

  @override
  Widget build(BuildContext context) {
    final Axis scrollDirection = Tabs.of(context).scrollDirection;
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: scrollDirection,
        reverse: reverse,
        itemCount: _items.length,
        itemBuilder: (cntxt, index) {
          return _items[index];
        },
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  final Map<String, List<MessageBubble>> _items;
  final bool reverse;

  const ChatList({super.key, required this._items, this.reverse = false});

  @override
  Widget build(BuildContext context) {
    final Axis scrollDirection = Tabs.of(context).scrollDirection;
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: ListView.builder(
        scrollDirection: scrollDirection,
        reverse: reverse,
        itemCount: _items.length,
        itemBuilder: (_, index) {
          return ChatListElement(
            chatName: _items.keys.elementAt(index),
            chatLastMsg: _items[_items.keys.elementAt(index)]!.first.message,
            index: index,
            isMe: _items[_items.keys.elementAt(index)]!.first.isMe,
          );
        },
      ),
    );
  }
}

class Tabs extends InheritedWidget {
  final int? selectedIndex;
  final int animationDuration;
  final bool scrollable;
  final Axis scrollDirection;
  final String? currentChatName;
  final Function(int?, String?) setIndex;

  const Tabs({
    super.key,
    required super.child,
    required this.scrollDirection,
    required this.setIndex,
    required this.selectedIndex,
    required this.currentChatName,
    this.animationDuration = 0,
    this.scrollable = true,
  });

  static Tabs of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Tabs>()!;
  }

  @override
  bool updateShouldNotify(Tabs old) => old.selectedIndex != selectedIndex;
}

class ChatContent extends StatelessWidget {
  final TextEditingController _controller;
  final VoidCallback _sendMsg;
  final Map<String, List<MessageBubble>> _items;
  final FocusNode? _focusNode;

  const ChatContent({
    super.key,
    required this._controller,
    required this._sendMsg,
    required this._items,
    this._focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (Tabs.of(context).selectedIndex == null) return const SizedBox.shrink();

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
              CustomIconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPress: () => Tabs.of(context).setIndex(null, null),
              ),
              Column(
                children: [
                  Builder(
                    builder: (context) =>
                        Text(Tabs.of(context).currentChatName!),
                  ),
                  SizedBox(height: 10),
                  Text("был(а) давно"),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  CustomIconButton(
                    icon: Icon(Icons.search),
                    iconSize: 20,
                    onPress: () => (),
                  ),
                  CustomIconButton(
                    icon: Icon(Icons.call),
                    iconSize: 20,
                    onPress: () => (),
                  ),
                  CustomIconButton(
                    icon: Icon(Icons.tab),
                    iconSize: 20,
                    onPress: () => (),
                  ),
                  CustomIconButton(
                    icon: Icon(Icons.house),
                    iconSize: 20,
                    onPress: () => (),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: WidgetList(
            items:
                _items[_items.keys.elementAt(Tabs.of(context).selectedIndex!)]
                    as List<Widget>,
            reverse: true,
          ),
        ),
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
                  onSubmitted: (value) => _sendMsg(),
                ),
              ),
            ),
            CustomIconButton(
              onPress: _sendMsg,
              icon: Icon(Icons.send),
              iconSize: 25,
            ),
          ],
        ),
      ],
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});
  @override
  State<LoginWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginWidget> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscured,
      decoration: InputDecoration(
        hintText: 'Enter password',
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
