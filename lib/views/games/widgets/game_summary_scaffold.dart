import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';
import 'game_mistakes_card.dart';
import 'game_stat_tile.dart';

/// Dört oyunun ortak "oyun bitti" düzeni: başlık, özet, istatistik kartı,
/// yanlışlar ve iki aksiyon (tekrar oyna / oyun merkezine dön).
class GameSummaryScaffold extends StatelessWidget {
  final String appBarTitle;
  final String headline;
  final String message;
  final List<GameStatTile> stats;
  final List<FlashcardModel> missedCards;
  final String restartLabel;
  final VoidCallback onRestart;

  const GameSummaryScaffold({
    super.key,
    required this.appBarTitle,
    required this.headline,
    required this.message,
    required this.stats,
    required this.missedCards,
    required this.onRestart,
    this.restartLabel = 'Tekrar Oyna',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: p.cardDecoration(),
                // Wrap: dar ekran / büyük yazıda istatistikler alt satıra iner.
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 16,
                  runSpacing: 12,
                  children: stats,
                ),
              ),
              if (missedCards.isNotEmpty) ...[
                const SizedBox(height: 16),
                GameMistakesCard(cards: missedCards),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(LucideIcons.rotateCcw, size: 18),
                  label: Text(restartLabel),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Oyun Merkezine Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
