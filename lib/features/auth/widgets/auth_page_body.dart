import 'package:flutter/material.dart';

import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/clipper_extension.dart';

class AuthPageBody extends StatelessWidget {
  const AuthPageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class AuthBodyPanel extends StatelessWidget {
  const AuthBodyPanel({
    super.key,
    required this.height,
    required this.child,
    this.keyboardHeight = 0.0
  });

  final double height;
  final Widget child;
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: height, end: height),
      duration: const Duration(
        milliseconds: 420
      ),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedHeight, child) {
        return ClipPath(
          clipper: AppTopCurveClipper(),
          child: Container(
            height: animatedHeight + keyboardHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: .topLeft,
                end: .bottomRight,
                colors: [colors.surfaceVariant, colors.surfaceElevated]
              )
            ),
            child: Align(
              alignment: .topCenter,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 560
                ),
                child: child
              )
            )
          )
        );
      },
      child: child
    );
  }
}