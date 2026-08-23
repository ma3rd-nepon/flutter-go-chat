import 'dart:math';

import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaFlameBar extends StatefulWidget {
  const NovaFlameBar({super.key, this.width = 6});

  final double width;

  @override
  State<NovaFlameBar> createState() => _NovaFlameBarState();
}

class _NovaFlameBarState extends State<NovaFlameBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
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
          width: widget.width,
          child: CustomPaint(painter: _FlamePainter(_controller.value)),
        );
      },
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          NovaTheme.flame.withValues(alpha: 0.35),
          NovaTheme.flame.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.height * 0.6,
        ),
      );
    canvas.drawRect(
      Rect.fromLTRB(-size.width, 0, size.width * 2, size.height),
      glow,
    );

    final steps = (size.height / 3).ceil();
    for (var i = 0; i <= steps; i++) {
      final y = size.height - (i / steps) * size.height;
      final wave = sin(i * 0.55 + t * 2 * pi * 2) * 0.5 +
          sin(i * 0.23 - t * 2 * pi * 3) * 0.5;
      final k = (wave + 1) / 2;
      final w = size.width * (0.55 + 0.45 * k);
      final color = Color.lerp(NovaTheme.ember, NovaTheme.gold, k)!;
      canvas.drawRect(
        Rect.fromLTWH((size.width - w) / 2, y - 2, w, 4),
        Paint()..color = color,
      );
    }

    for (var s = 0; s < 3; s++) {
      final p = (t * (0.7 + s * 0.23) + s * 0.37) % 1.0;
      final y = size.height * (1 - p);
      final x = size.width / 2 + sin((p * 3 + s) * pi) * size.width * 0.6;
      canvas.drawCircle(
        Offset(x, y),
        1.2 + (1 - p),
        Paint()
          ..blendMode = BlendMode.plus
          ..color = NovaTheme.gold.withValues(alpha: (1 - p) * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) => oldDelegate.t != t;
}