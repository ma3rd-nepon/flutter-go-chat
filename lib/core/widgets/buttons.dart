import "package:flutter/material.dart";
import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class WindowsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const WindowsButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    return InkWell(
      hoverColor: colors.surfaceHover,
      onTap: onTap,
      child: Container(
        width: 46,
        height: 32,
        color: colors.surfaceTransparent,
        child: Icon(icon, size: 32, color: colors.iconPrimary),
      ),
    );
  }
}

class LogoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;

  const LogoButton({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: Theme.of(context).elevatedButtonTheme.style,
      child: Text(text)
    );
  }
}

class NavBarToggler extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isActive;

  const NavBarToggler({super.key, required this.onPressed, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 40,
        height: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(40, 20),
              painter: _TrapezoidPainter(
                fillColor: colors.primary,
                strokeColor: colors.border,
                strokeWidth: 1.0,
              ),
            ),

            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: isActive ? 0.5 : 0.0,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrapezoidPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  _TrapezoidPainter({required this.fillColor, required this.strokeColor, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(8, 0)
      ..lineTo(size.width - 8, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _TrapezoidPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}