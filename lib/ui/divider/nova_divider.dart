import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';

class NovaDivider extends StatelessWidget {
  const NovaDivider.horizontal({super.key, this.thickness = 1, this.margin = const EdgeInsets.only(left: 1, right: 1), this.color}) : axis = .horizontal;

  const NovaDivider.vertical({super.key, this.thickness = 1, this.margin = const EdgeInsets.only(left: 1, right: 1), this.color}) : axis = .vertical;

  final double thickness;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return axis == Axis.horizontal ? Container(
      margin: margin,
      height: thickness,
      color: color ?? colors.border,
    ) : Container(
      margin: margin,
      width: thickness,
      color: color ?? colors.border
    );
  }
}