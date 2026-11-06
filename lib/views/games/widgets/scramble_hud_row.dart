import 'package:flutter/material.dart';

class ScrambleHudRow extends StatelessWidget {
  final int score;
  final int wordLength;

  const ScrambleHudRow({super.key, required this.score, required this.wordLength});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              'Puan: $score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        Text(
          'Kelime Uzunluğu: $wordLength Harf',
          style: TextStyle(fontSize: 12, color: mutedColor),
        ),
      ],
    );
  }
}
