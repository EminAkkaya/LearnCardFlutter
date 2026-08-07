import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/audio_helper.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../services/dictionary_service.dart';

class DeckManagerScreen extends ConsumerStatefulWidget {
  const DeckManagerScreen({super.key});

  @override
  ConsumerState<DeckManagerScreen> createState() => _DeckManagerScreenState();
}

class _DeckManagerScreenState extends ConsumerState<DeckManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const Color emerald = Color(0xFF10B981);

  void _showAddCardDialog({FlashcardModel? cardToEdit}) {
    final wordCtrl = TextEditingController(text: cardToEdit?.word ?? '');
    final trCtrl = TextEditingController(text: cardToEdit?.trTranslation ?? '');
    final defCtrl = TextEditingController(text: cardToEdit?.definition ?? '');
    final exampleCtrl = TextEditingController(text: cardToEdit?.exampleSentence ?? '');
    final phoneticCtrl = TextEditingController(text: cardToEdit?.phonetic ?? '');
    final partOfSpeechCtrl = TextEditingController(text: cardToEdit?.partOfSpeech ?? '');
    final audioCtrl = TextEditingController(text: cardToEdit?.audioUrl ?? '');

    bool isLookingUp = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(cardToEdit == null ? 'Yeni Kart Ekle' : 'Kartı Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: wordCtrl,
                            decoration: const InputDecoration(
                              labelText: 'İngilizce Kelime *',
                              hintText: 'Örn: serendipity',
                            ),
                          ),
                        ),
                        if (cardToEdit == null) ...[
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: isLookingUp
                                ? null
                                : () async {
                                    if (wordCtrl.text.trim().isEmpty) return;
                                    setDialogState(() => isLookingUp = true);
                                    final res = await DictionaryService.fetchWordDefinition(wordCtrl.text);
                                    setDialogState(() {
                                      trCtrl.text = res.trTranslation;
                                      defCtrl.text = res.definition;
                                      phoneticCtrl.text = res.phonetic;
                                      partOfSpeechCtrl.text = res.partOfSpeech;
                                      audioCtrl.text = res.audioUrl;
                                      isLookingUp = false;
                                    });
                                  },
                            icon: isLookingUp
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search_rounded),
                            tooltip: 'Otomatik Çeviri & Sözlük Getir',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: trCtrl,
                      decoration: const InputDecoration(labelText: 'Türkçe Çeviri'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: defCtrl,
                      decoration: const InputDecoration(labelText: 'İngilizce Tanım'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: exampleCtrl,
                      decoration: const InputDecoration(labelText: 'Örnek Cümle'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (wordCtrl.text.trim().isEmpty) return;

                    final navigator = Navigator.of(ctx);

                    if (cardToEdit != null) {
                      final updated = cardToEdit.copyWith(
                        word: wordCtrl.text.trim(),
                        trTranslation: trCtrl.text.trim(),
                        definition: defCtrl.text.trim(),
                        exampleSentence: exampleCtrl.text.trim(),
                        phonetic: phoneticCtrl.text.trim(),
                        partOfSpeech: partOfSpeechCtrl.text.trim(),
                        audioUrl: audioCtrl.text.trim(),
                      );
                      await ref.read(flashcardProvider.notifier).updateCard(updated);
                    } else {
                      await ref.read(flashcardProvider.notifier).addCard(
                            word: wordCtrl.text.trim(),
                            trTranslation: trCtrl.text.trim(),
                            definition: defCtrl.text.trim(),
                            exampleSentence: exampleCtrl.text.trim(),
                            phonetic: phoneticCtrl.text.trim(),
                            partOfSpeech: partOfSpeechCtrl.text.trim(),
                            audioUrl: audioCtrl.text.trim(),
                          );
                    }

                    navigator.pop();
                  },
                  child: Text(cardToEdit == null ? 'Ekle' : 'Güncelle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);
    final cards = cardState.filteredCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deste Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(flashcardProvider.notifier).loadCards(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Kart'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => ref.read(flashcardProvider.notifier).setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Kartlarda ara (Kelime, çeviri)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(flashcardProvider.notifier).setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tümü (${cardState.cards.length})', cardState),
                      const SizedBox(width: 8),
                      _buildFilterChip('due', 'Bugün Tekrar (${cardState.dueCards.length})', cardState),
                      const SizedBox(width: 8),
                      _buildFilterChip('new', 'Yeni (${cardState.newCards.length})', cardState),
                      const SizedBox(width: 8),
                      _buildFilterChip('learning', 'Öğrenilen (${cardState.learningCards.length})', cardState),
                      const SizedBox(width: 8),
                      _buildFilterChip('mastered', 'Öğrenildi (${cardState.masteredCards.length})', cardState),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: cardState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cards.isEmpty
                    ? Center(
                        child: Text(
                          'Hiç kart bulunamadı.',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                children: [
                                  Text(
                                    card.word,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (card.phonetic.isNotEmpty)
                                    Text(
                                      card.phonetic,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    card.trTranslation.isNotEmpty
                                        ? card.trTranslation
                                        : card.definition,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _buildStatusBadge(card.status),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tekrar: ${card.repetitions} | Aralık: ${card.interval}g',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (card.audioUrl.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, color: Colors.indigo),
                                      onPressed: () => AudioHelper.playAudio(card.audioUrl),
                                    ),
                                  PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showAddCardDialog(cardToEdit: card);
                                      } else if (val == 'delete') {
                                        ref.read(flashcardProvider.notifier).deleteCard(card.id);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 20),
                                            SizedBox(width: 8),
                                            Text('Düzenle'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                            Text('Sil', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, FlashcardState cardState) {
    final bool isSelected = cardState.filterStatus == key;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => ref.read(flashcardProvider.notifier).setFilterStatus(key),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'new') color = Colors.blue;
    if (status == 'learning') color = Colors.orange;
    if (status == 'mastered') color = emerald;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
