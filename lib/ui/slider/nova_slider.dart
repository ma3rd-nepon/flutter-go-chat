import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaSlider extends StatelessWidget {
  const NovaSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 30,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double height;

  bool get _disabled => onChanged == null;

  void _update(BoxConstraints constraints, double dx) {
    final usable = constraints.maxWidth - 24;
    if (usable <= 0) return;
    onChanged!(((dx - 12) / usable).clamp(0.0, 1.0).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Opacity(
      opacity: _disabled ? 0.5 : 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usable = constraints.maxWidth - 24;
          final thumbCenter = 12 + usable * value.clamp(0.0, 1.0).toDouble();
          return SizedBox(
            height: height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _disabled ? null : (d) => _update(constraints, d.localPosition.dx),
              onHorizontalDragUpdate:
                  _disabled ? null : (d) => _update(constraints, d.localPosition.dx),
              child: MouseRegion(
                cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: height / 2 - 6,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: colors.border,
                            width: AppConst.borderWidthL,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 3,
                      width: (thumbCenter - 4).clamp(0.0, usable + 24),
                      top: height / 2 - 3,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    Positioned(
                      left: thumbCenter - 12,
                      top: height / 2 - 12,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.textPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.border,
                            width: AppConst.borderWidthL,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF000000),
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}