import 'package:flutter/material.dart';

class DeckCardStatusBadge extends StatelessWidget {
  final String status;

  static const Color emerald = Color(0xFF10B981);

  const DeckCardStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'new') color = Colors.blue;
    if (status == 'learning') color = Colors.orange;
    if (status == 'mastered') color = emerald;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
