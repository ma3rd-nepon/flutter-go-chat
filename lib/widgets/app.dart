import 'package:flutter/material.dart';
import 'package:go_dart_e2e/services/page_manager.dart';
import 'package:go_dart_e2e/services/pages.dart';
import 'package:go_dart_e2e/widgets/app_tabs_bar.dart';
import 'package:go_dart_e2e/widgets/window.dart';
import 'package:window_manager/window_manager.dart';

class MainAppManager extends StatefulWidget {
  final WindowManager _windowManager;
  const MainAppManager({super.key, required this._windowManager});

  @override
  State<MainAppManager> createState() => _MainAppState();
}

class _MainAppState extends State<MainAppManager> with WindowListener {
  final _navigationManager = PageManager();
  final _overlayManager = PageManager();
  bool _loggedIn = false;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _initPages();
    _navigationManager.addListener(() => setState(() {}));
    _overlayManager.addListener(() => setState(() {}));
    windowManager.addListener(this);
  }

  void _initPages() {
    List<PageEntry> defaultPages = [
      const PageEntry(
        id: PageId.chat,
        page: ChatsPageMobile(),
        canBeClosed: false,
      ),
      const PageEntry(id: PageId.calls, page: CallsPage(), canBeClosed: false),
      const PageEntry(
        id: PageId.settings,
        page: SettingsPage(),
        canBeClosed: false,
      ),
      const PageEntry(
        id: PageId.profile,
        page: ProfilePage(),
        canBeClosed: false,
      ),
    ];

    for (final page in defaultPages) {
      _navigationManager.openPage(page);
    }
    _overlayManager.openPage(
      PageEntry(
        id: PageId.frame,
        page: WindowFrame(navManager: _navigationManager),
      ),
    );

    if (!_loggedIn) {
      _overlayManager.openPage(
        PageEntry(
          id: PageId.login,
          page: LoginPage(loginSuccess: onLoginSuccess),
        ),
      );
    }
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

  void onLoginSuccess() {
    _overlayManager.removePageForever(PageId.login);
    setState(() => _loggedIn = true);
  }

  @override
  void dispose() {
    _navigationManager.dispose();
    _overlayManager.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_overlayManager.pages.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          HeaderBar(windowManager: windowManager, maximize: _toggleMaximize),
          Expanded(
            child: IndexedStack(
              index: _overlayManager.currentIndex,
              children: _overlayManager.pages.map((e) => e.page).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// bottomNavigationBar: _loggedIn
//     ? AppBottomBar(pageManager: _pageManager)
//     : null,

class WindowFrame extends StatefulWidget {
  final PageManager _navManager;

  const WindowFrame({super.key, required this._navManager});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> {
  @override
  void initState() {
    super.initState();
    widget._navManager.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        const MyAppBar(),
        Expanded(
          child: Row(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Expanded(
                flex: 1,
                child: AppRailBar(navManager: widget._navManager),
              ),
              Expanded(
                flex: 3,
                child: IndexedStack(
                  index: widget._navManager.currentIndex,
                  children: widget._navManager.pages
                      .map((e) => e.page)
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
