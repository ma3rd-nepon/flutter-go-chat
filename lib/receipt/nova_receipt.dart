import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaReceipt extends StatelessWidget {
  const NovaReceipt({
    super.key,
    required this.children,
    this.width = 360,
    this.header,
    this.footer,
  });

  final List<Widget> children;
  final double width;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _ReceiptPaper(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?header,
              const SizedBox(height: 10),
              ...children,
              if (footer != null) ...[
                const SizedBox(height: 14),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptPaper extends CustomPainter {
  static const double _tooth = 12;
  static const double _zig = 7;

  Path _path(Size s) {
    final p = Path()..moveTo(0, _zig);
    var up = false;
    for (var x = 0.0; x < s.width; x += _tooth) {
      p.lineTo((x + _tooth).clamp(0.0, s.width), up ? _zig : 0);
      up = !up;
    }
    p.lineTo(s.width, s.height - _zig);
    up = false;
    for (var x = s.width; x > 0; x -= _tooth) {
      p.lineTo((x - _tooth).clamp(0.0, s.width), up ? s.height - _zig : s.height);
      up = !up;
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    canvas.save();
    canvas.translate(5, 5);
    canvas.drawPath(path, Paint()..color = const Color(0xFF000000));
    canvas.restore();
    canvas.drawPath(path, Paint()..color = NovaTheme.paper);
    canvas.drawPath(
      path,
      Paint()
        ..color = NovaTheme.ink
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ReceiptPaper oldDelegate) => false;
}

class NovaReceiptRow extends StatelessWidget {
  const NovaReceiptRow({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
    this.onTap,
  });

  final String name;
  final String message;
  final String time;
  final int unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: NovaTheme.monoFont,
                    fontVariations: [FontVariation.weight(700)],
                    fontSize: 14,
                    color: NovaTheme.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 2,
                    child: CustomPaint(painter: _Dots()),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: NovaTheme.monoFont,
                    fontSize: 12,
                    color: NovaTheme.receiptMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: NovaTheme.monoFont,
                      fontSize: 12,
                      color: NovaTheme.receiptMuted,
                    ),
                  ),
                ),
                if (unread > 0)
                  Text(
                    '✱$unread',
                    style: TextStyle(
                      fontFamily: NovaTheme.monoFont,
                      fontVariations: [FontVariation.weight(800)],
                      fontSize: 13,
                      color: NovaTheme.flame,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 2,
              child: CustomPaint(painter: _Dots()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NovaTheme.receiptMuted.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 4, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Dots oldDelegate) => false;
}

class NovaBarcode extends StatelessWidget {
  const NovaBarcode({super.key, this.height = 34});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _Barcode()),
    );
  }
}

class _Barcode extends CustomPainter {
  static const List<double> _widths = [
    3.0, 1.5, 2.0, 4.0, 1.5, 3.0, 2.0, 1.5, 4.0, 2.0,
    3.0, 1.5, 2.0, 3.0, 1.5, 4.0, 2.0, 1.5, 3.0, 2.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = NovaTheme.ink;
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final w = _widths[i % _widths.length];
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      x += w + 3;
      i++;
    }
  }

  @override
  bool shouldRepaint(_Barcode oldDelegate) => false;
}