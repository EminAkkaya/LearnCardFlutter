import 'package:flutter/material.dart';
import '../../../services/srs_service.dart';
import 'srs_rating_button.dart';

class SRSRatingActionBar extends StatelessWidget {
  final Map<ReviewRating, String> previews;
  final ValueChanged<ReviewRating> onRating;

  static const Color emerald = Color(0xFF10B981);

  const SRSRatingActionBar({
    super.key,
    required this.previews,
    required this.onRating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hatırlama Kalitesini Seçin',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SRSRatingButton(
              label: 'Tekrar',
              days: previews[ReviewRating.again] ?? '',
              color: Colors.red,
              onPressed: () => onRating(ReviewRating.again),
            ),
            const SizedBox(width: 8),
            SRSRatingButton(
              label: 'Zor',
              days: previews[ReviewRating.hard] ?? '',
              color: Colors.orange,
              onPressed: () => onRating(ReviewRating.hard),
            ),
            const SizedBox(width: 8),
            SRSRatingButton(
              label: 'İyi',
              days: previews[ReviewRating.good] ?? '',
              color: Colors.blue,
              onPressed: () => onRating(ReviewRating.good),
            ),
            const SizedBox(width: 8),
            SRSRatingButton(
              label: 'Kolay',
              days: previews[ReviewRating.easy] ?? '',
              color: emerald,
              onPressed: () => onRating(ReviewRating.easy),
            ),
          ],
        ),
      ],
    );
  }
}
