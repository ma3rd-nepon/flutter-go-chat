import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_go_chat/core/services/app_scope/scope.dart';
import 'package:flutter_go_chat/app/theme/theme_extension.dart';

class NovaContainer extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final int? radius;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  NovaContainer({
    super.key,
    required this.child,
    this.alignment,
    this.padding,
    this.radius = 30,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.clipBehavior = Clip.none,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(constraints == null || constraints.debugAssertIsValid());
      //  constraints = (width != null || height != null) ? constraints?.tighten(width: width, height: height) ?? BoxConstraints.tightFor(width: width, height: height) : constraints;

  @override
  Widget build(BuildContext context) {
    final g = AppScope.read(context).settingsController;

    return ListenableBuilder(
      listenable: g,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius?.toDouble() ?? 24),
            clipBehavior: .antiAlias,
            child: Container(
            width: width,
            height: height,
            constraints: constraints,
            alignment: alignment,
            padding: padding,
            margin: margin,
            clipBehavior: clipBehavior,
            child: g.useGlass
                ? GlassSurface(
                    key: const ValueKey('glass'),
                    child: child ?? SizedBox.shrink(),
                  )
                : MatteSurface(
                    key: const ValueKey('matte'),
                    child: child ?? SizedBox.shrink(),
                  ),
          ),
        ));
      },
      child: child,
    );
  }
}

class GlassSurface extends StatelessWidget {
  final Widget child;
  const GlassSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.read(context).settingsController;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: settings.glassBlur,
          sigmaY: settings.glassBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 3
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MatteSurface extends StatelessWidget {
  final Widget child;
  const MatteSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeExtension>()!.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderLight, width: 3),
      ),
      child: child,
    );
  }
}
