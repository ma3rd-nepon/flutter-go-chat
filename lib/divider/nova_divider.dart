import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';

class NovaDivider extends StatelessWidget {
  const NovaDivider({
    super.key,
    this.thickness = 2,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent, right: endIndent),
      height: thickness,
      color: color ?? NovaTheme.muted.withValues(alpha: 0.25),
    );
  }
}