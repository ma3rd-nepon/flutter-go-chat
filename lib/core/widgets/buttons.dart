import "package:flutter/material.dart";
import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class WindowsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const WindowsButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context)
    .extension<AppThemeExtension>()!
    .colors;

    return InkWell(
      hoverColor: colors.surfaceHover,
      onTap: onTap,
      child: Container(
        width: 46,
        height: 32,
        color: colors.surfaceTransparent,
        child: Icon(icon, size: 32, color: colors.iconPrimary),
      ),
    );
  }
}

class LogoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;

  const LogoButton({super.key, required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: Theme.of(context).elevatedButtonTheme.style,
      child: Text(text)
    );
  }
}
