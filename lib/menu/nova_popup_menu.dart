import 'package:flutter/widgets.dart';

import '../icons/nova_icons.dart';
import '../theme/nova_cut_box.dart';
import '../theme/nova_theme.dart';

class NovaMenuItem {
  const NovaMenuItem({required this.label, this.onSelected});

  final String label;
  final VoidCallback? onSelected;
}

class NovaPopupMenuButton extends StatefulWidget {
  const NovaPopupMenuButton({super.key, required this.items, this.child});

  final List<NovaMenuItem> items;
  final Widget? child;

  @override
  State<NovaPopupMenuButton> createState() => _NovaPopupMenuButtonState();
}

class _NovaPopupMenuButtonState extends State<NovaPopupMenuButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _open() {
    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
            child: Container(color: const Color(0x00000000)),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: _MenuPanel(
              items: widget.items,
              onDone: _close,
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _entry == null ? _open : _close,
          child: NovaCutBox(
            color: NovaTheme.surface,
            cut: 8,
            padding: const EdgeInsets.all(8),
            child: widget.child ?? const NovaIconGear(color: NovaTheme.paper),
          ),
        ),
      ),
    );
  }
}

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({required this.items, required this.onDone});

  final List<NovaMenuItem> items;
  final VoidCallback onDone;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  int _hovered = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      decoration: BoxDecoration(
        color: NovaTheme.surface,
        border: Border.all(color: NovaTheme.ink, width: 2),
        boxShadow: [
          BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = i),
              onExit: (_) => setState(() => _hovered = -1),
              child: GestureDetector(
                onTap: () {
                  widget.onDone();
                  widget.items[i].onSelected?.call();
                },
                child: Container(
                  color: _hovered == i ? const Color(0xFF3A2A18) : const Color(0x00000000),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    widget.items[i].label,
                    style: TextStyle(
                      fontFamily: NovaTheme.monoFont,
                      fontVariations: [FontVariation.weight(700)],
                      fontSize: 12,
                      letterSpacing: 1,
                      color: _hovered == i ? NovaTheme.flame : NovaTheme.paper,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}