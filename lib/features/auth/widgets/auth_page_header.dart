import 'package:flutter/material.dart';

import '../../../core/theme/theme_extension.dart';

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveIconColor = iconColor ?? colors.primary;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    
    return Padding(
      padding: const .symmetric(
        horizontal: 32
      ),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Container(
            width: 96,
            height: 96,
            margin: .only(
              bottom: keyboardHeight > 0 ? 0 : 24
            ),
            decoration: BoxDecoration(
              shape: .circle,
              color: effectiveIconColor.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: effectiveIconColor.withValues(alpha: 0.18),
                  blurRadius: 32,
                  spreadRadius: 4
                )
              ]
            ),

            child: Icon(
              icon,
              size: 48,
              color: effectiveIconColor
            )
          ),

          Text(
            title,
            style: context.textStyles.displayMedium,
            textAlign: .center,
          ),

          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: context.textStyles.titleSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: .normal
              ),
              textAlign: .center,
            )
          ]
        ],
      )
    );
  }
}