import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../games/mini_games_hub_screen.dart';

class MinigamesStatsCard extends StatelessWidget {
  final int totalGameScore;
  final int totalGamesPlayed;

  /// Ana sayfadaki Oyunlar sekmesine geçer; verilmezse oyun merkezi ayrı sayfa açılır.
  final VoidCallback? onOpenGames;

  const MinigamesStatsCard({
    super.key,
    required this.totalGameScore,
    required this.totalGamesPlayed,
    this.onOpenGames,
  });

  void _openGames(BuildContext context) {
    if (onOpenGames != null) {
      onOpenGames!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MiniGamesHubScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fb = FeedbackColors.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.trophy, color: fb.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Oyun Başarıları & Skor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openGames(context),
                  icon: const Icon(LucideIcons.play, size: 16),
                  label: const Text('Oyna', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScoreTile(label: 'Toplam Skor', value: '$totalGameScore'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoreTile(label: 'Tamamlanan Oyun', value: '$totalGamesPlayed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.subtle,
        borderRadius: BorderRadius.circular(AppPalette.radiusControl),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
