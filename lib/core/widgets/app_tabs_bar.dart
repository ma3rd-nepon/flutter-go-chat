import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/services/page_manager.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class AppBottomBar extends StatelessWidget {
  final PageManager navManager;
  final BoxConstraints constraints;

  const AppBottomBar({
    super.key,
    required this.navManager,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    if (navManager.pages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      alignment: .center,
      width: 400,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex(navManager.pages),
        onTap: (index) => navManager.openPage(navManager.pages[index]),
        unselectedFontSize: 8,
        selectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.sidebarBackground,
        items: navManager.pages.map(_buildItem).toList(),
      ),
    );
  }

  int _currentNavIndex(List<PageEntry> pages) {
    final currentId = navManager.currentPage.id;
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

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      alignment: .topStart,
      width: 200,
      height: constraints.maxHeight * 0.3,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: NavigationRail(
        extended: true,
        minExtendedWidth: 200,
        selectedIndex: _currentNavIndex(navManager.pages),
        onDestinationSelected: (index) {
          navManager.openPage(navManager.pages[index]);
        },
        backgroundColor: colors.sidebarBackground,
        destinations: navManager.pages.map(_buildItem).toList(),
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
