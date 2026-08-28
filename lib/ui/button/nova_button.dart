import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';
import 'button_size.dart';
import 'button_type.dart';
import 'button_variant.dart';

class NovaButton extends StatefulWidget {
  const NovaButton({
    super.key,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.type = ButtonType.elevated,
    this.size = ButtonSize.large,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.child,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Function(bool)? onHover;
  final ButtonVariant variant;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Widget? child;

  @override
  State<NovaButton> createState() => _NovaButtonState();
}

class _NovaButtonState extends State<NovaButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool get _disabled => widget.onPressed == null;

  bool get _isGhost =>
      widget.variant == ButtonVariant.ghost || widget.type == ButtonType.text;

  bool get _isOutlined => widget.type == ButtonType.outlined;

  Color _accent(ThemePalette colors) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return colors.primary;
      case ButtonVariant.secondary:
        return colors.primaryHover;
      case ButtonVariant.danger:
        return colors.error;
      case ButtonVariant.ghost:
        return colors.textPrimary;
    }
  }

  List<Color> _gradientColors(double breathe, ThemePalette colors) {
    final k = breathe * 0.5;
    switch (widget.variant) {
      case ButtonVariant.primary:
        return [
          Color.lerp(const Color(0xFFFF8A3D), const Color(0xFFFFA45C), k)!,
          Color.lerp(colors.primary, const Color(0xFFFF7A1F), k)!,
        ];
      case ButtonVariant.secondary:
        return [
          Color.lerp(const Color(0xFFFFD34D), const Color(0xFFFFE080), k)!,
          Color.lerp(colors.primaryHover, const Color(0xFFFFC22E), k)!,
        ];
      case ButtonVariant.danger:
        return [
          Color.lerp(const Color(0xFFFF6B5E), const Color(0xFFFF8579), k)!,
          Color.lerp(colors.error, const Color(0xFFFF5147), k)!,
        ];
      case ButtonVariant.ghost:
        return const [Color(0x00000000), Color(0x00000000)];
    }
  }

  Color _textColor(ThemePalette colors) {
    if (_disabled) return colors.textDisabled;
    if (_isGhost) return colors.textPrimary;
    if (_isOutlined) return _accent(colors);
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return colors.border;
      case ButtonVariant.danger:
      case ButtonVariant.ghost:
        return colors.textPrimary;
    }
  }

  EdgeInsets _padding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 13.0;
      case ButtonSize.medium:
        return 15.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  Widget _loader(ThemePalette colors) {
    return SizedBox(
      width: 18,
      height: 18,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 100.0),
        duration: const Duration(seconds: 100),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 6.28318530718,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _textColor(colors), width: 3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = !_disabled && !_isGhost && !_isOutlined;
    return Opacity(
      opacity: _disabled ? 0.6 : 1.0,
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (context, child) {
          final breathe = (sin(_ticker.value * 2 * pi) + 1) / 2;
          return AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              padding: _padding(),
              decoration: BoxDecoration(
                gradient: filled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradientColors(breathe, colors),
                      )
                    : null,
                color: _disabled
                    ? colors.surface
                    : _isGhost
                        ? (_hovered ? const Color(0x1AFFF6EC) : const Color(0x00000000))
                        : _isOutlined
                            ? (_hovered
                                ? _accent(colors).withValues(alpha: 0.12)
                                : const Color(0x00000000))
                            : null,
                borderRadius: BorderRadius.circular(12),
                border: filled
                    ? Border.all(
                        color: colors.border.withValues(alpha: 0.35),
                        width: 1.5,
                      )
                    : _isGhost
                        ? Border.all(color: const Color(0x99FFF6EC), width: 2)
                        : Border.all(color: _accent(colors), width: 2),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: _accent(colors)
                              .withValues(alpha: _hovered ? 0.5 : 0.28 + breathe * 0.08),
                          blurRadius: _hovered ? 20 : 12,
                          offset: Offset(0, _hovered ? 6 : 4),
                        ),
                      ]
                    : const [],
              ),
              child: MouseRegion(
                cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
                onEnter: (_) {
                  if (_disabled) return;
                  setState(() => _hovered = true);
                  widget.onHover?.call(true);
                },
                onExit: (_) {
                  setState(() => _hovered = false);
                  widget.onHover?.call(false);
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    if (_disabled || widget.isLoading) return;
                    setState(() => _pressed = true);
                  },
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTap: _disabled || widget.isLoading ? null : widget.onPressed,
                  onLongPress: _disabled || widget.isLoading ? null : widget.onLongPress,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (filled)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GlossPainter(t: _ticker.value, hovered: _hovered),
                          ),
                        ),
                      Opacity(
                        opacity: widget.isLoading ? 0.0 : 1.0,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontVariations: [FontVariation.weight(800)],
                            letterSpacing: 1.2,
                            color: _textColor(colors),
                            fontSize: _fontSize(),
                          ),
                          child: widget.child ?? const SizedBox.shrink(),
                        ),
                      ),
                      if (widget.isLoading) _loader(colors),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlossPainter extends CustomPainter {
  _GlossPainter({required this.t, required this.hovered});

  final double t;
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(12),
      ),
    );

    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.22),
          const Color(0x00FFFFFF),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gloss);

    final x = -0.4 + t * 1.8;
    final w = size.width;
    final band = Path()
      ..moveTo(w * x, 0)
      ..lineTo(w * (x + 0.15), 0)
      ..lineTo(w * (x - 0.1), size.height)
      ..lineTo(w * (x - 0.25), size.height)
      ..close();
    canvas.drawPath(
      band,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = const Color(0xFFFFFFFF).withValues(alpha: hovered ? 0.20 : 0.10),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlossPainter oldDelegate) => true;
}