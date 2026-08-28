import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';
import 'nova_flame_bar.dart';

class NovaChatTile extends StatefulWidget {
  const NovaChatTile({
    super.key,
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
    this.online = false,
    this.onTap,
  });

  final String initials;
  final Color avatarColor;
  final String name;
  final String message;
  final String time;
  final int unread;
  final bool online;
  final VoidCallback? onTap;

  @override
  State<NovaChatTile> createState() => _NovaChatTileState();
}

class _NovaChatTileState extends State<NovaChatTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    final unreadActive = widget.unread > 0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF3A2A18) : const Color(0x00000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              if (unreadActive)
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: const NovaFlameBar(width: 6),
                ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: unreadActive ? colors.primary : colors.border,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.initials,
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontVariations: [FontVariation.weight(800)],
                              fontSize: 15,
                              color: colors.border,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.online ? colors.primary : colors.textDisabled,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.bodyFont,
                                  fontVariations: [FontVariation.weight(800)],
                                  fontSize: 15,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              widget.time,
                              style: TextStyle(
                                fontFamily: AppFonts.monoFont,
                                fontSize: 11,
                                color: unreadActive ? colors.primary : colors.textDisabled,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.bodyFont,
                                  fontVariations: [
                                    FontVariation.weight(unreadActive ? 700 : 500),
                                  ],
                                  fontSize: 13,
                                  color: unreadActive
                                      ? colors.textPrimary.withValues(alpha: 0.8)
                                      : colors.textDisabled,
                                ),
                              ),
                            ),
                            if (unreadActive) const SizedBox(width: 8),
                            if (unreadActive)
                              Transform.rotate(
                                angle: 0.7853981634,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    border: Border.all(color: colors.border, width: 2),
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.7853981634,
                                      child: Text(
                                        '${widget.unread}',
                                        style: TextStyle(
                                          fontFamily: AppFonts.bodyFont,
                                          fontVariations: [FontVariation.weight(800)],
                                          fontSize: 10,
                                          color: colors.border,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}