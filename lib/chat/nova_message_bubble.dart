import 'package:flutter/widgets.dart';

import '../models/chat_models.dart';
import '../theme/nova_cut_box.dart';
import '../theme/nova_theme.dart';

class NovaMessageBubble extends StatelessWidget {
  const NovaMessageBubble({super.key, required this.message});

  final NovaMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: NovaCutBox(
          color: message.me ? NovaTheme.flame : NovaTheme.surface,
          cut: 10,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shadow: const Offset(3, 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                message.me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontFamily: NovaTheme.bodyFont,
                  fontVariations: [FontVariation.weight(600)],
                  fontSize: 14,
                  color: message.me ? NovaTheme.ink : NovaTheme.paper,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: TextStyle(
                      fontFamily: NovaTheme.monoFont,
                      fontSize: 9,
                      color: message.me
                          ? NovaTheme.ink.withValues(alpha: 0.7)
                          : NovaTheme.muted,
                    ),
                  ),
                  if (message.me) ...[
                    const SizedBox(width: 6),
                    const _Checks(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checks extends StatelessWidget {
  const _Checks();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 8,
      child: CustomPaint(painter: _ChecksPainter()),
    );
  }
}

class _ChecksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NovaTheme.ink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < 2; i++) {
      final dx = i * size.width * 0.35;
      final path = Path()
        ..moveTo(dx, size.height * 0.5)
        ..lineTo(dx + size.width * 0.2, size.height * 0.85)
        ..lineTo(dx + size.width * 0.45, size.height * 0.15);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ChecksPainter oldDelegate) => false;
}