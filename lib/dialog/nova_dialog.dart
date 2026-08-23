import 'package:flutter/widgets.dart';

import '../button/button_size.dart';
import '../button/button_variant.dart';
import '../button/nova_button.dart';
import '../theme/nova_cut_box.dart';
import '../theme/nova_theme.dart';

class NovaDialog {
  static OverlayEntry show(
    BuildContext context, {
    required Widget title,
    required Widget content,
    List<Widget>? actions,
  }) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _DialogHost(
        title: title,
        content: content,
        actions: actions,
        onClose: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }
}

class NovaAlertDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'ПОДТВЕРДИТЬ',
    String cancelLabel = 'ОТМЕНА',
    VoidCallback? onConfirm,
  }) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _DialogHost(
        title: Text(title),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: NovaTheme.bodyFont,
            fontVariations: [FontVariation.weight(600)],
            fontSize: 14,
            color: NovaTheme.muted,
          ),
        ),
        actions: [
          NovaButton(
            variant: ButtonVariant.ghost,
            size: ButtonSize.small,
            onPressed: () => entry.remove(),
            child: Text(cancelLabel),
          ),
          NovaButton(
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
            onPressed: () {
              entry.remove();
              onConfirm?.call();
            },
            child: Text(confirmLabel),
          ),
        ],
        onClose: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

class _DialogHost extends StatelessWidget {
  const _DialogHost({
    required this.title,
    required this.content,
    this.actions,
    required this.onClose,
  });

  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(color: const Color(0x99120B04)),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: NovaCutBox(
              cut: 16,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontFamily: NovaTheme.displayFont,
                            fontVariations: [FontVariation.weight(700)],
                            fontSize: 18,
                            color: NovaTheme.paper,
                          ),
                          child: title,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onClose,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: _CloseIcon(color: NovaTheme.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  content,
                  if (actions != null) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions!.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          actions![i],
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloseIcon extends StatelessWidget {
  const _CloseIcon({this.color = const Color(0xFFFFFFFF)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: _ClosePainter(color)),
    );
  }
}

class _ClosePainter extends CustomPainter {
  _ClosePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ClosePainter oldDelegate) => oldDelegate.color != color;
}