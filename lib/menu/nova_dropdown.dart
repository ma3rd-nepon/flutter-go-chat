import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaDropdownButton extends StatefulWidget {
  const NovaDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 240,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  State<NovaDropdownButton> createState() => _NovaDropdownButtonState();
}

class _NovaDropdownButtonState extends State<NovaDropdownButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  int _hovered = -1;

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _open() {
    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            child: Container(color: const Color(0x00000000)),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 6),
            child: SizedBox(
              width: widget.width,
              child: Container(
                decoration: BoxDecoration(
                  color: NovaTheme.surface,
                  border: Border.all(color: NovaTheme.ink, width: 2),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.items.length; i++)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => _hovered = i),
                        onExit: (_) => setState(() => _hovered = -1),
                        child: GestureDetector(
                          onTap: () {
                            _close();
                            widget.onChanged(widget.items[i]);
                          },
                          child: Container(
                            color: _hovered == i
                                ? const Color(0xFF3A2A18)
                                : const Color(0x00000000),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                if (widget.items[i] == widget.value)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: _Mark(),
                                  ),
                                Text(
                                  widget.items[i],
                                  style: TextStyle(
                                    fontFamily: NovaTheme.monoFont,
                                    fontVariations: [FontVariation.weight(700)],
                                    fontSize: 12,
                                    letterSpacing: 1,
                                    color: widget.items[i] == widget.value
                                        ? NovaTheme.flame
                                        : NovaTheme.paper,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: SizedBox(
        width: widget.width,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _entry == null ? _open : _close,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: NovaTheme.surface,
                border: Border.all(color: NovaTheme.ink, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value,
                      style: TextStyle(
                        fontFamily: NovaTheme.bodyFont,
                        fontVariations: [FontVariation.weight(700)],
                        fontSize: 14,
                        color: NovaTheme.paper,
                      ),
                    ),
                  ),
                  const _Arrow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, color: NovaTheme.flame);
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 8,
      child: CustomPaint(painter: _ArrowPainter()),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = NovaTheme.gold);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}