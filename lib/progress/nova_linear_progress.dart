import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaLinearProgress extends StatefulWidget {
  const NovaLinearProgress({super.key, this.value, this.height = 12});

  final double? value;
  final double height;

  @override
  State<NovaLinearProgress> createState() => _NovaLinearProgressState();
}

class _NovaLinearProgressState extends State<NovaLinearProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: NovaTheme.surface,
        border: Border.all(color: NovaTheme.ink, width: NovaTheme.borderWidth),
      ),
      child: widget.value == null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(painter: _StripesPainter(_controller.value));
              },
            )
          : FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.value!.clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [NovaTheme.flame, NovaTheme.gold],
                  ),
                ),
              ),
            ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  _StripesPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final shift = t * 14;
    var i = 0;
    for (var x = -size.height - 14 + shift; x < size.width; x += 14) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height * 0.6, 0)
        ..lineTo(x + size.height * 0.6 + 7, 0)
        ..lineTo(x + 7, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = i.isEven ? NovaTheme.flame : NovaTheme.gold,
      );
      i++;
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => oldDelegate.t != t;
}