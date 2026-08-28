import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supernova_client/core/router/app_router.dart';
import 'package:supernova_client/features/auth/cubit/auth_state.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';

import '../auth/cubit/auth_cubit.dart' show AuthCubit;

import '../../../core/utils/pages/page_control.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/constants/app_icons.dart';

// screens import
import 'screens/chat/view/chat_screen.dart';
import 'screens/music/view/music_screen.dart';
import 'screens/friends/view/friends_screen.dart';
import 'screens/settings/view/settings_screen.dart';
import 'screens/profile/view/profile_screen.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late final PageManager controller;

  @override
  void initState() {
    super.initState();

    controller = PageManager();
    controller.addListener(updateState);

    _initPages();
  }

  void _initPages() {
    List<PageConfig> defaultPages = [
      PageConfig(
        id: .profile,
        page: ProfileScreen(),
        canBeClosed: false,
        icon: AppIcons.profile,
      ),
      PageConfig(
        id: .chat,
        page: ChatScreen(),
        canBeClosed: false,
        icon: AppIcons.chats,
      ),
      PageConfig(
        id: .music,
        page: MusicScreen(),
        canBeClosed: false,
        icon: AppIcons.music,
      ),
      PageConfig(
        id: .friends,
        page: FriendsScreen(),
        canBeClosed: false,
        icon: AppIcons.unknown,
      ),
    ];

    PageConfig settingsPage = PageConfig(
      id: .settings,
      page: SettingsScreen(),
      canBeClosed: false,
      icon: AppIcons.settings,
    );

    controller.openPage(settingsPage);

    for (final page in defaultPages) {
      controller.openPage(page);
    }
  }

  void updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(updateState);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final colors = context.colors;
    // final isDesktop = MediaQuery.of(context).size.width > 800; // desktop breakpoint
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticatedState) { return CircularProgressIndicator(); }
    final user = authState.fullUser.$1;
    return BlocProvider(
      create: (_) => HomeCubit(user.id), // TODO вместо токена передавать айди 
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (layoutContext, constraints) {
              final pagesWidget = IndexedStack(
                index: controller.currentIndex,
                children: controller.pages.map((e) => e.page).toList(),
              );
              return Scaffold(
                body: SafeArea(
                  child: _DesktopSplitLayout(
                    pageController: controller,
                    child: pagesWidget,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DesktopSplitLayout extends StatelessWidget {
  const _DesktopSplitLayout({
    required this.pageController,
    required this.child,
  });

  final PageManager pageController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // ── Left Sidebar ─────────────────────────────────────────────────────
        _DesktopSidebar(pageController: pageController),

        // ── Vertical Divider ─────────────────────────────────────────────────
        Container(width: 1, color: colors.border),

        // ── Master List Pane ─────────────────────────────────────────────────
        Expanded(child: child),

        // ── Vertical Divider ─────────────────────────────────────────────────
        // Container(width: 1, color: colors.border),

        // ── Right Detail Pane ────────────────────────────────────────────────
        // const Expanded(child: _DesktopDetailPlaceholder()),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.pageController});

  final PageManager pageController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 80,
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          ...pageController.pages.map((page) {
          return _SidebarItem(
            icon: page.icon,
            label: page.label(context),
            selected:
                pageController.currentIndex ==
                pageController.pages.indexOf(page),
            onTap: () => pageController.openPage(page),
          );
        }),
        
        const Spacer(),

        _SidebarItem(
          icon: AppIcons.logout,
          label: 'Logout',
          selected: false,
          onTap: () {
            context.read<AuthCubit>().logout();
            context.go(AppRoutes.auth);
          },
        )
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 24,
                color: selected ? colors.primary : colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.primary : colors.textSecondary,
                fontWeight: selected ? .bold : .w500,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopDetailPlaceholder extends StatelessWidget {
  const _DesktopDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.background,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.forum,
                      size: 48,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  Text(
                    'Desktop Screen',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'This is a placeholder for the detail pane. Select a chat or request from the left to view its details here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Encryption Notice at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.lock,
                  size: 14,
                  color: colors.textHint,
                ),
                const SizedBox(width: 6),
                Text(
                  'All messages are end-to-end encrypted',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.border.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: AppIcons.home,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: AppIcons.request,
            label: 'Requests',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: AppIcons.settings,
            label: 'Settings',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: AppIcons.logout,
            label: 'Logout',
            selected: false,
            onTap: () {
              context.read<AuthCubit>().logout();
              context.go(AppRoutes.auth);
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 26,
                color: selected ? colors.primary : colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.primary : colors.textSecondary,
                fontWeight: selected ? .bold : .w500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: selected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
