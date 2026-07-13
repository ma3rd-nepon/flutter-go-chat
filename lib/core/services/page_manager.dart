import 'package:flutter/material.dart';
import 'package:flutter_go_chat/core/icons/app_icons.dart';

class PageEntry {
  final PageId id;
  final Widget page;
  final bool canBeClosed;
  final bool hideUI;

  const PageEntry({
    required this.id,
    required this.page,
    this.canBeClosed = true,
    this.hideUI = false
  });
}

enum PageId {
  frame('supernova*', AppIcons.easterEgg),
  chat('Сообщения', AppIcons.chats),
  login('Регистрация', AppIcons.next),
  calls('Звонки', AppIcons.calls),
  music('Музыка', AppIcons.music),
  settings('Настройки', AppIcons.settings),
  profile('Профиль', AppIcons.profile),
  unknown('Ошибка', AppIcons.help);

  const PageId(this.label, this.icon);
  final String label;
  final IconData icon;
}

@Deprecated("Use NavigationController instead")
class PageManager extends ChangeNotifier {
  static const int maxPages = 6;

  final List<PageEntry> _pages = [];
  int _currentIndex = 0;
  int _previousIndex = 0;

  List<PageEntry> get pages => _pages;
  int get currentIndex => _currentIndex;
  PageEntry get currentPage => _pages[_currentIndex];

  // add or switch page
  void openPage(PageEntry entry) {
    final existingIndex = _pages.indexWhere((p) => p.id == entry.id);
    _previousIndex = _currentIndex;

    if (existingIndex != -1) {
      _currentIndex = existingIndex;
    } else {
      _pages.add(entry);

      if (_pages.length > maxPages) {
        _removeOldestClosable();
      }
      _currentIndex = _pages.length - 1;
    }
    notifyListeners();
  }

  void openPreviousPage() {
    _currentIndex = _previousIndex;
    notifyListeners();
  }

  void closePage(PageId id) {
    final entry = _pages.firstWhere((p) => p.id == id);
    if (!entry.canBeClosed) return;

    final index = _pages.indexWhere((p) => p.id == id);
    _pages.removeAt(index);

    if (_currentIndex >= _pages.length) {
      _currentIndex = _pages.length - 1;
    }
    if (_currentIndex < 0) _currentIndex = 0;

    notifyListeners();
  }

  void removePageForever(PageId id) {
    _pages.removeWhere((p) => p.id == id);
    if (_currentIndex >= _pages.length) {
      _currentIndex = _pages.length - 1;
    }
    if (_currentIndex < 0) _currentIndex = 0;
    notifyListeners();
  }

  // void switchTab(int index) {
  //   if (currentIndex != index) { _currentIndex = _tabs.length > index ? _pages.indexOf(_tabs[index]) : 0; }
  //   notifyListeners();
  // }

  void _removeOldestClosable() {
    for (int i = 0; i < _pages.length; i++) {
      if (_pages[i].canBeClosed) {
        _pages.removeAt(i);
        if (_currentIndex >= _pages.length) {
          _currentIndex = _pages.length - 1;
        }
        return;
      }
    }
  }
}