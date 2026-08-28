import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaTabBar extends StatelessWidget {
  const NovaTabBar({
    super.key,
    required this.tabs,
    required this.index,
    this.onChanged,
    this.height = 44,
  });

  final List<String> tabs;
  final int index;
  final ValueChanged<int>? onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth / tabs.length;
        return Container(
          height: height,
          color: const Color(0xFF201609),
          child: Stack(
            children: [
              Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onChanged?.call(i),
                          child: Center(
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                fontFamily: AppFonts.monoFont,
                                fontVariations: [FontVariation.weight(700)],
                                fontSize: 12,
                                letterSpacing: 2,
                                color: i == index ? colors.textPrimary : colors.textDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: index * w,
                width: w,
                bottom: 0,
                height: 4,
                child: Container(color: colors.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}