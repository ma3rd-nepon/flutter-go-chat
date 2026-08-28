import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaChip extends StatefulWidget {
  const NovaChip({
    super.key,
    required this.label,
    this.leading,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.selectedColor,
  });

  final Widget label;
  final Widget? leading;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? selectedColor;

  @override
  State<NovaChip> createState() => _NovaChipState();
}

class _NovaChipState extends State<NovaChip> {
  bool _hovered = false;
  bool _deleteHovered = false;

  bool get _disabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    final fill = widget.selected
        ? (widget.selectedColor ?? colors.primary)
        : colors.surface;
    final textColor = widget.selected ? colors.border : colors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border, width: AppConst.borderWidthL),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000),
                offset: _hovered && !_disabled ? const Offset(3, 3) : const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 6),
              ],
              DefaultTextStyle(
                style: TextStyle(
                  fontFamily: AppFonts.bodyFont,
                  fontVariations: [FontVariation.weight(700)],
                  fontSize: 13,
                  color: textColor,
                ),
                child: widget.label,
              ),
              if (widget.onDeleted != null) ...[
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _deleteHovered = true),
                  onExit: (_) => setState(() => _deleteHovered = false),
                  child: GestureDetector(
                    onTap: widget.onDeleted,
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CustomPaint(
                        painter: _CrossPainter(
                          color: _deleteHovered ? colors.error : textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  _CrossPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter oldDelegate) => oldDelegate.color != color;
}