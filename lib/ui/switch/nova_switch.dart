import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaSwitch extends StatelessWidget {
  const NovaSwitch({
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
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 54,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? colors.primary : colors.surface,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: colors.border, width: AppConst.borderWidthL),
              boxShadow: const [
                BoxShadow(color: Color(0xFF000000), offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: AppConst.borderWidthL),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}