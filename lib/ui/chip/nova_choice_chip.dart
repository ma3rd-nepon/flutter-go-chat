import 'package:flutter/widgets.dart';

import '../../core/novacore.dart';
import 'nova_chip.dart';

class NovaChoiceChip extends StatelessWidget {
  const NovaChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return NovaChip(
      label: Text(label),
      leading: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.border,
                shape: BoxShape.circle,
              ),
            )
          : null,
      selected: selected,
      selectedColor: colors.primaryHover,
      onPressed: onSelected == null ? null : () => onSelected!(true),
    );
  }
}