import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaCheckbox extends StatelessWidget {
  const NovaCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  bool get _disabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _disabled ? null : () => onChanged!(!value),
        child: Opacity(
          opacity: _disabled ? 0.5 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: value ? colors.primaryHover : colors.surface,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: colors.border, width: AppConst.borderWidthL),
              boxShadow: const [
                BoxShadow(color: Color(0xFF000000), offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: AnimatedOpacity(
              opacity: value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 120),
              child: CustomPaint(painter: _CheckPainter(colors)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.colors);

  final ThemePalette colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.border
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => false;
}