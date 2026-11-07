import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_palette.dart';
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
    final palette = AppPalette.of(context);
    final muted = palette.textMuted;
    final senses = widget.entry.senses;
    final visible = _expanded ? senses : senses.take(WordMeaningsSection.collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Sözlük Anlamları', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.2, color: palette.textSecondary)),
            if (widget.entry.isInflected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text('→ ${widget.entry.lemma}',
                    overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: muted)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        for (final sense in visible)
          WordSenseRow(sense: sense, selected: widget.selected, onPick: widget.onPick),
        if (senses.length > WordMeaningsSection.collapsedCount)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16),
            label: Text(_expanded ? 'Daha az göster' : 'Tüm anlamlar (${senses.length})'),
          ),
        _OnlineRow(
          online: widget.online,
          isLoading: widget.isOnlineLoading,
          selected: widget.selected,
          onPick: widget.onPick,
          onFetch: widget.onFetchOnline,
        ),
        Text('Kaynak: Wiktionary (CC BY-SA)', style: TextStyle(fontSize: 11.5, color: muted)),
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
        icon: const Icon(LucideIcons.languages, size: 16),
        label: const Text('Çevrimiçi çeviriyi de göster'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Çevrimiçi:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppPalette.of(context).textSecondary)),
          WordPickChip(label: text, selected: selected == text, onPick: onPick),
        ],
      ),
    );
  }
}
