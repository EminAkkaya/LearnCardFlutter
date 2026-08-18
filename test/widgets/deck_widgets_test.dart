import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';
import 'package:learncard_flutter/views/flashcard/widgets/deck_card_list_item.dart';
import 'package:learncard_flutter/views/flashcard/widgets/deck_filter_chips.dart';
import 'package:learncard_flutter/views/flashcard/widgets/deck_search_bar.dart';

void main() {
  group('Deck Widgets Tests', () {
    testWidgets('1. DeckFilterChips renders all category counts and triggers callback on tap', (WidgetTester tester) async {
      final state = FlashcardState(
        cards: [
          FlashcardModel(
            id: '1',
            word: 'serendipity',
            status: 'new',
            nextReviewDate: DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
          FlashcardModel(
            id: '2',
            word: 'resilient',
            status: 'mastered',
            nextReviewDate: DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
        ],
        filterStatus: 'all',
      );

      String? selectedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeckFilterChips(
              cardState: state,
              onSelected: (val) {
                selectedFilter = val;
              },
            ),
          ),
        ),
      );

      // Verify labels with count
      expect(find.text('Tümü (2)'), findsOneWidget);
      expect(find.text('Yeni (1)'), findsOneWidget);
      expect(find.text('Öğrenildi (1)'), findsOneWidget);

      // Tap on 'Yeni (1)' chip
      await tester.tap(find.text('Yeni (1)'));
      await tester.pump();

      expect(selectedFilter, equals('new'));
    });

    testWidgets('2. DeckSearchBar renders input field and triggers callbacks', (WidgetTester tester) async {
      final controller = TextEditingController();
      String changedText = '';
      bool clearTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeckSearchBar(
              controller: controller,
              onChanged: (val) {
                changedText = val;
              },
              onClear: () {
                clearTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Kartlarda ara (Kelime, çeviri)...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'resilient');
      await tester.pump();

      expect(changedText, equals('resilient'));
    });

    testWidgets('3. DeckCardListItem renders word, definition, status and handles menu actions', (WidgetTester tester) async {
      final card = FlashcardModel(
        id: 'card_abc',
        word: 'pragmatic',
        trTranslation: 'Pratik, uygulamacı',
        definition: 'Dealing with things sensibly and realistically',
        phonetic: '/præɡˈmætɪk/',
        status: 'learning',
        interval: 3,
        repetitions: 2,
        nextReviewDate: '2026-08-14',
        createdAt: '2026-08-14',
      );

      bool editTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeckCardListItem(
              card: card,
              onEdit: () {
                editTriggered = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('pragmatic'), findsOneWidget);
      expect(find.text('Pratik, uygulamacı'), findsOneWidget);
      expect(find.text('/præɡˈmætɪk/'), findsOneWidget);
      expect(find.text('LEARNING'), findsOneWidget);
      expect(find.text('Tekrar: 2 | Aralık: 3g'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Düzenle'), findsOneWidget);
      expect(find.text('Sil'), findsOneWidget);

      // Tap 'Düzenle'
      await tester.tap(find.text('Düzenle'));
      await tester.pumpAndSettle();

      expect(editTriggered, isTrue);
    });
  });
}
