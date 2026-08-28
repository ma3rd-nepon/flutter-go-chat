import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaBottomSheet {
  static OverlayEntry show(BuildContext context, {required WidgetBuilder builder}) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SheetHost(
        builder: builder,
        onClose: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }
}

class _SheetHost extends StatefulWidget {
  const _SheetHost({required this.builder, required this.onClose});

  final WidgetBuilder builder;
  final VoidCallback onClose;

  @override
  State<_SheetHost> createState() => _SheetHostState();
}

class _SheetHostState extends State<_SheetHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _controller.value * 0.6,
              child: GestureDetector(
                onTap: _close,
                child: Container(color: const Color(0xFF120B04)),
              ),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  color: colors.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 60, height: 4, color: colors.primary),
                      const SizedBox(height: 16),
                      Builder(builder: widget.builder),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}