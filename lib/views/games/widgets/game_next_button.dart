import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Cevaptan sonra çıkan "Sonraki Soru / Sonuçları Gör" butonu.
/// Temanın birincil (vurgu) dolgusunu kullanır; metin onPrimary.
class GameNextButton extends StatelessWidget {
  final bool hasNext;
  final VoidCallback onPressed;

  const GameNextButton({
    super.key,
    required this.hasNext,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(LucideIcons.arrowRight, size: 18),
        label: Text(
          hasNext ? 'Sonraki Soru' : 'Sonuçları Gör',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
