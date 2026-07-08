import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_go_chat/app/app_new.dart';
import 'package:flutter_go_chat/core/services/database/db_service.dart';
import 'package:flutter_go_chat/app/theme/theme_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) await windowManager.ensureInitialized();
  
  DatabaseService().openDB("database.db");
  await ThemeController.instance.init();

    // if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) 

  runApp(AppShell());
}