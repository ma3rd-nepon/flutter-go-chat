import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/local_storage_service.dart';
import '../../features/auth/auth_layout.dart';
import '../../features/home/home_layout.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const auth = '/auth';
  static const profile = '/chat/:userId';
  static const chat = '/chat/:chatId';
  static const settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,

  redirect: (BuildContext context, GoRouterState state) {
    final storage = LocalStorageService.instance;
    final isLoggedIn = storage.token != null && storage.user != null;

    final goingToAuth = state.matchedLocation == AppRoutes.auth;

    if (!isLoggedIn && !goingToAuth) {
      return AppRoutes.auth;
    }

    if (isLoggedIn && goingToAuth) {
      return AppRoutes.home;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => _fadePage(state: state, child: const AppLayout()),
    ),

    GoRoute(
      path: AppRoutes.auth,
      name: 'auth',
      pageBuilder: (context, state) => _fadePage(state: state, child: const AuthLayout()),
    )
  ],

  errorPageBuilder: (context, state) => _fadePage(
    state: state,
    child: _RouterErrorScreen(error: state.error)
  )
);

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child, 
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child
    )
  );
}

CustomTransitionPage<void> _slidePage({
  required GoRouterState state,
  required Widget child
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, _, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(position: animation.drive(tween),  child: child);
    }
  );
}

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Page not found\n${error?.toString() ?? ""}',
          textAlign: .center,
        )
      )
    );
  }
}