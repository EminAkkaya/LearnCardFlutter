import 'package:flutter/material.dart';

/// Cevaptan sonra çıkan "Sonraki Soru / Sonuçları Gör" butonu.
class GameNextButton extends StatelessWidget {
  final bool hasNext;
  final Color color;
  final VoidCallback onPressed;

  const GameNextButton({
    super.key,
    required this.hasNext,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          hasNext ? 'Sonraki Soru' : 'Sonuçları Gör',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
