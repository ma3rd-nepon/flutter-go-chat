import 'package:flutter/widgets.dart';

import '../menu/nova_context_menu.dart';
import '../../core/novacore.dart';

class NovaTextField extends StatefulWidget {
  const NovaTextField({
    super.key,
    this.controller,
    this.label,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<NovaTextField> createState() => _NovaTextFieldState();
}

class _NovaTextFieldState extends State<NovaTextField> {
  TextEditingController? _internal;
  FocusNode? _internalFocus;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internal ??= TextEditingController());

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _internal?.dispose();
    _internalFocus?.dispose();
    super.dispose();
  }

  void _openMenu(Offset position) {
    NovaContextMenu.show(context, position, [
      NovaContextMenuItem(
        label: 'КОПИРОВАТЬ',
        onPressed: () => NovaTextActions.copySelection(_controller),
      ),
      NovaContextMenuItem(
        label: 'ВЫРЕЗАТЬ',
        onPressed: () => NovaTextActions.cut(_controller),
      ),
      NovaContextMenuItem(
        label: 'ВСТАВИТЬ',
        onPressed: () => NovaTextActions.paste(_controller),
      ),
      NovaContextMenuItem(
        label: 'ВЫДЕЛИТЬ ВСЁ',
        onPressed: () => NovaTextActions.selectAll(_controller),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return GestureDetector(
      onSecondaryTapUp: (d) => _openMenu(d.globalPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: _focused ? colors.primary : colors.border,
            width: AppConst.borderWidthL,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000),
              offset: _focused ? const Offset(4, 4) : const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    fontFamily: AppFonts.monoFont,
                    fontSize: 10,
                    letterSpacing: 1,
                    color: _focused || _controller.text.isNotEmpty
                        ? colors.primary
                        : colors.textDisabled,
                  ),
                ),
              ),
            EditableText(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              obscureText: widget.obscureText,
              cursorColor: colors.primary,
              backgroundCursorColor: colors.textDisabled,
              selectionColor: colors.primary.withValues(alpha: 0.35),
              style: TextStyle(
                fontFamily: AppFonts.bodyFont,
                fontVariations: [FontVariation.weight(600)],
                fontSize: 14,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}