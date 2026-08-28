import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaListTile extends StatefulWidget {
  const NovaListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<NovaListTile> createState() => _NovaListTileState();
}

class _NovaListTileState extends State<NovaListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap == null) return;
        setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF3A2A18) : const Color(0x00000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontVariations: [FontVariation.weight(700)],
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                      child: widget.title,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: AppFonts.bodyFont,
                          fontVariations: [FontVariation.weight(500)],
                          fontSize: 13,
                          color: colors.textDisabled,
                        ),
                        child: widget.subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}