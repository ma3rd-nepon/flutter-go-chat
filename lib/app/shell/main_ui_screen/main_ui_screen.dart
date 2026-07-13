import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/widgets/app_tabs_bar.dart';
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/app/shell/window.dart';

import 'package:flutter_go_chat/features/calls/calls_page.dart';
import 'package:flutter_go_chat/features/profile/profile_page.dart';
import 'package:flutter_go_chat/features/chats/chats_page.dart';
import 'package:flutter_go_chat/features/settings/settings_page.dart';

import 'package:flutter_go_chat/core/layers/particles/particle_system.dart';
import 'package:flutter_go_chat/core/layers/wallpaper/wallpaper_layer.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';

import 'package:flutter_go_chat/core/widgets/nova_design/nova_design.dart';

class MainUIScreen extends StatefulWidget {
  final int currentUserId;

  const MainUIScreen({super.key, required this.currentUserId});

  @override
  State<MainUIScreen> createState() => _MainUIScreenState();
}

class _MainUIScreenState extends State<MainUIScreen> {
  late final NavigationController navController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    navController = AppScope.read(context).navController;
    navController.addListener(updateState);

    _initPages();
  }

  @override
  void dispose() {
    navController.removeListener(updateState);
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  void _initPages() {
    List<PageConfig> defaultPages = [
      PageConfig(
        id: PageId.profile,
        page: ProfileScreen(),
        canBeClosed: false,
        icon: AppIcons.profile,
      ),
      PageConfig(
        id: PageId.chat,
        page: ChatsPage(currentUserId: widget.currentUserId),
        canBeClosed: false,
        icon: AppIcons.chats,
      ),
      PageConfig(
        id: PageId.calls,
        page: CallsScreen(),
        canBeClosed: false,
        icon: AppIcons.calls,
      ),
      PageConfig(
        id: PageId.settings,
        page: SettingsScreen(),
        canBeClosed: false,
        icon: AppIcons.settings,
      ),
    ];

    for (final page in defaultPages) {
      navController.openPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = AppScope.of(context);
    final isDesktop = g.isDesktop(context);
    final uiController = g.uiController;

    return LayoutBuilder(
      builder: (cntxt, constraints) {
        final pagesWidget = IndexedStack(
          index: navController.currentIndex,
          children: navController.pages.map((e) => e.page).toList(),
        );
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Wallpaper layer
                      // Positioned.fill(
                      //   left: 0,
                      //   top: 0,
                      //   child: g.wallpaperUrl != null
                      //       ? Image.network(g.wallpaperUrl!, fit: BoxFit.fill)
                      //       : Container(
                      //           color: colors.background,
                      //         ), // Image.asset(wallpaper)
                      // ),
                      Positioned.fill(left: 0, top: 0, child: WallpaperLayer()),

                      // Particle effect layer
                      Positioned.fill(left: 0, top: 0, child: ParticleSystem()),

                      NovaContainer(
                        alignment: .topCenter,
                        padding: EdgeInsets.all(5),
                        child: MyAppBar(),
                      ),

                      // Pages layer
                      ListenableBuilder(
                        listenable: uiController,
                        builder: (context, child) {
                          return AnimatedPadding(
                            duration: Duration(
                              milliseconds: 270,
                            ), // модификатор анимаций
                            padding: EdgeInsets.only(
                              left: isDesktop && !uiController.barHidden ? isDesktop ? 270 : 30 : 1,
                              top: 90,
                              bottom: isDesktop ? 20 : !uiController.barHidden ? 1 : 35,
                              right: isDesktop ? 20 : 1,
                            ),
                            child: NovaContainer(child: pagesWidget),
                          );
                        },
                      ),

                      // Widgets Layer
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Align(
                          alignment: g.isDesktop(context)
                              ? .topStart
                              : .bottomCenter,
                          child: g.isDesktop(context)
                              ? AppRailBar(
                                  navController: navController,
                                  constraints: constraints,
                                )
                              : AppBottomBar(
                                  navController: navController,
                                  constraints: constraints,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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