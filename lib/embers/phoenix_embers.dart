import 'dart:math';

import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class PhoenixEmbers extends StatefulWidget {
  const PhoenixEmbers({super.key, this.count = 16});

  final int count;

  @override
  State<PhoenixEmbers> createState() => _PhoenixEmbersState();
}

class _PhoenixEmbersState extends State<PhoenixEmbers>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Ember> _embers;

  @override
  void initState() {
    super.initState();
    final random = Random(2026);
    _embers = List.generate(widget.count, (_) => _Ember(random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
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
        return CustomPaint(
          painter: _EmbersPainter(_embers, _controller.value),
        );
      },
    );
  }
}

class _Ember {
  _Ember(Random random)
      : x = random.nextDouble(),
        speed = 0.6 + random.nextDouble() * 0.8,
        phase = random.nextDouble(),
        size = 1.5 + random.nextDouble() * 2.5,
        wobble = 10 + random.nextDouble() * 30;

  final double x;
  final double speed;
  final double phase;
  final double size;
  final double wobble;
}

class _EmbersPainter extends CustomPainter {
  _EmbersPainter(this.embers, this.t);

  final List<_Ember> embers;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ember in embers) {
      final progress = (t * ember.speed + ember.phase) % 1.0;
      final x = size.width * ember.x +
          sin((progress * 2 + ember.phase * 4) * pi) * ember.wobble;
      final y = size.height * (1.05 - progress * 1.1);
      final alpha = sin(progress * pi) * 0.8;
      final color = Color.lerp(NovaTheme.flame, NovaTheme.gold, ember.phase)!
          .withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), ember.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_EmbersPainter oldDelegate) => true;
}