import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_palette.dart';
import '../../providers/flashcard_provider.dart';
import '../games/mini_games_hub_screen.dart';
import 'dialogs/add_edit_card_dialog.dart';
import 'widgets/deck_cards_list_view.dart';
import 'widgets/deck_filter_chips.dart';
import 'widgets/deck_search_bar.dart';

class DeckManagerScreen extends ConsumerStatefulWidget {
  const DeckManagerScreen({super.key});

  @override
  ConsumerState<DeckManagerScreen> createState() => _DeckManagerScreenState();
}

class _DeckManagerScreenState extends ConsumerState<DeckManagerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(flashcardProvider);
    final notifier = ref.read(flashcardProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deste Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.gamepad2, size: 20),
            tooltip: 'Mini Oyunlar & Alıştırmalar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiniGamesHubScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Kartları Yenile',
            onPressed: () => notifier.loadCards(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditCardDialog.show(context, ref),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Yeni Kart'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
              child: Column(
                children: [
                  DeckSearchBar(
                    controller: _searchController,
                    onChanged: notifier.setSearchQuery,
                    onClear: () {
                      _searchController.clear();
                      notifier.setSearchQuery('');
                    },
                  ),
                  const SizedBox(height: 12),
                  DeckFilterChips(
                    cardState: cardState,
                    onSelected: notifier.setFilterStatus,
                  ),
                ],
              ),
            ),
          ),
          DeckCardsListView(
            cards: cardState.filteredCards,
            isLoading: cardState.isLoading,
          ),
        ],
      ),
    );
  }
}
