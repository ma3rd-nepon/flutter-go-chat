import 'dart:math';
import 'package:flutter/widgets.dart';

class NovaIconMenu extends StatelessWidget {
  const NovaIconMenu({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MenuPainter(color)),
    );
  }
}

class _MenuPainter extends CustomPainter {
  _MenuPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MenuPainter oldDelegate) => oldDelegate.color != color;
}

class NovaIconChat extends StatelessWidget {
  const NovaIconChat({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChatPainter(color)),
    );
  }
}

class _ChatPainter extends CustomPainter {
  _ChatPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.08, h * 0.15)
      ..lineTo(w * 0.92, h * 0.15)
      ..lineTo(w * 0.92, h * 0.65)
      ..lineTo(w * 0.4, h * 0.65)
      ..lineTo(w * 0.22, h * 0.88)
      ..lineTo(w * 0.22, h * 0.65)
      ..lineTo(w * 0.08, h * 0.65)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChatPainter oldDelegate) => oldDelegate.color != color;
}

class NovaIconFlame extends StatelessWidget {
  const NovaIconFlame({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FlamePainter(color)),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..cubicTo(w * 0.72, h * 0.3, w * 0.86, h * 0.45, w * 0.86, h * 0.62)
      ..cubicTo(w * 0.86, h * 0.85, w * 0.68, h * 0.95, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.32, h * 0.95, w * 0.14, h * 0.85, w * 0.14, h * 0.62)
      ..cubicTo(w * 0.14, h * 0.45, w * 0.28, h * 0.3, w * 0.5, h * 0.06)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) => oldDelegate.color != color;
}

class NovaIconUser extends StatelessWidget {
  const NovaIconUser({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _UserPainter(color)),
    );
  }
}

class _UserPainter extends CustomPainter {
  _UserPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.32),
      size.width * 0.18,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.55,
        size.width * 0.64,
        size.height * 0.6,
      ),
      3.6,
      2.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_UserPainter oldDelegate) => oldDelegate.color != color;
}

class NovaIconGear extends StatelessWidget {
  const NovaIconGear({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GearPainter(color)),
    );
  }
}

class _GearPainter extends CustomPainter {
  _GearPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c, size.width * 0.26, paint);
    for (var i = 0; i < 8; i++) {
      final a = i * 0.7853981634;
      canvas.drawLine(
        c + Offset(cos(a) * size.width * 0.32, sin(a) * size.width * 0.32),
        c + Offset(cos(a) * size.width * 0.45, sin(a) * size.width * 0.45),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GearPainter oldDelegate) => oldDelegate.color != color;
}
class NovaIconBack extends StatelessWidget {
  const NovaIconBack({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BackPainter(color)),
    );
  }
}

class _BackPainter extends CustomPainter {
  _BackPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.15, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.22),
      Offset(size.width * 0.15, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) => oldDelegate.color != color;
}

class NovaIconSend extends StatelessWidget {
  const NovaIconSend({super.key, this.color = const Color(0xFFFFFFFF), this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SendPainter(color)),
    );
  }
}

class _SendPainter extends CustomPainter {
  _SendPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.45)
      ..lineTo(size.width * 0.95, size.height * 0.1)
      ..lineTo(size.width * 0.55, size.height * 0.9)
      ..lineTo(size.width * 0.45, size.height * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SendPainter oldDelegate) => oldDelegate.color != color;
}
