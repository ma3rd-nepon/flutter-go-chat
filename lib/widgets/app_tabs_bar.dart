import 'package:flutter/material.dart';
import 'package:flutter_go_chat/services/page_manager.dart';
import 'package:flutter_go_chat/theme/app_theme.dart';

class AppBottomBar extends StatelessWidget {
  final PageManager navManager;

  const AppBottomBar({super.key, required this.navManager});

  @override
  Widget build(BuildContext context) {
    if (navManager.pages.isEmpty) return const SizedBox.shrink();

    return BottomNavigationBar(
      currentIndex: _currentNavIndex(navManager.pages),
      onTap: (index) => navManager.openPage(navManager.pages[index]),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      items: navManager.pages.map(_buildItem).toList(),
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

  const AppRailBar({super.key, required this.navManager});

  @override
  Widget build(BuildContext context) {

    if (navManager.pages.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 300,
      child: NavigationRail(
        extended: true,
        minExtendedWidth: 250,
        selectedIndex: _currentNavIndex(navManager.pages),
        onDestinationSelected: (index) => navManager.openPage(navManager.pages[index]),
        backgroundColor: AppColors.background,
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
