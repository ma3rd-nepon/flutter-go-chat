import 'dart:math';

import 'package:flutter/widgets.dart';

import '../theme/nova_cut_box.dart';
import '../../core/novacore.dart';

class NovaTypingIndicator extends StatefulWidget {
  const NovaTypingIndicator({super.key});

  @override
  State<NovaTypingIndicator> createState() => _NovaTypingIndicatorState();
}

class _NovaTypingIndicatorState extends State<NovaTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: NovaCutBox(
        color: colors.surface,
        cut: 10,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Transform.translate(
                    offset: Offset(0, sin(_controller.value * 2 * pi + i * 0.7) * 3),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == 1 ? colors.primaryHover : colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}