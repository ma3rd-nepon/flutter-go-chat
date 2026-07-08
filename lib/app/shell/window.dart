import 'package:flutter/material.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';
import 'package:flutter_go_chat/core/icons/app_icons.dart';
import 'package:flutter_go_chat/core/widgets/buttons.dart';
import 'package:window_manager/window_manager.dart';

class MyAppBar extends StatelessWidget {
  final bool _needSearch;
  final String name =
      "supernova*"; // тут можно и текстом и иконкой, сам смотри че выберешь

  const MyAppBar({super.key, this._needSearch = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Color.fromARGB(100, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: .center,
        children: [
          LogoButton(text: name, onPress: () {}),
          _needSearch
              ? const SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(hintText: "Search smth..."),
                  ),
                )
              : SizedBox(width: 100),
          Row(
            children: [
              IconButton(icon: Icon(AppIcons.notifications), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class WindowControls extends StatefulWidget {
  final VoidCallback maximize;

  const WindowControls({
    super.key,
    required this.maximize,
  });

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 30,
        color: colors.background,
        child: Row(
          mainAxisAlignment: .end,
          crossAxisAlignment: .center,
          children: [
            IconButton(
              icon: Icon(AppIcons.minimize),
              onPressed: () async {
                await windowManager.minimize();
              },
            ),
            IconButton(
              icon: Icon(AppIcons.maximize),
              onPressed: () async {
                widget.maximize();
              },
            ),
            IconButton(
              icon: Icon(AppIcons.close),
              onPressed: () async {
                await windowManager.close();
              },
            ),
          ],
        ),
      ),
    );
  }
}
