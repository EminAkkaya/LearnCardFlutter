import 'package:flutter/material.dart';

import '../../../models/offline_entry.dart';

/// Sözlükteki tek anlam: tür etiketi, kısa İngilizce açıklama ve seçilebilir karşılıklar.
class WordSenseRow extends StatelessWidget {
  final OfflineSense sense;
  final String selected;
  final ValueChanged<String> onPick;

  const WordSenseRow({super.key, required this.sense, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: sense.posLabel,
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
              ),
              if (sense.sense.isNotEmpty) TextSpan(text: '  ${sense.sense}', style: TextStyle(color: muted)),
            ]),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final tr in sense.translations)
                ChoiceChip(
                  label: Text(tr),
                  selected: selected == tr,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => onPick(tr),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
