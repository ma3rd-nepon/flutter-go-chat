import 'package:flutter/material.dart';
import 'package:flutter_go_chat/theme/app_theme.dart';
import 'package:flutter_go_chat/widgets/buttons.dart';
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
              IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class WindowControls extends StatelessWidget {
  final VoidCallback maximize;

  const WindowControls({
    super.key,
    required this.maximize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 30,
        color: AppColors.background,
        child: Row(
          mainAxisAlignment: .end,
          crossAxisAlignment: .center,
          children: [
            IconButton(
              icon: Icon(Icons.horizontal_rule),
              onPressed: () async {
                await windowManager.minimize();
              },
            ),
            IconButton(
              icon: Icon(Icons.crop_square),
              onPressed: () async {
                maximize();
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
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
