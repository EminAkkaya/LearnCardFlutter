import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../flashcard/widgets/custom_study_bottom_sheet.dart';
import 'context_cloze_game_screen.dart';
import 'speed_quiz_game_screen.dart';
import 'widgets/game_card_item.dart';
import 'widgets/game_category_chips.dart';
import 'widgets/game_hub_intro_banner.dart';
import 'word_match_game_screen.dart';
import 'word_scramble_game_screen.dart';

class MiniGamesHubScreen extends ConsumerStatefulWidget {
  const MiniGamesHubScreen({super.key});

  @override
  ConsumerState<MiniGamesHubScreen> createState() => _MiniGamesHubScreenState();
}

class _MiniGamesHubScreenState extends ConsumerState<MiniGamesHubScreen> {
  String _selectedCategory = 'all';

  List<FlashcardModel> _getCategoryCards(FlashcardState state) {
    switch (_selectedCategory) {
      case 'due':
        return state.dueCards.isNotEmpty ? state.dueCards : state.cards;
      case 'learning':
        return state.learningCards.isNotEmpty
            ? state.learningCards
            : state.cards;
      case 'new':
        return state.newCards.isNotEmpty ? state.newCards : state.cards;
      case 'mastered':
        return state.masteredCards.isNotEmpty
            ? state.masteredCards
            : state.cards;
      case 'all':
      default:
        return state.cards;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);
    final currentPool = _getCategoryCards(cardState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Oyunlar & Alıştırmalar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GameHubIntroBanner(),
            const SizedBox(height: 20),
            GameCategoryChips(
              cardState: cardState,
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 24),
            Text(
              'Eğitim Modları & Oyunlar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GameCardItem(
              title: '1. Özel Kart Tekrarı (Serbest Mod)',
              subtitle:
                  'Algoritmadan bağımsız, özelleştirilmiş seans ile kartları çalışın',
              badge: 'Serbest Tekrar',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.style_rounded,
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              minCardsRequired: 1,
              currentCardsCount: currentPool.length,
              onPlay: () => showCustomStudyBottomSheet(
                context,
                cardState,
                initialStatus: _selectedCategory,
              ),
            ),
            const SizedBox(height: 14),
            GameCardItem(
              title: '2. Kelime Eşleştirme',
              subtitle:
                  'İngilizce kelimeler ile Türkçe karşılıklarını eşleştirin',
              badge: 'Çift Kodlama',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.grid_view_rounded,
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              minCardsRequired: 3,
              currentCardsCount: currentPool.length,
              onPlay: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WordMatchGameScreen(cards: currentPool),
                ),
              ),
            ),
            const SizedBox(height: 14),
            GameCardItem(
              title: '3. Harf Sihirbazı (Yazım)',
              subtitle: 'Karışık harflerden doğru İngilizce kelimeyi oluşturun',
              badge: 'İmlasal Bellek',
              badgeColor: const Color(0xFF6366F1),
              icon: Icons.spellcheck_rounded,
              gradientColors: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
              minCardsRequired: 1,
              currentCardsCount: currentPool.length,
              onPlay: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WordScrambleGameScreen(cards: currentPool),
                ),
              ),
            ),
            const SizedBox(height: 14),
            GameCardItem(
              title: '4. Hızlı Karar Testi',
              subtitle:
                  '10 saniyelik sürede doğru anlamı bularak kombo serisi yapın',
              badge: 'Hızlı Geri Çağırma',
              badgeColor: const Color(0xFFF59E0B),
              icon: Icons.timer_outlined,
              gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
              minCardsRequired: 4,
              currentCardsCount: currentPool.length,
              onPlay: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpeedQuizGameScreen(cards: currentPool),
                ),
              ),
            ),
            const SizedBox(height: 14),
            GameCardItem(
              title: '5. Cümle İçi Boşluk Doldurma',
              subtitle:
                  'Örnek cümledeki boşluğa en uygun kelimeyi yerleştirin',
              badge: 'Bağlamsal Öğrenme',
              badgeColor: const Color(0xFFEC4899),
              icon: Icons.auto_stories_rounded,
              gradientColors: const [Color(0xFFDB2777), Color(0xFFEC4899)],
              minCardsRequired: 2,
              currentCardsCount: currentPool.length,
              onPlay: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContextClozeGameScreen(cards: currentPool),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
