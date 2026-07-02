import 'package:flutter/material.dart';
import 'package:go_dart_e2e/theme/app_theme.dart';
import 'package:go_dart_e2e/widgets/buttons.dart';
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
              CustomIconButton(icon: Icon(Icons.notifications), onPress: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  final WindowManager _windowManager;
  final VoidCallback maximize;

  const HeaderBar({
    super.key,
    required this._windowManager,
    required this.maximize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => _windowManager.startDragging(),
      child: Container(
        height: 30,
        color: AppColors.background,
        child: Row(
          mainAxisAlignment: .end,
          crossAxisAlignment: .center,
          children: [
            CustomIconButton(
              icon: Icon(Icons.horizontal_rule),
              onPress: () async {
                await _windowManager.minimize();
              },
            ),
            CustomIconButton(
              icon: Icon(Icons.crop_square),
              onPress: () async {
                maximize();
              },
            ),
            CustomIconButton(
              icon: Icon(Icons.close),
              onPress: () async {
                await _windowManager.close();
              },
            ),
          ],
        ),
      ),
    );
  }
}
