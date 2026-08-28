import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'features/auth/cubit/auth_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';
import 'core/router/app_router.dart';

class AppShell extends StatefulWidget {
  const AppShell._internal();

  static final AppShell _instance = AppShell._internal();

  factory AppShell() => _instance;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      const options = WindowOptions(
        size: Size(1024, 768),
        minimumSize: Size(600, 400),
        center: true,
        // titleBarStyle: TitleBarStyle.hidden, // ← скрыть стандартный заголовок
        // windowButtonVisibility: false, // ← скрыть кнопки Windows
      );

      windowManager.waitUntilReadyToShow(options, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      windowManager.addListener(this);
    }

    // setCon.load();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  void toggleMaximize() {
    if (_isMaximized) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ThemeCubit(brightness)..init()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            theme: state.theme,
          );
        },
      ),
    );
  }
}
