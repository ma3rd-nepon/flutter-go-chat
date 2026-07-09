import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/page_manager.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/core/services/global_screen_manager.dart';

class AppBottomBar extends StatefulWidget {
  final PageManager navManager;
  final BoxConstraints constraints;

  const AppBottomBar({
    super.key,
    required this.navManager,
    required this.constraints,
  });

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
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
    if (widget.navManager.pages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final g = GlobalScreenManager.of(context);

    return AnimatedSlide(
      duration: const Duration(
        milliseconds: 250,
      ), // потом добавим множитель анимаций
      offset: g.barHidden ? Offset(0, 0.75) : Offset.zero,
      child: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Container(
          height: 100,
          width: 400,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          alignment: .topStart,
          child: Column(
            children: [
              Align(
                alignment: .centerStart,
                child: ButtonTheme(
                  height: 8,
                  child: ElevatedButton(
                    onPressed: () => g.barToggle(),
                    child: Icon(AppIcons.easterEgg),
                  ),
                ),
              ),

              Container(
                alignment: .center,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentNavIndex(widget.navManager.pages),
                  onTap: (index) => widget.navManager.openPage(
                    widget.navManager.pages[index],
                  ),
                  unselectedFontSize: 8,
                  selectedFontSize: 10,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: colors.sidebarBackground,
                  items: widget.navManager.pages.map(_buildItem).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _currentNavIndex(List<PageEntry> pages) {
    final currentId = widget.navManager.currentPage.id;
    final index = pages.indexWhere((t) => t.id == currentId);
    return index != -1 ? index : 0;
  }

  BottomNavigationBarItem _buildItem(PageEntry entry) {
    return BottomNavigationBarItem(
      icon: Icon(entry.id.icon),
      label: entry.id.label,
    );
  }
}

class AppRailBar extends StatelessWidget {
  final PageManager navManager;
  final BoxConstraints constraints;

  const AppRailBar({
    super.key,
    required this.navManager,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    if (navManager.pages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final g = GlobalScreenManager.of(context);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: g.barHidden ? Offset(-0.8, 0) : Offset.zero,
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 20),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          height: constraints.maxHeight * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              NavigationRail(
                extended: true,
                minExtendedWidth: 200,
                selectedIndex: _currentNavIndex(navManager.pages),
                onDestinationSelected: (index) {
                  navManager.openPage(navManager.pages[index]);
                },
                backgroundColor: colors.sidebarBackground,
                destinations: navManager.pages.map(_buildItem).toList(),
              ),
              Align(
                alignment: .topStart,
                child: ButtonTheme(
                  height: 5,
                  minWidth: 5,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: ElevatedButton(
                      onPressed: () => g.barToggle(),
                      child: Icon(AppIcons.easterEgg),
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

  int _currentNavIndex(List<PageEntry> pages) {
    final currentId = navManager.currentPage.id;
    final index = pages.indexWhere((t) => t.id == currentId);
    return index != -1 ? index : 0;
  }

  NavigationRailDestination _buildItem(PageEntry entry) {
    return NavigationRailDestination(
      icon: Icon(entry.id.icon),
      label: Text(entry.id.label),
    );
  }
}
