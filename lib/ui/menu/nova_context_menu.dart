import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaContextMenuItem {
  const NovaContextMenuItem({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class NovaContextMenu {
  static void show(
    BuildContext context,
    Offset globalPosition,
    List<NovaContextMenuItem> items,
  ) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => entry.remove(),
            child: Container(color: const Color(0x00000000)),
          ),
          Positioned(
            left: globalPosition.dx,
            top: globalPosition.dy,
            child: _Menu(items: items, onDone: () => entry.remove()),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }
}

class _Menu extends StatefulWidget {
  const _Menu({required this.items, required this.onDone});

  final List<NovaContextMenuItem> items;
  final VoidCallback onDone;

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  int _hovered = -1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: 2),
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
                  widget.items[i].onPressed();
                },
                child: Container(
                  color: _hovered == i ? const Color(0xFF3A2A18) : const Color(0x00000000),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Text(
                    widget.items[i].label,
                    style: TextStyle(
                      fontFamily: AppFonts.monoFont,
                      fontVariations: [FontVariation.weight(700)],
                      fontSize: 12,
                      letterSpacing: 1,
                      color: _hovered == i ? colors.primary : colors.textPrimary,
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

class NovaTextActions {
  static Future<void> copy(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  static void copySelection(TextEditingController controller) {
    final sel = controller.selection;
    if (sel.isValid && !sel.isCollapsed) {
      copy(sel.textInside(controller.text));
    }
  }

  static void cut(TextEditingController controller) {
    copySelection(controller);
    final sel = controller.selection;
    if (!sel.isValid || sel.isCollapsed) return;
    controller.text = sel.textBefore(controller.text) + sel.textAfter(controller.text);
    controller.selection = TextSelection.collapsed(offset: sel.start);
  }

  static Future<void> paste(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null) return;
    final sel = controller.selection;
    final old = controller.text;
    final start = sel.isValid ? sel.start : old.length;
    final end = sel.isValid ? sel.end : old.length;
    controller.text = old.substring(0, start) + text + old.substring(end);
    controller.selection = TextSelection.collapsed(offset: start + text.length);
  }

  static void selectAll(TextEditingController controller) {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }
}