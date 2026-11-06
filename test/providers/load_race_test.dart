import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/models/reading_article_model.dart';
import 'package:learncard_flutter/providers/flashcard_provider.dart';
import 'package:learncard_flutter/providers/reading_provider.dart';
import 'package:learncard_flutter/services/flashcard_store.dart';
import 'package:learncard_flutter/services/reading_store.dart';
import 'package:learncard_flutter/services/supabase_service.dart';
import 'package:learncard_flutter/services/sync/sync_engine.dart';
import 'package:sqlite3/open.dart';

FlashcardModel _card(String id, {String word = 'word'}) => FlashcardModel(
      id: id,
      word: '$word-$id',
      definition: 'def',
      trTranslation: 'tr',
      status: 'new',
      interval: 0,
      repetitions: 0,
      nextReviewDate: '2026-11-07T00:00:00.000Z',
      createdAt: '2026-11-07T00:00:00.000Z',
    );

ReadingArticleModel _article(String id, {String title = 'title'}) => ReadingArticleModel(
      id: id,
      title: title,
      text: 'text $id',
      createdAt: '2026-11-07T00:00:00.000Z',
    );

/// Her `load` çağrısı ayrı bir Completer döner; test hangi sırayla
/// biteceğine karar verir.
class _FakeCardStore extends FlashcardStore {
  final List<Completer<SyncedList<FlashcardModel>>> loads = [];
  bool failWrites = false;

  @override
  Future<SyncedList<FlashcardModel>> load() {
    final c = Completer<SyncedList<FlashcardModel>>();
    loads.add(c);
    return c.future;
  }

  @override
  Future<SyncResult> save(List<FlashcardModel> cards) async {
    if (failWrites) throw StateError('disk full');
    return SyncResult.skipped;
  }

  @override
  Future<SyncResult> delete(String id) async {
    if (failWrites) throw StateError('disk full');
    return SyncResult.skipped;
  }
}

class _FakeReadingStore extends ReadingStore {
  final List<Completer<SyncedList<ReadingArticleModel>>> loads = [];

  @override
  Future<SyncedList<ReadingArticleModel>> load() {
    final c = Completer<SyncedList<ReadingArticleModel>>();
    loads.add(c);
    return c.future;
  }

  @override
  Future<SyncResult> save(List<ReadingArticleModel> articles) async => SyncResult.skipped;

  @override
  Future<SyncResult> delete(String id) async => SyncResult.skipped;
}

SyncedList<T> _result<T>(List<T> items, {String? error}) => (
      items: items,
      sync: error == null ? SyncResult.skipped : SyncResult(errors: [error]),
    );

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so');
        } catch (_) {
          return DynamicLibrary.open('libsqlite3.so.0');
        }
      });
    }
  });

  group('FlashcardNotifier load race', () {
    test('a slower stale load does not overwrite the newer one', () async {
      final store = _FakeCardStore();
      final notifier = FlashcardNotifier(null, false, null, store);

      final first = notifier.loadCards();
      final second = notifier.loadCards();

      store.loads[1].complete(_result([_card('new')]));
      await second;
      store.loads[0].complete(_result([_card('stale')], error: 'old error'));
      await first;

      expect(notifier.state.cards.map((c) => c.id), ['new']);
      expect(notifier.state.syncError, isNull);
      expect(notifier.state.isLoading, isFalse);
      notifier.dispose();
    });

    test('a stale load failure does not set an error over newer data', () async {
      final store = _FakeCardStore();
      final notifier = FlashcardNotifier(null, false, null, store);

      final first = notifier.loadCards();
      final second = notifier.loadCards();
      store.loads[1].complete(_result([_card('a')]));
      await second;
      store.loads[0].completeError(StateError('boom'));
      await first;

      expect(notifier.state.error, isNull);
      expect(notifier.state.cards.map((c) => c.id), ['a']);
      notifier.dispose();
    });

    test('edits made while loading are merged into the loaded snapshot', () async {
      final store = _FakeCardStore();
      final notifier = FlashcardNotifier(
        FlashcardState(cards: [_card('keep'), _card('gone'), _card('edit')]),
        false,
        null,
        store,
      );

      final loading = notifier.loadCards();
      await notifier.addCard(word: 'fresh');
      await notifier.deleteCard('gone');
      await notifier.updateCard(_card('edit').copyWith(trTranslation: 'edited'));

      // Snapshot taken before the edits reached the local DB.
      store.loads[0].complete(_result([_card('keep'), _card('gone'), _card('edit')]));
      await loading;

      final ids = notifier.state.cards.map((c) => c.id).toList();
      expect(ids, containsAll(['keep', 'edit']));
      expect(ids, isNot(contains('gone')));
      expect(notifier.state.cards.where((c) => c.word == 'fresh'), hasLength(1));
      expect(notifier.state.cards.firstWhere((c) => c.id == 'edit').trTranslation, 'edited');
      notifier.dispose();
    });

    test('failed local write rolls back and surfaces an error', () async {
      final store = _FakeCardStore()..failWrites = true;
      final notifier = FlashcardNotifier(FlashcardState(cards: [_card('x')]), false, null, store);

      expect(await notifier.addCard(word: 'fresh'), isFalse);
      expect(notifier.state.cards.map((c) => c.id), ['x']);
      expect(notifier.state.error, FlashcardNotifier.saveFailedMessage);

      await notifier.deleteCard('x');
      expect(notifier.state.cards.map((c) => c.id), ['x']);
      expect(notifier.state.error, FlashcardNotifier.saveFailedMessage);

      await notifier.updateCard(_card('x').copyWith(trTranslation: 'changed'));
      expect(notifier.state.cards.single.trTranslation, 'tr');
      notifier.dispose();
    });
  });

  group('ReadingNotifier load race', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('a slower stale load does not overwrite the newer one', () async {
      final store = _FakeReadingStore();
      final notifier = ReadingNotifier(db, false, store);

      final first = notifier.loadReadings();
      final second = notifier.loadReadings();
      store.loads[1].complete(_result([_article('new')]));
      await second;
      store.loads[0].complete(_result([_article('stale')], error: 'old'));
      await first;

      expect(notifier.state.articles.map((a) => a.id), ['new']);
      expect(notifier.state.syncError, isNull);
      notifier.dispose();
    });

    test('articles saved and selected while loading survive the load', () async {
      final store = _FakeReadingStore();
      final notifier = ReadingNotifier(db, false, store);

      final loading = notifier.loadReadings();
      final saved = await notifier.saveArticle('Mine', 'my text');
      store.loads[0].complete(_result([_article('old')]));
      await loading;

      expect(notifier.state.articles.first.id, saved.id);
      expect(notifier.state.articles.map((a) => a.id), contains('old'));
      expect(notifier.state.selectedArticle?.id, saved.id);
      expect(notifier.state.currentText, 'my text');
      notifier.dispose();
    });
  });
}
