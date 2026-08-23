import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaDrawer extends StatelessWidget {
  const NovaDrawer({
    super.key,
    required this.open,
    required this.onClose,
    required this.child,
    this.width = 280,
  });

  final bool open;
  final VoidCallback onClose;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (open)
          GestureDetector(
            onTap: onClose,
            child: Container(color: const Color(0x99120B04)),
          ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: width,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            offset: open ? Offset.zero : const Offset(-1.2, 0),
            child: Container(
              color: NovaTheme.surface,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}