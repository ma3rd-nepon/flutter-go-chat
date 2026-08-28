import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaCircularProgress extends StatefulWidget {
  const NovaCircularProgress({
    super.key,
    this.value,
    this.size = 48,
    this.strokeWidth = 6,
  });

  final double? value;
  final double size;
  final double strokeWidth;

  @override
  State<NovaCircularProgress> createState() => _NovaCircularProgressState();
}

class _NovaCircularProgressState extends State<NovaCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RingPainter(
              value: widget.value,
              t: _controller.value,
              strokeWidth: widget.strokeWidth,
              colors: context.colors
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.t, required this.strokeWidth, required this.colors});

  final double? value;
  final double t;
  final double strokeWidth;
  final ThemePalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final center = Offset(size.width / 2, size.height / 2);
    final r = rect.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFF3A2A18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final sweep = value == null ? pi * 0.7 : value! * 2 * pi;
    final start = value == null ? t * 2 * pi : -pi / 2;

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square
        ..shader = SweepGradient(
          colors: [colors.primary, colors.primaryHover, colors.primary],
        ).createShader(rect),
    );

    final endAngle = start + sweep;
    final knobPos = center + Offset(cos(endAngle) * r, sin(endAngle) * r);
    canvas.save();
    canvas.translate(knobPos.dx, knobPos.dy);
    canvas.rotate(pi / 4);
    canvas.drawRect(
      const Rect.fromLTWH(-4, -4, 8, 8),
      Paint()..color = colors.primaryHover,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-4, -4, 8, 8),
      Paint()
        ..color = colors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => true;
}