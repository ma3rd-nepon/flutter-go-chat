import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaFloatingActionButton extends StatefulWidget {
  const NovaFloatingActionButton({super.key, required this.onPressed, this.child});

  final VoidCallback onPressed;
  final Widget? child;

  @override
  State<NovaFloatingActionButton> createState() => _NovaFloatingActionButtonState();
}

class _NovaFloatingActionButtonState extends State<NovaFloatingActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : (_hovered ? 1.06 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -pi / 4,
                  child: widget.child ??
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomPaint(painter: _PlusPainter(colors)),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter(this.colors);

  final ThemePalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.border
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PlusPainter oldDelegate) => false;
}