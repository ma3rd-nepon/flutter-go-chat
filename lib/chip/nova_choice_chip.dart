import 'package:flutter/widgets.dart';

import '../theme/nova_theme.dart';
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
    return NovaChip(
      label: Text(label),
      leading: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: NovaTheme.ink,
                shape: BoxShape.circle,
              ),
            )
          : null,
      selected: selected,
      selectedColor: NovaTheme.gold,
      onPressed: onSelected == null ? null : () => onSelected!(true),
    );
  }
}