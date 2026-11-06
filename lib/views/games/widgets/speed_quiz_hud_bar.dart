import 'package:flutter/material.dart';

class SpeedQuizHudBar extends StatelessWidget {
  final int score;
  final int streak;
  final int secondsRemaining;

  static const Color amberColor = Color(0xFFF59E0B);

  const SpeedQuizHudBar({
    super.key,
    required this.score,
    required this.streak,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 6),
            Text(
              'Puan: $score',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: streak > 1 ? Colors.orangeAccent : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 4),
            Text(
              'Seri: x$streak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: streak > 1 ? Colors.orangeAccent : Colors.grey,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (secondsRemaining <= 3 ? Colors.redAccent : amberColor).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secondsRemaining <= 3 ? Colors.redAccent : amberColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: secondsRemaining <= 3 ? Colors.redAccent : amberColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${secondsRemaining}s',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: secondsRemaining <= 3 ? Colors.redAccent : amberColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
