import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

Offset _flightPath(double t, Size size) {
  final p = t % 1.0;
  final x = size.width * (-0.15 + 1.3 * p);
  final y = size.height * (0.52 - 0.22 * sin(p * pi)) +
      sin(t * 2 * pi * 3) * size.shortestSide * 0.02;
  return Offset(x, y);
}

class PhoenixFlight extends StatefulWidget {
  const PhoenixFlight({super.key});

  @override
  State<PhoenixFlight> createState() => _PhoenixFlightState();
}

class _PhoenixFlightState extends State<PhoenixFlight>
    with SingleTickerProviderStateMixin {
  static const List<String> _framePaths = [
    'assets/images/anim1.png',
    'assets/images/anim2.png',
    'assets/images/anim3.png',
    'assets/images/anim4.png'
  ];

  static const double _fps = 3.5;

  late final AnimationController _controller;
  final List<ui.Image?> _frames = List.filled(_framePaths.length, null);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    for (var i = 0; i < _framePaths.length; i++) {
      final data = await rootBundle.load(_framePaths[i]);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _frames[i] = frame.image);
    }
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
        final t = _controller.value;
        final frame = (t * 10 * _fps).floor() % _framePaths.length;
        return CustomPaint(
          painter: _ScenePainter(t, _frames, frame),
        );
      },
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.t, this.frames, this.frame);

  final double t;
  final List<ui.Image?> frames;
  final int frame;

  Path _teardrop(double len, double width) {
    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -width, len, 0)
      ..quadraticBezierTo(len * 0.5, width, 0, 0);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [NovaTheme.background, Color(0xFF2B0D04)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.78, size.height * 0.20);
    final pulse = 1.0 + 0.05 * sin(t * 2 * pi * 2);
    final r = size.shortestSide * 0.10 * pulse;

    final halo = Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          NovaTheme.gold.withValues(alpha: 0.5),
          NovaTheme.flame.withValues(alpha: 0.15),
          NovaTheme.flame.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 3.2));
    canvas.drawCircle(center, r * 3.2, halo);

    final rayPaint = Paint()
      ..blendMode = BlendMode.plus
      ..color = NovaTheme.gold.withValues(alpha: 0.12);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 2 * pi * 0.15);
    for (var i = 0; i < 8; i++) {
      canvas.rotate(pi / 4);
      canvas.drawPath(_teardrop(r * 2.8, r * 0.18), rayPaint);
    }
    canvas.restore();

    final disc = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFF6D8), NovaTheme.gold, NovaTheme.flame],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, disc);
  }

  void _drawTrail(Canvas canvas, Size size) {
    for (var i = 0; i < 28; i++) {
      final tt = t - i * 0.006;
      final pos = _flightPath(tt, size);
      if (pos.dx < -40 || pos.dx > size.width + 40) continue;
      final k = 1 - i / 28;
      final wobble = Offset(
        sin((t * 6 + i) * pi) * 4,
        cos((t * 5 + i * 0.7) * pi) * 4,
      );
      final paint = Paint()
        ..blendMode = BlendMode.plus
        ..color = Color.lerp(NovaTheme.gold, NovaTheme.ember, i / 28)!
            .withValues(alpha: 0.45 * k);
      canvas.drawCircle(pos + wobble, 1.5 + 5 * k, paint);
    }
  }

  void _drawPhoenix(Canvas canvas, Size size) {
  if (frames.isEmpty || frames.every((e) => e == null)) return;
  final pos = _flightPath(t, size);
  if (pos.dx < -80 || pos.dx > size.width + 80) return;
  final ahead = _flightPath(t + 0.005, size);
  final angle = (ahead - pos).direction;

  final n = frames.length;
  final raw = t * _PhoenixFlightState._fps;
  final i0 = raw.floor() % n;
  final i1 = (i0 + 1) % n;
  final mix = raw - raw.floor();
  final img0 = frames[i0];
  final img1 = frames[i1];
  if (img0 == null && img1 == null) return;

  final ref = img0 ?? img1!;
  final w = size.shortestSide * 0.62;
  final h = w * ref.height / ref.width;
  final src = Rect.fromLTWH(0, 0, ref.width.toDouble(), ref.height.toDouble());
  final dst = Rect.fromLTWH(-w / 2, -h / 2, w, h);

  canvas.save();
  canvas.translate(pos.dx, pos.dy);
  canvas.rotate(angle * 0.4);

  if (img0 != null) {
    canvas.drawImageRect(
      img0,
      src,
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..colorFilter = ColorFilter.mode(
          const Color(0xFFFFFFFF).withValues(alpha: 1 - mix),
          BlendMode.modulate,
        ),
    );
  }
  if (img1 != null && mix > 0.001) {
    canvas.drawImageRect(
      img1,
      Rect.fromLTWH(0, 0, img1.width.toDouble(), img1.height.toDouble()),
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..colorFilter = ColorFilter.mode(
          const Color(0xFFFFFFFF).withValues(alpha: mix),
          BlendMode.modulate,
        ),
    );
  }

  canvas.restore();
}

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawSun(canvas, size);
    _drawTrail(canvas, size);
    _drawPhoenix(canvas, size);
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => true;
}