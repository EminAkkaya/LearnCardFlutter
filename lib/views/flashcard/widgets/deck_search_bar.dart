import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeckSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DeckSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Kartlarda ara (Kelime, çeviri)...',
        prefixIcon: const Icon(LucideIcons.search, size: 18),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
