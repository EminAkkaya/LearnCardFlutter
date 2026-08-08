import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import 'widgets/add_edit_card_dialog.dart';
import 'widgets/custom_study_banner.dart';
import 'widgets/custom_study_bottom_sheet.dart';
import 'widgets/deck_card_list_item.dart';
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
    final theme = Theme.of(context);
    final cardState = ref.watch(flashcardProvider);
    final cards = cardState.filteredCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deste Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(flashcardProvider.notifier).loadCards(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditCardDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Kart'),
      ),
      body: Column(
        children: [
          CustomStudyBanner(
            onStartPressed: () => showCustomStudyBottomSheet(context, cardState),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DeckSearchBar(
                  controller: _searchController,
                  onChanged: (val) =>
                      ref.read(flashcardProvider.notifier).setSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    ref.read(flashcardProvider.notifier).setSearchQuery('');
                  },
                ),
                const SizedBox(height: 12),
                DeckFilterChips(
                  cardState: cardState,
                  onSelected: (status) => ref
                      .read(flashcardProvider.notifier)
                      .setFilterStatus(status),
                ),
              ],
            ),
          ),
          Expanded(
            child: cardState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cards.isEmpty
                ? Center(
                    child: Text(
                      'Hiç kart bulunamadı.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return DeckCardListItem(
                        card: card,
                        onEdit: () => showAddEditCardDialog(
                          context,
                          ref,
                          cardToEdit: card,
                        ),
                        onDelete: () => ref
                            .read(flashcardProvider.notifier)
                            .deleteCard(card.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
