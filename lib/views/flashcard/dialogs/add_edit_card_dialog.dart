import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../services/dictionary_service.dart';

class AddEditCardDialog extends ConsumerStatefulWidget {
  final FlashcardModel? cardToEdit;

  const AddEditCardDialog({super.key, this.cardToEdit});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    FlashcardModel? cardToEdit,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AddEditCardDialog(cardToEdit: cardToEdit),
    );
  }

  @override
  ConsumerState<AddEditCardDialog> createState() => _AddEditCardDialogState();
}

class _AddEditCardDialogState extends ConsumerState<AddEditCardDialog> {
  late final TextEditingController _wordCtrl;
  late final TextEditingController _trCtrl;
  late final TextEditingController _defCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _phoneticCtrl;
  late final TextEditingController _partOfSpeechCtrl;
  late final TextEditingController _audioCtrl;

  bool _isLookingUp = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cardToEdit;
    _wordCtrl = TextEditingController(text: c?.word ?? '');
    _trCtrl = TextEditingController(text: c?.trTranslation ?? '');
    _defCtrl = TextEditingController(text: c?.definition ?? '');
    _exampleCtrl = TextEditingController(text: c?.exampleSentence ?? '');
    _phoneticCtrl = TextEditingController(text: c?.phonetic ?? '');
    _partOfSpeechCtrl = TextEditingController(text: c?.partOfSpeech ?? '');
    _audioCtrl = TextEditingController(text: c?.audioUrl ?? '');
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _trCtrl.dispose();
    _defCtrl.dispose();
    _exampleCtrl.dispose();
    _phoneticCtrl.dispose();
    _partOfSpeechCtrl.dispose();
    _audioCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDefinition() async {
    if (_wordCtrl.text.trim().isEmpty) return;
    setState(() => _isLookingUp = true);
    final res = await DictionaryService.fetchWordDefinition(_wordCtrl.text);
    if (!mounted) return;
    setState(() {
      _trCtrl.text = res.trTranslation;
      _defCtrl.text = res.definition;
      _phoneticCtrl.text = res.phonetic;
      _partOfSpeechCtrl.text = res.partOfSpeech;
      _audioCtrl.text = res.audioUrl;
      _isLookingUp = false;
    });
  }

  Future<void> _saveCard() async {
    if (_wordCtrl.text.trim().isEmpty) return;
    final nav = Navigator.of(context);

    if (widget.cardToEdit != null) {
      final updated = widget.cardToEdit!.copyWith(
        word: _wordCtrl.text.trim(),
        trTranslation: _trCtrl.text.trim(),
        definition: _defCtrl.text.trim(),
        exampleSentence: _exampleCtrl.text.trim(),
        phonetic: _phoneticCtrl.text.trim(),
        partOfSpeech: _partOfSpeechCtrl.text.trim(),
        audioUrl: _audioCtrl.text.trim(),
      );
      await ref.read(flashcardProvider.notifier).updateCard(updated);
    } else {
      await ref.read(flashcardProvider.notifier).addCard(
            word: _wordCtrl.text.trim(),
            trTranslation: _trCtrl.text.trim(),
            definition: _defCtrl.text.trim(),
            exampleSentence: _exampleCtrl.text.trim(),
            phonetic: _phoneticCtrl.text.trim(),
            partOfSpeech: _partOfSpeechCtrl.text.trim(),
            audioUrl: _audioCtrl.text.trim(),
          );
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cardToEdit == null ? 'Yeni Kart Ekle' : 'Kartı Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'İngilizce Kelime *',
                      hintText: 'Örn: serendipity',
                    ),
                  ),
                ),
                if (widget.cardToEdit == null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _isLookingUp ? null : _fetchDefinition,
                    icon: _isLookingUp
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
              controller: _trCtrl,
              decoration: const InputDecoration(labelText: 'Türkçe Çeviri'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _defCtrl,
              decoration: const InputDecoration(labelText: 'İngilizce Tanım'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleCtrl,
              decoration: const InputDecoration(labelText: 'Örnek Cümle'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveCard,
          child: Text(widget.cardToEdit == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }
}
