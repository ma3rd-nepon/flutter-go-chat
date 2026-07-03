import 'package:flutter/material.dart';
import 'package:flutter_go_chat/services/page_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_go_chat/widgets/frame.dart';
import 'package:flutter_go_chat/screens/calls_screen.dart';
import 'package:flutter_go_chat/screens/chats_mobile_screen.dart';
// import 'package:go_dart_e2e/screens/chats_screen.dart';
import 'package:flutter_go_chat/screens/login_screen.dart';
import 'package:flutter_go_chat/screens/profile_screen.dart';
import 'package:flutter_go_chat/screens/settings_screen.dart';
import 'package:flutter_go_chat/widgets/window.dart';


class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _MainAppState();
}

class _MainAppState extends State<AppShell> with WindowListener {
  final _navigationManager = PageManager();
  final _screenManager = PageManager();
  int currentUserId = 0;
  bool _loggedIn = false;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _initScreens();
    _navigationManager.addListener(() => setState(() {}));
    _screenManager.addListener(() => setState(() {}));
    windowManager.addListener(this);
  }

  void _initScreens() {
    if (!_loggedIn) {
      _screenManager.openPage(
        PageEntry(
          id: PageId.login,
          page: LoginScreen(loginSuccess: onLoginSuccess),
        ),
      );
    }
  }

  void _initPages() {
    List<PageEntry> defaultPages = [
      PageEntry(
        id: PageId.chat,
        page: ChatsScreenMobile(currentUserId: currentUserId),
        canBeClosed: false,
      ),
      const PageEntry(id: PageId.calls, page: CallsScreen(), canBeClosed: false),
      const PageEntry(
        id: PageId.settings,
        page: SettingsScreen(),
        canBeClosed: false,
      ),
      const PageEntry(
        id: PageId.profile,
        page: ProfileScreen(),
        canBeClosed: false,
      ),
    ];

    for (final page in defaultPages) {
      _navigationManager.openPage(page);
    }
    _screenManager.openPage(
      PageEntry(
        id: PageId.frame,
        page: WindowFrame(navManager: _navigationManager),
      ),
    );
  }

  

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  void _toggleMaximize() {
    if (_isMaximized) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }
  
  void onLoginSuccess(int newUserId) {
    _screenManager.removePageForever(PageId.login);
    setState(() { currentUserId = newUserId; _loggedIn = true; });
    _initPages();
  }

  @override
  void dispose() {
    _navigationManager.dispose();
    _screenManager.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_screenManager.pages.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          WindowControls(maximize: _toggleMaximize),
          Expanded(
            child: IndexedStack(
              index: _screenManager.currentIndex,
              children: _screenManager.pages.map((e) => e.page).toList(),
            ),
          ),
        ],
      ),
    );
  }
}