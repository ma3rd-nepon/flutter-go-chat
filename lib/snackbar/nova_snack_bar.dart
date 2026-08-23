import 'dart:async';

import 'package:flutter/widgets.dart';

import '../chat/nova_flame_bar.dart';
import '../theme/nova_cut_box.dart';
import '../theme/nova_theme.dart';

class NovaSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SnackBarHost(
        message: message,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _SnackBarHost extends StatefulWidget {
  const _SnackBarHost({
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_SnackBarHost> createState() => _SnackBarHostState();
}

class _SnackBarHostState extends State<_SnackBarHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
    _timer = Timer(widget.duration, _close);
  }

  void _close() {
    _timer?.cancel();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final curve = Curves.easeOut.transform(_controller.value);
          return Opacity(
            opacity: curve,
            child: Transform.translate(
              offset: Offset(0, (1 - curve) * 60),
              child: child,
            ),
          );
        },
        child: Center(
          child: NovaCutBox(
            color: NovaTheme.paper,
            cut: 10,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 26,
                  child: NovaFlameBar(width: 6),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.message,
                  style: TextStyle(
                    fontFamily: NovaTheme.bodyFont,
                    fontVariations: [FontVariation.weight(700)],
                    fontSize: 14,
                    color: NovaTheme.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}