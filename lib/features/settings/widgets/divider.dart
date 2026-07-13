import 'package:flutter/material.dart';

import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class NovaDivider extends StatelessWidget {
  const NovaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surfaceTransparent,
            colors.primary.withValues(alpha: 0.2),
            colors.myMessageBubble.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }
}
