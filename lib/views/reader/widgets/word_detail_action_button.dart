import 'package:flutter/material.dart';
import '../../../models/flashcard_model.dart';

class WordDetailActionButton extends StatelessWidget {
  final FlashcardModel? existingCard;
  final bool isAdding;
  final VoidCallback onAdd;

  static const Color emerald = Color(0xFF10B981);

  const WordDetailActionButton({
    super.key,
    required this.existingCard,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (existingCard != null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: emerald.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: emerald),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: emerald),
            const SizedBox(width: 8),
            Text(
              'Destede Var (${cardStatusLabel(existingCard!.status)})',
              style: const TextStyle(fontWeight: FontWeight.bold, color: emerald),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isAdding ? null : onAdd,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Desteye Kart Olarak Ekle'),
    );
  }
}
