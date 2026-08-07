import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_provider.dart';
import 'extractor/text_extractor_screen.dart';
import 'flashcard/deck_manager_screen.dart';
import 'flashcard/flashcard_review_screen.dart';
import 'reader/reader_screen.dart';
import 'stats/stats_overview_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFocusMode = ref.watch(readingProvider).isFocusMode;

    final List<Widget> pages = [
      const FlashcardReviewScreen(),
      const ReaderScreen(),
      const DeckManagerScreen(),
      const TextExtractorScreen(),
      StatsOverviewScreen(onNavigateToTab: _onTabTapped),
    ];

    return PopScope(
      canPop: !isFocusMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isFocusMode) {
          ref.read(readingProvider.notifier).setFocusMode(false);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: (isFocusMode && _currentIndex == 1)
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabTapped,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.style_outlined),
                    selectedIcon: Icon(Icons.style_rounded),
                    label: 'Tekrar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: 'Okuyucu',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2_rounded),
                    label: 'Deste',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.manage_search_outlined),
                    selectedIcon: Icon(Icons.manage_search_rounded),
                    label: 'Çıkarıcı',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: 'İstatistik',
                  ),
                ],
              ),
      ),
    );
  }
}
