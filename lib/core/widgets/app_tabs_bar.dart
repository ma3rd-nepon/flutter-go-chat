import 'package:flutter/material.dart';

import 'package:flutter_go_chat/app/theme/theme_extension.dart';
import 'package:flutter_go_chat/core/widgets/buttons.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/core/widgets/nova_design/nova_design.dart';

class AppBottomBar extends StatefulWidget {
  final NavigationController navController;
  final BoxConstraints constraints;

  const AppBottomBar({
    super.key,
    required this.navController,
    required this.constraints,
  });

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  late final UIController uiController;

  @override
  void initState() {
    super.initState();

    uiController = AppScope.read(context).uiController;
    uiController.addListener(updateState);
  }

  void updateState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    uiController.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.navController.pages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final g = AppScope.of(context);

    final uiController = g.uiController;

    return AnimatedSlide(
      duration: const Duration(
        milliseconds: 250,
      ), // потом добавим множитель анимаций
      offset: uiController.barHidden ? Offset(0, 0.75) : Offset.zero,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: NovaContainer(
          height: widget.constraints.maxHeight * 0.15,
          width: widget.constraints.maxWidth * 0.6,
          padding: EdgeInsets.all(2),
          margin: EdgeInsets.all(2),
          alignment: .topStart,
          child: Column(
            mainAxisSize: .min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: NavBarToggler(
                    onPressed: () => uiController.toggleBar(null),
                    isActive: !uiController.barHidden,
                  ),
                ),
              ),

              NovaContainer(
                alignment: .center,
                child: BottomNavigationBar(
                  currentIndex: _currentNavIndex(widget.navController.pages),
                  onTap: (index) => widget.navController.openPage(
                    widget.navController.pages[index],
                  ),
                  unselectedFontSize: 8,
                  selectedFontSize: 10,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: colors.sidebarBackground,
                  items: widget.navController.pages
                      .map((page) => _buildItem(page, context))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _currentNavIndex(List<PageConfig> pages) {
    final currentId = widget.navController.currentPage.id;
    final index = pages.indexWhere((t) => t.id == currentId);
    return index != -1 ? index : 0;
  }

  BottomNavigationBarItem _buildItem(PageConfig entry, BuildContext context) {
    return BottomNavigationBarItem(
      icon: Icon(entry.icon),
      label: entry.label(context),
    );
  }
}

class AppRailBar extends StatefulWidget {
  final NavigationController navController;
  final BoxConstraints constraints;

  const AppRailBar({
    super.key,
    required this.navController,
    required this.constraints,
  });

  @override
  State<AppRailBar> createState() => _AppRailBarState();
}

class _AppRailBarState extends State<AppRailBar> {
  late final UIController uiController;
  @override
  void initState() {
    super.initState();

    uiController = AppScope.read(context).uiController;
    uiController.addListener(updateState);
  }

  void updateState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    uiController.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.navController.pages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final g = AppScope.of(context);

    final uiController = g.uiController;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: uiController.barHidden ? Offset(-0.85, 0) : Offset.zero,
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 20),
        child: NovaContainer(
          padding: EdgeInsets.only(left: 5, top: 10, right: 10, bottom: 10),
          margin: EdgeInsets.only(left: 5, top: 10, right: 10, bottom: 10),
          height: widget.constraints.maxHeight * 0.3,
          child: Row(
            mainAxisSize: .min,
            children: [
              NavigationRail(
                extended: true,
                minExtendedWidth: 200,
                selectedIndex: _currentNavIndex(widget.navController.pages),
                onDestinationSelected: (index) {
                  widget.navController.openPage(
                    widget.navController.pages[index],
                  );
                },
                backgroundColor: colors.sidebarBackground,
                destinations: widget.navController.pages
                    .map((page) => _buildItem(page, context))
                    .toList(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: NavBarToggler(
                      onPressed: () => uiController.toggleBar(null),
                      isActive: !uiController.barHidden,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _currentNavIndex(List<PageConfig> pages) {
    final currentId = widget.navController.currentPage.id;
    final index = pages.indexWhere((t) => t.id == currentId);
    return index != -1 ? index : 0;
  }

  NavigationRailDestination _buildItem(PageConfig entry, BuildContext context) {
    return NavigationRailDestination(
      icon: Icon(entry.icon),
      label: Text(entry.label(context)),
    );
  }
}
