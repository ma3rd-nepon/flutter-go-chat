import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaAppBar extends StatelessWidget {
  const NovaAppBar({super.key, this.leading, required this.title, this.actions});

  final Widget? leading;
  final Widget title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface, // colors.surface
        border: Border(
          bottom: BorderSide(color: colors.border, width: 2), // colors.border
        ),
        boxShadow: [
          BoxShadow(color: colors.surfaceShadow, offset: Offset(0, 3), blurRadius: 0), // Color(0xFF000000)
        ],
      ),
      child: Row(
        children: [
          ?leading,
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: AppFonts.displayFont,
                fontVariations: [FontVariation.weight(700)],
                fontSize: 16,
                letterSpacing: 3,
                color: colors.textPrimary,
              ),
              child: title,
            ),
          ),
          ...actions ?? [],
        ],
      ),
    );
  }
}