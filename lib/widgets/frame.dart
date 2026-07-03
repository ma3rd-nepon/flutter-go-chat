import 'package:flutter/material.dart';
import 'package:flutter_go_chat/services/page_manager.dart';
import 'package:flutter_go_chat/widgets/app_tabs_bar.dart';
import 'package:flutter_go_chat/widgets/window.dart';

class WindowFrame extends StatefulWidget {
  final PageManager _navManager;

  const WindowFrame({super.key, required this._navManager});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> {
  @override
  void initState() {
    super.initState();
    widget._navManager.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        const MyAppBar(),
        Expanded(
          child: Row(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Expanded(
                flex: 1,
                child: AppRailBar(navManager: widget._navManager),
              ),
              Expanded(
                flex: 3,
                child: IndexedStack(
                  index: widget._navManager.currentIndex,
                  children: widget._navManager.pages
                      .map((e) => e.page)
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
