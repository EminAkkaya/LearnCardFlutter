import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/games/context_cloze_provider.dart';
import '../../providers/games/speed_quiz_provider.dart';
import '../../providers/games/word_match_provider.dart';
import '../../providers/games/word_scramble_provider.dart';
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

  /// Seçili kategorinin kartları. Kategori boşsa sessizce tüm desteye
  /// düşülmez; oyunlar "yetersiz kart" olarak kapalı görünür.
  List<FlashcardModel> _getCategoryCards(FlashcardState state) {
    switch (_selectedCategory) {
      case 'due':
        return state.dueCards;
      case 'learning':
        return state.learningCards;
      case 'new':
        return state.newCards;
      case 'mastered':
        return state.masteredCards;
      case 'all':
      default:
        return state.cards;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final cardState = ref.watch(flashcardProvider);
    final currentPool = _getCategoryCards(cardState);
    // Her oyun için gerçekten oynanabilir içerik sayısı (ör. tek kelimelik kart,
    // yeterli çeldiricisi olan soru).
    final matchPairs = buildWordMatchTiles(currentPool).length ~/ 2;
    final scrambleWords = pickScrambleCards(currentPool).length;
    final quizQuestions = buildSpeedQuizQuestions(currentPool).length;
    final clozeQuestions = buildClozeQuestions(currentPool).length;

    final games = <GameCardItem>[
      GameCardItem(
        title: '1. Özel Kart Tekrarı (Serbest Mod)',
        subtitle: 'Algoritmadan bağımsız, özelleştirilmiş seans ile kartları çalışın',
        badge: 'Serbest Tekrar',
        icon: LucideIcons.layers,
        minCardsRequired: 1,
        currentCardsCount: currentPool.length,
        onPlay: () => showCustomStudyBottomSheet(
          context,
          cardState,
          initialStatus: _selectedCategory,
        ),
      ),
      GameCardItem(
        title: '2. Kelime Eşleştirme',
        subtitle: 'İngilizce kelimeler ile Türkçe karşılıklarını eşleştirin',
        badge: 'Çift Kodlama',
        icon: LucideIcons.grid2x2,
        minCardsRequired: 3,
        currentCardsCount: matchPairs,
        onPlay: () => _open(context, WordMatchGameScreen(cards: currentPool)),
      ),
      GameCardItem(
        title: '3. Harf Sihirbazı (Yazım)',
        subtitle: 'Karışık harflerden doğru İngilizce kelimeyi oluşturun',
        badge: 'İmlasal Bellek',
        icon: LucideIcons.spellCheck,
        minCardsRequired: 1,
        currentCardsCount: scrambleWords,
        onPlay: () => _open(context, WordScrambleGameScreen(cards: currentPool)),
      ),
      GameCardItem(
        title: '4. Hızlı Karar Testi',
        subtitle: '10 saniyelik sürede doğru anlamı bularak kombo serisi yapın',
        badge: 'Hızlı Geri Çağırma',
        icon: LucideIcons.timer,
        minCardsRequired: 1,
        currentCardsCount: quizQuestions,
        onPlay: () => _open(context, SpeedQuizGameScreen(cards: currentPool)),
      ),
      GameCardItem(
        title: '5. Cümle İçi Boşluk Doldurma',
        subtitle: 'Örnek cümledeki boşluğa en uygun kelimeyi yerleştirin',
        badge: 'Bağlamsal Öğrenme',
        icon: LucideIcons.textCursorInput,
        minCardsRequired: 1,
        currentCardsCount: clozeQuestions,
        onPlay: () => _open(context, ContextClozeGameScreen(cards: currentPool)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Oyunlar & Alıştırmalar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GameHubIntroBanner(),
            const SizedBox(height: 24),
            GameCategoryChips(
              cardState: cardState,
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 24),
            Text(
              'Eğitim Modları & Oyunlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: p.textPrimary),
            ),
            const SizedBox(height: 12),
            // Dar ekranda tek sütun liste, genişte iki sütunlu ızgara.
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final twoCols = constraints.maxWidth >= 640;
                final itemWidth = twoCols ? (constraints.maxWidth - gap) / 2 : constraints.maxWidth;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final g in games) SizedBox(width: itemWidth, child: g),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
