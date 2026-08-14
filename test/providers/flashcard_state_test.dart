import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';

void main() {
  group('FlashcardState & Filtering Tests', () {
    late FlashcardModel newCard;
    late FlashcardModel learningCardDue;
    late FlashcardModel learningCardFuture;
    late FlashcardModel masteredCard;

    setUp(() {
      final now = DateTime.now();

      newCard = FlashcardModel(
        id: 'c1',
        word: 'ubiquitous',
        definition: 'Present or existing everywhere',
        trTranslation: 'Her yerde bulunan',
        status: 'new',
        interval: 0,
        repetitions: 0,
        learningStep: 0,
        nextReviewDate: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );

      learningCardDue = FlashcardModel(
        id: 'c2',
        word: 'serendipity',
        definition: 'Occurrence of events by chance in a happy way',
        trTranslation: 'Mutlu tesadüf',
        status: 'learning',
        interval: 1,
        repetitions: 1,
        learningStep: 1,
        nextReviewDate: now.subtract(const Duration(hours: 2)).toIso8601String(), // due
        createdAt: now.toIso8601String(),
      );

      learningCardFuture = FlashcardModel(
        id: 'c3',
        word: 'ephemeral',
        definition: 'Lasting for a very short time',
        trTranslation: 'Kısa ömürlü',
        status: 'learning',
        interval: 3,
        repetitions: 2,
        learningStep: 2,
        nextReviewDate: now.add(const Duration(days: 2)).toIso8601String(), // not due
        createdAt: now.toIso8601String(),
      );

      masteredCard = FlashcardModel(
        id: 'c4',
        word: 'resilient',
        definition: 'Able to recover quickly',
        trTranslation: 'Dayanıklı',
        status: 'mastered',
        interval: 30,
        repetitions: 5,
        learningStep: 2,
        nextReviewDate: now.add(const Duration(days: 25)).toIso8601String(),
        createdAt: now.toIso8601String(),
      );
    });

    test('1. Getters separate cards accurately by status and due date', () {
      final state = FlashcardState(
        cards: [newCard, learningCardDue, learningCardFuture, masteredCard],
      );

      expect(state.cards.length, equals(4));
      expect(state.newCards.map((c) => c.id), contains('c1'));
      expect(state.dueCards.map((c) => c.id), containsAll(['c1', 'c2'])); // new card with now date is due + past learning card
      expect(state.learningCards.map((c) => c.id), containsAll(['c2', 'c3']));
      expect(state.masteredCards.map((c) => c.id), contains('c4'));
    });

    test('2. filterStatus accurately isolates target categories in filteredCards', () {
      final allCards = [newCard, learningCardDue, learningCardFuture, masteredCard];

      // Filter: 'all'
      final stateAll = FlashcardState(cards: allCards, filterStatus: 'all');
      expect(stateAll.filteredCards.length, equals(4));

      // Filter: 'new'
      final stateNew = FlashcardState(cards: allCards, filterStatus: 'new');
      expect(stateNew.filteredCards.length, equals(1));
      expect(stateNew.filteredCards.first.word, equals('ubiquitous'));

      // Filter: 'learning'
      final stateLearning = FlashcardState(cards: allCards, filterStatus: 'learning');
      expect(stateLearning.filteredCards.length, equals(2));

      // Filter: 'mastered'
      final stateMastered = FlashcardState(cards: allCards, filterStatus: 'mastered');
      expect(stateMastered.filteredCards.length, equals(1));
      expect(stateMastered.filteredCards.first.word, equals('resilient'));
    });

    test('3. searchQuery matches against English word, Turkish translation, and definition', () {
      final allCards = [newCard, learningCardDue, learningCardFuture, masteredCard];

      // Search by word
      final stateWord = FlashcardState(cards: allCards, searchQuery: 'seren');
      expect(stateWord.filteredCards.length, equals(1));
      expect(stateWord.filteredCards.first.id, equals('c2'));

      // Search by Turkish translation
      final stateTr = FlashcardState(cards: allCards, searchQuery: 'Kısa');
      expect(stateTr.filteredCards.length, equals(1));
      expect(stateTr.filteredCards.first.id, equals('c3'));

      // Search by definition substring
      final stateDef = FlashcardState(cards: allCards, searchQuery: 'everywhere');
      expect(stateDef.filteredCards.length, equals(1));
      expect(stateDef.filteredCards.first.id, equals('c1'));
    });

    test('4. Combining filterStatus and searchQuery narrows down correctly', () {
      final allCards = [newCard, learningCardDue, learningCardFuture, masteredCard];

      // Filter 'learning' + search 'chance' (matches learningCardDue definition)
      final state = FlashcardState(
        cards: allCards,
        filterStatus: 'learning',
        searchQuery: 'chance',
      );

      expect(state.filteredCards.length, equals(1));
      expect(state.filteredCards.first.word, equals('serendipity'));

      // Filter 'mastered' + search 'chance' -> 0 results
      final stateEmpty = FlashcardState(
        cards: allCards,
        filterStatus: 'mastered',
        searchQuery: 'chance',
      );

      expect(stateEmpty.filteredCards, isEmpty);
    });

    test('5. copyWith creates an updated state with immutable safety', () {
      final state = FlashcardState(
        cards: [newCard],
        isLoading: false,
        filterStatus: 'all',
        searchQuery: '',
      );

      final next = state.copyWith(
        isLoading: true,
        searchQuery: 'test',
        filterStatus: 'due',
      );

      expect(next.isLoading, isTrue);
      expect(next.searchQuery, equals('test'));
      expect(next.filterStatus, equals('due'));
      expect(next.cards.length, equals(1));

      expect(state.isLoading, isFalse);
      expect(state.searchQuery, equals(''));
    });
  });
}
