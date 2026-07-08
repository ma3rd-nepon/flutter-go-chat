import "package:flutter/material.dart";
import "package:flutter_go_chat/app/theme/theme_extension.dart";
import 'package:flutter_go_chat/features/chats/widgets/view/desktop_chat_tile.dart';
import 'package:flutter_go_chat/features/chats/widgets/chat_tabs.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/features/chats/widgets/view/mobile_chat_tile.dart';

class ChatListView extends StatelessWidget {
  final int tileWidth = 350;
  final int tileHeight = 210;
  final bool isDesktop;

  const ChatListView({super.key, this.isDesktop=true});

  @override
  Widget build(BuildContext context) {
    final inherited = ChatInherited.of(context);
    final db = inherited.db;
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      children: [
        SizedBox(height: 50),
        Expanded(
          child: Container(
            width: double.infinity,
            color: colors.chatListBackground,
            child: StreamBuilder<List<(Chat, Message?)>>(
              stream: db.watchAllChats(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // redesign
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("ERROR ChatListView on ${isDesktop ? "Desktop" : "Mobile"} UI: ${snapshot.error}"),
                  );
                }

                final chatList = snapshot.data ?? [];

                if (chatList.isEmpty) {
                  return Center(child: Text("Начните общение"));
                }
                final reverse = false;
                final itemCount = chatList.length;
                Widget itemBuilder(_, index) {
                  final pair = chatList[index];
                  return isDesktop ? ChatTile(
                    width: tileWidth,
                    height: tileHeight,
                    chat: pair.$1,
                    lastMsg: pair.$2,
                    onTap: () => inherited.setChat(pair.$1.id)
                  ) : MobileChatTile(
                    width: tileWidth,
                    height: tileHeight ~/ 2,
                    chat: pair.$1,
                    lastMsg: pair.$2,
                    onTap: () => inherited.setChat(pair.$1.id)
                  );
                } 

                return isDesktop ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: tileWidth.toDouble(),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: tileWidth / tileHeight,
                  ),
                  reverse: reverse,
                  itemCount: itemCount,
                  itemBuilder: itemBuilder
                ) : 
                ListView.builder(
                  reverse: reverse,
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
