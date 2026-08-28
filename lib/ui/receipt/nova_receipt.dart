import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

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
    final colors = context.colors;

    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _ReceiptPaper(colors),
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
  _ReceiptPaper(this.colors);

  final ThemePalette colors;

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
    canvas.drawPath(path, Paint()..color = colors.textPrimary);
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.border
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
    final colors = context.colors;

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
                    fontFamily: AppFonts.monoFont,
                    fontVariations: [FontVariation.weight(700)],
                    fontSize: 14,
                    color: colors.border,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 2,
                    child: CustomPaint(painter: _Dots(colors)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: AppFonts.monoFont,
                    fontSize: 12,
                    color: colors.textHint,
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
                      fontFamily: AppFonts.monoFont,
                      fontSize: 12,
                      color: colors.textHint,
                    ),
                  ),
                ),
                if (unread > 0)
                  Text(
                    '✱$unread',
                    style: TextStyle(
                      fontFamily: AppFonts.monoFont,
                      fontVariations: [FontVariation.weight(800)],
                      fontSize: 13,
                      color: colors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 2,
              child: CustomPaint(painter: _Dots(colors)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends CustomPainter {
  _Dots(this.colors);
  final ThemePalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.textHint.withValues(alpha: 0.5)
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
      child: CustomPaint(painter: _Barcode(context.colors)),
    );
  }
}

class _Barcode extends CustomPainter {
  _Barcode(this.colors);

  final ThemePalette colors;

  static const List<double> _widths = [
    3.0, 1.5, 2.0, 4.0, 1.5, 3.0, 2.0, 1.5, 4.0, 2.0,
    3.0, 1.5, 2.0, 3.0, 1.5, 4.0, 2.0, 1.5, 3.0, 2.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colors.border;
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