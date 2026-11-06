import 'package:flutter/material.dart';

class ClozeHudBar extends StatelessWidget {
  final int score;
  final bool showHint;
  final String hintText;
  final VoidCallback onToggleHint;

  const ClozeHudBar({
    super.key,
    required this.score,
    required this.showHint,
    required this.hintText,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
            TextButton.icon(
              onPressed: onToggleHint,
              icon: Icon(
                showHint ? Icons.visibility_off_outlined : Icons.lightbulb_outline_rounded,
                size: 18,
                color: Colors.amber,
              ),
              label: Text(
                showHint ? 'İpucunu Gizle' : 'İpucu Gör',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        if (showHint) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Türkçe Anlamı: $hintText',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
