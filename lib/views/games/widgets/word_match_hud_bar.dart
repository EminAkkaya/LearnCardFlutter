import 'package:flutter/material.dart';

class WordMatchHudBar extends StatelessWidget {
  final int matchedPairs;
  final int totalPairs;
  final int score;
  final int mistakes;
  final int streak;

  static const Color emerald = Color(0xFF10B981);

  const WordMatchHudBar({
    super.key,
    required this.matchedPairs,
    required this.totalPairs,
    required this.score,
    required this.mistakes,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: emerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emerald.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Eşleşen', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                '$matchedPairs/$totalPairs',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: emerald),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Puan', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                '$score',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seri', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                'x$streak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: streak > 1 ? Colors.orangeAccent : Colors.grey,
                ),
              ),
            ],
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Süre', style: TextStyle(fontSize: 11, color: Colors.grey)),
              SizedBox(height: 2),
              Text('Serbest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
