import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/navigation/page_config.dart';

/// Управление страницами навигационного бара
class NavigationController extends ChangeNotifier {
  static const int maxPages = 6;

  final List<PageConfig> _pages = [];
  int _currentIndex = 0;
  int _previousIndex = 0;

  List<PageConfig> get pages => _pages;
  int get currentIndex => _currentIndex;
  PageConfig get currentPage => _pages[_currentIndex];

  void openPage(PageConfig entry) {
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