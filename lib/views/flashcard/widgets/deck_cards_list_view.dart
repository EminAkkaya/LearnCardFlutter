import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/flashcard_model.dart';
import '../../../providers/flashcard_provider.dart';
import '../dialogs/add_edit_card_dialog.dart';
import 'deck_card_list_item.dart';

class DeckCardsListView extends ConsumerWidget {
  final List<FlashcardModel> cards;
  final bool isLoading;

  const DeckCardsListView({
    super.key,
    required this.cards,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);

    if (isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cards.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Hiç kart bulunamadı.',
            style: TextStyle(
              fontSize: 15,
              color: palette.textSecondary,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 84.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final card = cards[index];
            return DeckCardListItem(
              card: card,
              onEdit: () => AddEditCardDialog.show(
                context,
                ref,
                cardToEdit: card,
              ),
              onDelete: () =>
                  ref.read(flashcardProvider.notifier).deleteCard(card.id),
            );
          },
          childCount: cards.length,
        ),
      ),
    );
  }
}
