import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../providers/flashcard_provider.dart';
import '../flashcard/widgets/custom_study_bottom_sheet.dart';
import 'context_cloze_game_screen.dart';
import 'speed_quiz_game_screen.dart';
import 'word_match_game_screen.dart';
import 'word_scramble_game_screen.dart';

class MiniGamesHubScreen extends ConsumerStatefulWidget {
  const MiniGamesHubScreen({super.key});

  @override
  ConsumerState<MiniGamesHubScreen> createState() => _MiniGamesHubScreenState();
}

class _MiniGamesHubScreenState extends ConsumerState<MiniGamesHubScreen> {
  String _selectedCategory = 'all'; // all, due, learning, new, mastered

  List<FlashcardModel> _getCategoryCards(FlashcardState state) {
    switch (_selectedCategory) {
      case 'due':
        return state.dueCards.isNotEmpty ? state.dueCards : state.cards;
      case 'learning':
        return state.learningCards.isNotEmpty ? state.learningCards : state.cards;
      case 'new':
        return state.newCards.isNotEmpty ? state.newCards : state.cards;
      case 'mastered':
        return state.masteredCards.isNotEmpty ? state.masteredCards : state.cards;
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
            // Hero Intro Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bilişsel Öğrenme Oyunları',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'SRS algoritmasını etkilemeyen serbest pratik',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'İkinci dil ediniminde aktif geri çağırma (Active Retrieval), çift kodlama ve bağlam içi pratik kelime kalıcılığını %80\'e kadar artırır.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category Selector
            Text(
              'Kelime Havuzu Seçimi',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('all', 'Tümü (${cardState.cards.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('due', 'Bugün Tekrar (${cardState.dueCards.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('learning', 'Öğrenilen (${cardState.learningCards.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('new', 'Yeni (${cardState.newCards.length})'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('mastered', 'Ustalaşılan (${cardState.masteredCards.length})'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Games Grid / List
            Text(
              'Eğitim Modları & Oyunlar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Mode 1: Custom Study (Free Flashcard Practice)
            _buildGameCard(
              context: context,
              title: '1. Özel Kart Tekrarı (Serbest Mod)',
              subtitle: 'Algoritmadan bağımsız, özelleştirilmiş seans ile kartları çalışın',
              badge: 'Serbest Tekrar',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.style_rounded,
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              minCardsRequired: 1,
              currentCardsCount: currentPool.length,
              onPlay: () {
                showCustomStudyBottomSheet(
                  context,
                  cardState,
                  initialStatus: _selectedCategory,
                );
              },
            ),

            const SizedBox(height: 14),

            // Game 2: Word Match
            _buildGameCard(
              context: context,
              title: '2. Kelime Eşleştirme',
              subtitle: 'İngilizce kelimeler ile Türkçe karşılıklarını eşleştirin',
              badge: 'Çift Kodlama',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.grid_view_rounded,
              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
              minCardsRequired: 3,
              currentCardsCount: currentPool.length,
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordMatchGameScreen(cards: currentPool),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Game 3: Word Scramble
            _buildGameCard(
              context: context,
              title: '3. Harf Sihirbazı (Yazım)',
              subtitle: 'Karışık harflerden doğru İngilizce kelimeyi oluşturun',
              badge: 'İmlasal Bellek',
              badgeColor: const Color(0xFF6366F1),
              icon: Icons.spellcheck_rounded,
              gradientColors: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
              minCardsRequired: 1,
              currentCardsCount: currentPool.length,
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordScrambleGameScreen(cards: currentPool),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Game 4: Speed Quiz
            _buildGameCard(
              context: context,
              title: '4. Hızlı Karar Testi',
              subtitle: '10 saniyelik sürede doğru anlamı bularak kombo serisi yapın',
              badge: 'Hızlı Geri Çağırma',
              badgeColor: const Color(0xFFF59E0B),
              icon: Icons.timer_outlined,
              gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
              minCardsRequired: 4,
              currentCardsCount: currentPool.length,
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeedQuizGameScreen(cards: currentPool),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Game 5: Context Cloze
            _buildGameCard(
              context: context,
              title: '5. Cümle İçi Boşluk Doldurma',
              subtitle: 'Örnek cümledeki boşluğa en uygun kelimeyi yerleştirin',
              badge: 'Bağlamsal Öğrenme',
              badgeColor: const Color(0xFFEC4899),
              icon: Icons.auto_stories_rounded,
              gradientColors: const [Color(0xFFDB2777), Color(0xFFEC4899)],
              minCardsRequired: 2,
              currentCardsCount: currentPool.length,
              onPlay: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContextClozeGameScreen(cards: currentPool),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.colorScheme.primaryContainer,
      onSelected: (_) {
        setState(() {
          _selectedCategory = key;
        });
      },
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required List<Color> gradientColors,
    required int minCardsRequired,
    required int currentCardsCount,
    required VoidCallback onPlay,
  }) {
    final theme = Theme.of(context);
    final bool canPlay = currentCardsCount >= minCardsRequired;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: canPlay ? onPlay : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!canPlay)
                      Text(
                        'En az $minCardsRequired kelime gerekiyor',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: canPlay ? theme.colorScheme.primary : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
