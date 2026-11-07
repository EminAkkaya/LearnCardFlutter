import 'package:flutter/material.dart';

import '../../../models/offline_entry.dart';
import 'word_sense_row.dart';

/// Çevrimdışı sözlükteki anlamlar ve isteğe bağlı çevrimiçi çeviri.
/// Bir karşılığa dokunmak onu kartın çevirisi yapar ([onPick]).
class WordMeaningsSection extends StatefulWidget {
  static const int collapsedCount = 4;

  final OfflineEntry entry;
  final String selected;
  final String? online;
  final bool isOnlineLoading;
  final ValueChanged<String> onPick;
  final VoidCallback onFetchOnline;

  const WordMeaningsSection({
    super.key,
    required this.entry,
    required this.selected,
    required this.online,
    required this.isOnlineLoading,
    required this.onPick,
    required this.onFetchOnline,
  });

  @override
  State<WordMeaningsSection> createState() => _WordMeaningsSectionState();
}

class _WordMeaningsSectionState extends State<WordMeaningsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7);
    final senses = widget.entry.senses;
    final visible = _expanded ? senses : senses.take(WordMeaningsSection.collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Sözlük Anlamları', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (widget.entry.isInflected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text('→ ${widget.entry.lemma}',
                    overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: muted)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        for (final sense in visible)
          WordSenseRow(sense: sense, selected: widget.selected, onPick: widget.onPick),
        if (senses.length > WordMeaningsSection.collapsedCount)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Daha az göster' : 'Tüm anlamlar (${senses.length})'),
          ),
        _OnlineRow(
          online: widget.online,
          isLoading: widget.isOnlineLoading,
          selected: widget.selected,
          onPick: widget.onPick,
          onFetch: widget.onFetchOnline,
        ),
        Text('Kaynak: Wiktionary (CC BY-SA)', style: TextStyle(fontSize: 11, color: muted)),
      ],
    );
  }
}

class _OnlineRow extends StatelessWidget {
  final String? online;
  final bool isLoading;
  final String selected;
  final ValueChanged<String> onPick;
  final VoidCallback onFetch;

  const _OnlineRow({
    required this.online,
    required this.isLoading,
    required this.selected,
    required this.onPick,
    required this.onFetch,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final text = online;
    if (text == null) {
      return TextButton.icon(
        onPressed: onFetch,
        icon: const Icon(Icons.translate_rounded, size: 18),
        label: const Text('Çevrimiçi çeviriyi de göster'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Çevrimiçi:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ChoiceChip(
            label: Text(text),
            selected: selected == text,
            onSelected: (_) => onPick(text),
          ),
        ],
      ),
    );
  }
}
