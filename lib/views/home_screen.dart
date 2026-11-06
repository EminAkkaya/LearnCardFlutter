import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/flashcard_provider.dart';
import '../providers/reading_provider.dart';
import 'extractor/text_extractor_screen.dart';
import 'flashcard/deck_manager_screen.dart';
import 'flashcard/flashcard_review_screen.dart';
import 'reader/reader_screen.dart';
import 'stats/stats_overview_screen.dart';
import 'widgets/home_navigation_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flashcardProvider.notifier).loadCards();
      ref.read(readingProvider.notifier).loadReadings();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFocusMode = ref.watch(readingProvider).isFocusMode;

    final pages = [
      const FlashcardReviewScreen(),
      const ReaderScreen(),
      const DeckManagerScreen(),
      const TextExtractorScreen(),
      StatsOverviewScreen(onNavigateToTab: _onTabTapped),
    ];

    return PopScope(
      canPop: !isFocusMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isFocusMode) {
          ref.read(readingProvider.notifier).setFocusMode(false);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: (isFocusMode && _currentIndex == 1)
            ? null
            : HomeNavigationBar(
                currentIndex: _currentIndex,
                onTabTapped: _onTabTapped,
              ),
      ),
    );
  }
}
