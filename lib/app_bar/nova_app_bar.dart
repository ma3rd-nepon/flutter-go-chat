import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaAppBar extends StatelessWidget {
  const NovaAppBar({super.key, this.leading, required this.title, this.actions});

  final Widget? leading;
  final Widget title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: NovaTheme.surface,
        border: Border(
          bottom: BorderSide(color: NovaTheme.ink, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Color(0xFF000000), offset: Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          ?leading,
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: NovaTheme.displayFont,
                fontVariations: [FontVariation.weight(700)],
                fontSize: 16,
                letterSpacing: 3,
                color: NovaTheme.paper,
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