import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';
import 'nova_chip.dart';

class NovaFilterChip extends StatelessWidget {
  const NovaFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onChanged,
    this.leading,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return NovaChip(
      label: Text(label),
      leading: selected ? const _SelectedMark() : leading,
      selected: selected,
      onPressed: onChanged == null ? null : () => onChanged!(!selected),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NovaTheme.ink
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.85, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}