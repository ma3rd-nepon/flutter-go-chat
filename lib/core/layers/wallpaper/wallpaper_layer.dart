import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/layers/wallpaper/wallaper_type.dart';
import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class WallpaperLayer extends StatefulWidget {
  const WallpaperLayer({super.key});

  @override
  State<WallpaperLayer> createState() => _WallpaperLayerState();
}

class _WallpaperLayerState extends State<WallpaperLayer> {
  late WallpaperType wallpaperType;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;
    final g = AppScope.of(context);
    wallpaperType = g.settingsController.wallpaperType;

    switch (wallpaperType) {
      case WallpaperType.color:
        return Container(color: colors.background);
      case WallpaperType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.background, colors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case WallpaperType.asset:
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/rabbit.png'),
              fit: BoxFit.cover,
            ),
          ),
        );
      case WallpaperType.url:
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://i.imgur.com/02F3ghL.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        );
    }
  }
}