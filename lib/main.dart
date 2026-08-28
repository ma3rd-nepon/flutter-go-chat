import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_shell.dart';
// import 'core/theme/theme_controller.dart';
import 'core/utils/polling/http.dart';
import 'core/di/service_locator.dart';
// import 'package:flutter_go_chat/core/services/database/db_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) await windowManager.ensureInitialized();
  
  // DatabaseService().openDB("database.db");

  await setupLocator();
  final http = ApiService();

  await http.init();
  
  // await ThemeController.instance.init();

    // if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) 

  runApp(AppShell());
}