import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaNavigationItem {
  const NovaNavigationItem({required this.icon, required this.label});

  final Widget Function(Color color) icon;
  final String label;
}

class NovaNavigationBar extends StatelessWidget {
  const NovaNavigationBar({
    super.key,
    required this.items,
    required this.index,
    this.onChanged,
  });

  final List<NovaNavigationItem> items;
  final int index;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Color(0xFF000000), offset: Offset(0, -3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onChanged?.call(i),
                  child: Stack(
                    children: [
                      if (i == index)
                        Positioned(
                          top: 0,
                          left: 24,
                          right: 24,
                          height: 3,
                          child: ColoredBox(color: colors.primary),
                        ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            items[i].icon(i == index ? colors.primary : colors.textDisabled),
                            const SizedBox(height: 4),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                fontFamily: AppFonts.monoFont,
                                fontSize: 9,
                                letterSpacing: 1,
                                color: i == index ? colors.textPrimary : colors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NovaNavigationRail extends StatelessWidget {
  const NovaNavigationRail({
    super.key,
    required this.items,
    required this.index,
    this.onChanged,
    this.width = 64,
  });

  final List<NovaNavigationItem> items;
  final int index;
  final ValueChanged<int>? onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.border, width: 2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged?.call(i),
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: i == index ? const Color(0xFF3A2A18) : const Color(0x00000000),
                  child: Stack(
                    children: [
                      if (i == index)
                        Positioned(
                          left: 0,
                          top: 8,
                          bottom: 8,
                          width: 3,
                          child: ColoredBox(color: colors.primary),
                        ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            items[i].icon(i == index ? colors.primary : colors.textDisabled),
                            const SizedBox(height: 4),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                fontFamily: AppFonts.monoFont,
                                fontSize: 8,
                                letterSpacing: 1,
                                color: i == index ? colors.textPrimary : colors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}