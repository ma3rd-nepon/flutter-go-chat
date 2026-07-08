import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

import 'package:flutter_go_chat/core/services/page_manager.dart';
import 'package:flutter_go_chat/core/widgets/app_tabs_bar.dart';
import 'package:flutter_go_chat/app/shell/window.dart';
import 'package:flutter_go_chat/features/calls/calls_page.dart';
import 'package:flutter_go_chat/features/profile/profile_page.dart';
import 'package:flutter_go_chat/features/chats/chats_page.dart';
import 'package:flutter_go_chat/features/settings/settings_page.dart';

class MainUIScreen extends StatefulWidget {
  final PageManager navManager;
  final int currentUserId;

  const MainUIScreen({
    super.key,
    required this.navManager,
    required this.currentUserId,
  });

  @override
  State<MainUIScreen> createState() => _MainUIScreenState();
}

class _MainUIScreenState extends State<MainUIScreen> {
  @override
  void initState() {
    super.initState();
    widget.navManager.addListener(updateState);
    _initPages();
  }

  @override
  void dispose() {
    widget.navManager.removeListener(updateState);
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  void _initPages() {
    List<PageEntry> defaultPages = [
      PageEntry(
        id: PageId.profile,
        page: ProfileScreen(),
        canBeClosed: false,
      ),
      PageEntry(
        id: PageId.chat,
        page: ChatsPage(
          currentUserId: widget.currentUserId),
        canBeClosed: false,
      ),
      PageEntry(
        id: PageId.calls,
        page: CallsScreen(),
        canBeClosed: false,
      ),
      PageEntry(
        id: PageId.settings,
        page: SettingsScreen(),
        canBeClosed: false,
      ),
    ];

    for (final page in defaultPages) {
      widget.navManager.openPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = GlobalScreenManager.of(context);

    return LayoutBuilder(
      builder: (cntxt, constraints) {
        final pagesWidget = Expanded(
          child: IndexedStack(
            index: widget.navManager.currentIndex,
            children: widget.navManager.pages.map((e) => e.page).toList(),
          ),
        );
        final childs = g.isDesktop(context)
            ? [
                const MyAppBar(),
                Expanded(
                  child: Row(
                    children: [
                      Align(
                        alignment: .topStart,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.5,
                            maxWidth: constraints.maxWidth * 0.25,
                          ),
                          child: AppRailBar(
                            navManager: widget.navManager,
                            constraints: constraints,
                          ),
                        ),
                      ),
                      pagesWidget,
                    ],
                  ),
                ),
              ]
            : [
                pagesWidget,
                Align(
                  alignment: .bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.25,
                      maxWidth: constraints.maxWidth * 0.72,
                    ),
                    child: AppBottomBar(
                      navManager: widget.navManager,
                      constraints: constraints,
                    ),
                  ),
                ),
              ];
        return Scaffold(
          body: SafeArea(
            child: Center(child: Column(children: childs)),
          ),
        );
      },
    );
  }
}


                // Stack children
                // children: [
                //   // background widget(), Stack

                //   Positioned.fill(
                //     left: isWide ? 300 : 0,
                //     child: IndexedStack(
                //     index: widget._navManager.currentIndex,
                //     children: widget._navManager.pages
                //         .map((e) => e.page)
                //         .toList(),
                //   )),
                //   isWide
                //       ? Positioned(
                //           top: 20,
                //           left: 20,
                //           child: ConstrainedBox(
                //             constraints: BoxConstraints(
                //               maxHeight: constraints.maxHeight * 0.5,
                //               maxWidth: constraints.maxWidth * 0.25,
                //             ),
                //             child: AppRailBar(navManager: widget._navManager, constraints: constraints),
                //           ),
                //         )
                //       : Positioned(
                //           bottom: 20,
                //           left: constraints.maxWidth * 0.14,
                //           child: ConstrainedBox(
                //             constraints: BoxConstraints(
                //               maxHeight: constraints.maxHeight * 0.25,
                //               maxWidth: constraints.maxWidth * 0.72,
                //             ),
                //             child: AppBottomBar(navManager: widget._navManager, constraints: constraints),
                //           ),
                //         ),
                // ],