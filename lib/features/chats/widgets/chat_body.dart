import "package:flutter/material.dart";
import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/features/chats/widgets/message_list.dart';
import 'package:flutter_go_chat/core/extensions/l10n_extension.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';

class ChatBody extends StatelessWidget {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final bool isDesktop;

  ChatBody({super.key, this.isDesktop=true});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;

    if (inherited.currentChatId == null) return const SizedBox.shrink();
    void sendMsg() {
      final text = _controller.text.trim();
      inherited.sendMessage(text);
      _controller.clear();
      _focusNode.requestFocus();
    }

    final textWidget = TextField(
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: InputDecoration(hintText: context.l10n.enterMessage),
                  onSubmitted: (_) => sendMsg());
    
    final enterMessageField = isDesktop ? textWidget : AnimatedPadding(
                    duration: Duration(milliseconds: 150),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: textWidget);

    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    return Column(
      mainAxisAlignment: .center,
      children: [
        Container(
          color: colors.chatBackground,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: .center,
            children: [
              IconButton(
                icon: Icon(AppIcons.back),
                onPressed: () { inherited.setChat(null); AppScope.read(context).uiController.toggleBar(false);},
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
                        text = context.l10n.unexpectError(snapshot.error.toString());
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
                children: isDesktop ? [
                  IconButton(
                    icon: Icon(AppIcons.search),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.calls),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.panel),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.home),
                    iconSize: 20,
                    onPressed: () => (),
                  ),
                ] : [
                  IconButton(
                    icon: Icon(AppIcons.other),
                    iconSize: 20,
                    onPressed: () {}
                  )
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
                color: colors.inputBar,
                child: enterMessageField,
                ),
              ),
            IconButton(
              onPressed: () => sendMsg(),
              icon: Icon(AppIcons.send),
              iconSize: 25,
            ),
          ],
        ),
      ],
    );
  }
}
