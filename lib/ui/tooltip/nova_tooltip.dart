import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaTooltip extends StatefulWidget {
  const NovaTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<NovaTooltip> createState() => _NovaTooltipState();
}

class _NovaTooltipState extends State<NovaTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _show() {
    final colors = context.colors;

    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              border: Border.all(color: colors.border, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF000000),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                fontFamily: AppFonts.monoFont,
                fontVariations: [FontVariation.weight(700)],
                fontSize: 12,
                color: colors.border,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: (_) => _show(),
      onExit: (_) => _hide(),
      child: CompositedTransformTarget(
        link: _link,
        child: widget.child,
      ),
    );
  }
}