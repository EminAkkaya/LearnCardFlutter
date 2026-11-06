import 'package:flutter/material.dart';

class DeckFilterChipItem extends StatelessWidget {
  final String statusKey;
  final String label;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const DeckFilterChipItem({
    super.key,
    required this.statusKey,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onSelected(statusKey),
    );
  }
}
