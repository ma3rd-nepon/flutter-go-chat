import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_go_chat/theme/app_theme.dart';
import 'package:flutter_go_chat/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1024, 768),
    minimumSize: Size(600, 400),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,    // ← скрыть стандартный заголовок
    windowButtonVisibility: false,           // ← скрыть кнопки Windows
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp(windowManager: windowManager));
}

class MyApp extends StatelessWidget {
  final WindowManager windowManager;
  const MyApp({super.key, required this.windowManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'supernova',
      theme: ThemeList.orange.theme,
      home: AppShell(),
    );
  }
}
