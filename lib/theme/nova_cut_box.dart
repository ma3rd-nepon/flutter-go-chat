import 'package:flutter/widgets.dart';

import 'nova_theme.dart';

class NovaCutBox extends StatelessWidget {
  const NovaCutBox({
    super.key,
    required this.child,
    this.color = NovaTheme.surface,
    this.borderColor = NovaTheme.ink,
    this.cut = NovaTheme.cut,
    this.shadow = const Offset(4, 4),
    this.padding,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final double cut;
  final Offset shadow;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CutPainter(color, borderColor, cut, shadow),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

class _CutPainter extends CustomPainter {
  _CutPainter(this.color, this.borderColor, this.cut, this.shadow);

  final Color color;
  final Color borderColor;
  final double cut;
  final Offset shadow;

  Path _path(Size s) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(s.width - cut, 0)
      ..lineTo(s.width, cut)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.save();
    canvas.translate(shadow.dx, shadow.dy);
    canvas.drawPath(path, Paint()..color = const Color(0xFF000000));
    canvas.restore();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..strokeWidth = NovaTheme.borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_CutPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.shadow != shadow;
}