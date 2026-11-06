import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class WordMatchHudBar extends StatelessWidget {
  final int matchedPairs;
  final int totalPairs;
  final int score;
  final int mistakes;
  final int streak;

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
    final fb = FeedbackColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: fb.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fb.success.withValues(alpha: 0.3)),
      ),
      // Wrap: dar ekran / büyük yazıda istatistikler alt satıra iner.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 8,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Eşleşen', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                '$matchedPairs/$totalPairs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fb.success),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fb.warning),
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
                  color: streak > 1 ? fb.warning : Colors.grey,
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
