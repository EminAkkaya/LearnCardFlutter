import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../../../services/dictionary_service.dart';

void showAddEditCardDialog(
  BuildContext context,
  WidgetRef ref, {
  FlashcardModel? cardToEdit,
}) {
  final wordCtrl = TextEditingController(text: cardToEdit?.word ?? '');
  final trCtrl = TextEditingController(text: cardToEdit?.trTranslation ?? '');
  final defCtrl = TextEditingController(text: cardToEdit?.definition ?? '');
  final exampleCtrl = TextEditingController(
    text: cardToEdit?.exampleSentence ?? '',
  );
  final phoneticCtrl = TextEditingController(
    text: cardToEdit?.phonetic ?? '',
  );
  final partOfSpeechCtrl = TextEditingController(
    text: cardToEdit?.partOfSpeech ?? '',
  );
  final audioCtrl = TextEditingController(text: cardToEdit?.audioUrl ?? '');

  bool isLookingUp = false;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              cardToEdit == null ? 'Yeni Kart Ekle' : 'Kartı Düzenle',
            ),
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
                                  final res =
                                      await DictionaryService.fetchWordDefinition(
                                        wordCtrl.text,
                                      );
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Türkçe Çeviri',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: defCtrl,
                    decoration: const InputDecoration(
                      labelText: 'İngilizce Tanım',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: exampleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Örnek Cümle',
                    ),
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
                    await ref
                        .read(flashcardProvider.notifier)
                        .updateCard(updated);
                  } else {
                    await ref
                        .read(flashcardProvider.notifier)
                        .addCard(
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
