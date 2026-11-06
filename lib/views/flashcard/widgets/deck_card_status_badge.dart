import 'package:flutter/material.dart';
import '../../../core/theme/feedback_colors.dart';

class DeckCardStatusBadge extends StatelessWidget {
  final String status;

  const DeckCardStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final fb = FeedbackColors.of(context);
    Color color = Colors.grey;
    if (status == 'new') color = Colors.blue;
    if (status == 'learning') color = fb.warning;
    if (status == 'mastered') color = fb.success;

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
