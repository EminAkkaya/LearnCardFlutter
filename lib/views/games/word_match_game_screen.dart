import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/games/word_match_provider.dart';
import 'widgets/word_match_game_over_view.dart';
import 'widgets/word_match_hud_bar.dart';
import 'widgets/word_match_tile.dart';

class WordMatchGameScreen extends ConsumerWidget {
  final List<FlashcardModel> cards;

  const WordMatchGameScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = wordMatchProvider(cards);
    final s = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (s.tiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelime Eşleştirme')),
        body: const Center(child: Text('Eşleştirilecek kart bulunamadı.')),
      );
    }

    if (s.isGameOver) {
      return WordMatchGameOverView(
        totalPairs: s.totalPairs,
        score: s.score,
        mistakes: s.mistakes,
        onPlayAgain: notifier.restart,
        missedCards: s.missedCards,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Eşleştirme'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yeniden Başlat',
            onPressed: notifier.restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              WordMatchHudBar(
                matchedPairs: s.matchedPairs,
                totalPairs: s.totalPairs,
                score: s.score,
                mistakes: s.mistakes,
                streak: s.streak,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: s.tiles.length,
                  itemBuilder: (context, index) {
                    final tile = s.tiles[index];
                    return WordMatchTile(tile: tile, onTap: () => notifier.tapTile(tile.id));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
