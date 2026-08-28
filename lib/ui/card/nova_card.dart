import 'package:flutter/widgets.dart';

import '../theme/nova_cut_box.dart';

class NovaCard extends StatefulWidget {
  const NovaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.width,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? width;

  @override
  State<NovaCard> createState() => _NovaCardState();
}

class _NovaCardState extends State<NovaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap == null) return;
        setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: _hovered ? const Offset(-2, -2) : Offset.zero,
          child: SizedBox(
            width: widget.width,
            child: NovaCutBox(
              cut: 16,
              padding: widget.padding,
              shadow: _hovered ? const Offset(7, 7) : const Offset(5, 5),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}