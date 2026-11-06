import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deste Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_esports_rounded),
            tooltip: 'Mini Oyunlar & Alıştırmalar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiniGamesHubScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Kartları Yenile',
            onPressed: () => notifier.loadCards(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditCardDialog.show(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Kart'),
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
