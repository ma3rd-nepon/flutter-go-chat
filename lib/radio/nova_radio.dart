import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaRadio<T> extends StatelessWidget {
  const NovaRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  bool get _selected => value == groupValue;
  bool get _disabled => onChanged == null;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _disabled ? null : () => onChanged!(value),
        child: Opacity(
          opacity: _disabled ? 0.5 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: NovaTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: NovaTheme.ink, width: NovaTheme.borderWidth),
              boxShadow: const [
                BoxShadow(color: Color(0xFF000000), offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: Center(
              child: AnimatedScale(
                scale: _selected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: NovaTheme.flame,
                    shape: BoxShape.circle,
                    border: Border.all(color: NovaTheme.ink, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}