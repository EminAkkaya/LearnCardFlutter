import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/models/reading_article_model.dart';
import 'package:learncard_flutter/models/syncable.dart';
import 'package:learncard_flutter/services/sync/drift_sync_store.dart';
import 'package:learncard_flutter/services/sync/supabase_remote_store.dart';
import 'package:learncard_flutter/services/sync/sync_engine.dart';
import 'package:learncard_flutter/services/sync/sync_stores.dart';
import 'package:sqlite3/open.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// Bellekte tutulan sahte bulut tablosu.
class FakeRemote<T extends Syncable> implements RemoteSyncStore<T> {
  final Map<String, T> rows = {};
  bool offline = false;
  bool failUpsert = false;
  bool failDelete = false;
  int upsertCalls = 0;
  final List<String> upsertedIds = [];

  void _check() {
    if (offline) throw const SocketException('offline');
  }

  @override
  Future<List<T>> fetchAll(String userId) async {
    _check();
    return rows.values.where((r) => r.userId == userId).toList();
  }

  @override
  Future<void> upsert(List<T> items) async {
    _check();
    upsertCalls++;
    if (failUpsert) throw Exception('upsert rejected');
    for (final item in items) {
      rows[item.id] = item;
      upsertedIds.add(item.id);
    }
  }

  @override
  Future<void> deleteByIds(List<String> ids) async {
    _check();
    if (failDelete) throw Exception('delete rejected');
    for (final id in ids) {
      rows.remove(id);
    }
  }
}

FlashcardModel card(
  String id, {
  String? userId,
  String word = 'word',
  String? updatedAt,
  int repetitions = 0,
  String status = 'new',
}) {
  return FlashcardModel(
    id: id,
    userId: userId,
    word: word,
    repetitions: repetitions,
    status: status,
    nextReviewDate: '2026-11-07',
    createdAt: '2026-11-01T10:00:00.000Z',
    updatedAt: updatedAt,
  );
}

const uid = 'user-1';
const t1 = '2026-11-01T10:00:00.000Z';
const t2 = '2026-11-02T10:00:00.000Z';
const t3 = '2026-11-03T10:00:00.000Z';

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

  late AppDatabase db;
  late FakeRemote<FlashcardModel> remote;
  late LocalSyncStore<FlashcardModel> store;
  late SyncEngine<FlashcardModel> engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    remote = FakeRemote<FlashcardModel>();
    store = flashcardSyncStore(db);
    engine = SyncEngine(
      local: store,
      remote: remote,
      clock: () => DateTime.utc(2026, 11, 7),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<FlashcardModel?> localCard(String id) async {
    final all = await store.recordsOf(uid);
    for (final r in all) {
      if (r.item.id == id) return r.item;
    }
    return null;
  }

  Future<int> dirtyCount() async => (await store.dirtyRecords(uid)).length;

  group('SyncEngine - flashcards', () {
    test('offline edit survives an offline sync and is pushed when back online', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t1);
      await engine.sync(uid);
      expect((await localCard('c1'))!.repetitions, 0);

      // Çevrimdışı SRS tekrarı
      remote.offline = true;
      await db.saveLocalFlashcardEdits([
        card('c1', userId: uid, updatedAt: t2, repetitions: 3, status: 'learning'),
      ]);
      final offlineResult = await engine.sync(uid);
      expect(offlineResult.hasErrors, isTrue);
      expect(offlineResult.pullSucceeded, isFalse);
      expect((await localCard('c1'))!.repetitions, 3);
      expect(await dirtyCount(), 1);

      remote.offline = false;
      final online = await engine.sync(uid);
      expect(online.hasErrors, isFalse);
      expect(online.pushed, 1);
      expect(remote.rows['c1']!.repetitions, 3);
      expect((await localCard('c1'))!.repetitions, 3);
      expect(await dirtyCount(), 0);
    });

    test('pull never overwrites a dirty local row, even if remote is newer', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t3, repetitions: 9);
      remote.failUpsert = true;
      await db.saveLocalFlashcardEdits([card('c1', userId: uid, updatedAt: t2, repetitions: 3)]);

      final result = await engine.sync(uid);
      expect(result.pullSucceeded, isTrue);
      expect(result.failed, 1);
      expect((await localCard('c1'))!.repetitions, 3);
      expect(await dirtyCount(), 1);
    });

    test('guest rows are migrated to the account and pushed; untouched seeds are dropped', () async {
      await db.saveLocalFlashcardEdits([card('guest-1', word: 'pear', updatedAt: t1)]);
      await db.batchUpsertFlashcards([card('seed-1-abc', word: 'serendipity')]);
      await db.batchUpsertFlashcards([card('guest-legacy', word: 'plum')]);
      expect((await db.getAllFlashcards()).length, 3);

      final result = await engine.sync(uid);
      expect(result.migrated, 2);
      expect(result.hasErrors, isFalse);
      expect(remote.rows.keys, unorderedEquals(['guest-1', 'guest-legacy']));
      expect(remote.rows['guest-1']!.userId, uid);
      expect(remote.rows['guest-legacy']!.updatedAt, isNotNull);

      expect(await db.getAllFlashcards(), isEmpty, reason: 'guest view is empty now');
      final mine = await db.getAllFlashcards(userId: uid);
      expect(mine.map((c) => c.id), unorderedEquals(['guest-1', 'guest-legacy']));
      expect(mine.every((c) => c.userId == uid), isTrue);
    });

    test('local delete propagates to remote and is then purged locally', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t1);
      await engine.sync(uid);

      await db.markFlashcardDeleted('c1', t2);
      expect(await db.getAllFlashcards(userId: uid), isEmpty);

      final result = await engine.sync(uid);
      expect(result.remoteDeleted, 1);
      expect(remote.rows, isEmpty);
      expect(await store.recordsOf(uid), isEmpty);
    });

    test('failed remote delete keeps the row soft-deleted and dirty; it does not come back', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t1);
      await engine.sync(uid);

      await db.markFlashcardDeleted('c1', t2);
      remote.failDelete = true;
      final result = await engine.sync(uid);
      expect(result.hasErrors, isTrue);
      expect(await db.getAllFlashcards(userId: uid), isEmpty);
      final records = await store.dirtyRecords(uid);
      expect(records.single.isDeleted, isTrue);

      remote.failDelete = false;
      await engine.sync(uid);
      expect(remote.rows, isEmpty);
      expect(await store.recordsOf(uid), isEmpty);
    });

    test('remote delete removes clean local rows, but only after a successful pull', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t1);
      remote.rows['c2'] = card('c2', userId: uid, updatedAt: t1);
      await engine.sync(uid);
      expect((await db.getAllFlashcards(userId: uid)).length, 2);

      remote.rows.remove('c1');
      remote.offline = true;
      await engine.sync(uid);
      expect((await db.getAllFlashcards(userId: uid)).length, 2);

      remote.offline = false;
      final result = await engine.sync(uid);
      expect(result.localDeleted, 1);
      expect((await db.getAllFlashcards(userId: uid)).map((c) => c.id), ['c2']);
    });

    test('push failure keeps rows dirty and reports the error', () async {
      remote.failUpsert = true;
      await db.saveLocalFlashcardEdits([card('c1', userId: uid, updatedAt: t1)]);

      final result = await engine.push(uid);
      expect(result.failed, 1);
      expect(result.pushed, 0);
      expect(result.errorMessage, contains('upsert rejected'));
      expect(await dirtyCount(), 1);

      remote.failUpsert = false;
      final retry = await engine.push(uid);
      expect(retry.pushed, 1);
      expect(await dirtyCount(), 0);
    });

    test('push only sends dirty rows', () async {
      remote.rows['c1'] = card('c1', userId: uid, updatedAt: t1);
      remote.rows['c2'] = card('c2', userId: uid, updatedAt: t1);
      await engine.sync(uid);
      remote.upsertedIds.clear();

      await db.saveLocalFlashcardEdits([card('c3', userId: uid, updatedAt: t2)]);
      await engine.push(uid);
      expect(remote.upsertedIds, ['c3']);
    });

    test('last write wins between clean local rows and remote rows', () async {
      remote.rows['older'] = card('older', userId: uid, updatedAt: t1, repetitions: 1);
      remote.rows['newer'] = card('newer', userId: uid, updatedAt: t3, repetitions: 1);
      remote.rows['nostamp'] = card('nostamp', userId: uid, repetitions: 1);
      await store.writeClean([
        card('older', userId: uid, updatedAt: t2, repetitions: 5),
        card('newer', userId: uid, updatedAt: t2, repetitions: 5),
        card('nostamp', userId: uid, updatedAt: t2, repetitions: 5),
      ]);

      await engine.sync(uid);
      expect((await localCard('older'))!.repetitions, 5, reason: 'local is newer');
      expect((await localCard('newer'))!.repetitions, 1, reason: 'remote is newer');
      expect((await localCard('nostamp'))!.repetitions, 1,
          reason: 'missing remote updated_at wins over clean rows');
      expect((await localCard('nostamp'))!.updatedAt, kUnknownSyncTime);
    });

    test('legacy rows (pre-sync schema) missing from the cloud are re-uploaded, not deleted', () async {
      await db.batchUpsertFlashcards([card('legacy', userId: uid, word: 'old')]);

      final result = await engine.sync(uid);
      expect(result.localDeleted, 0);
      expect(remote.rows.keys, ['legacy']);
      expect(await localCard('legacy'), isNotNull);
      expect(await dirtyCount(), 0);
    });

    test('remoteWins treats a missing remote timestamp as older than dirty rows', () {
      final remoteCard = card('c', userId: uid);
      expect(
        SyncEngine.remoteWins(LocalRecord(card('c', updatedAt: t1), isDirty: true), remoteCard),
        isFalse,
      );
      expect(SyncEngine.remoteWins(LocalRecord(card('c', updatedAt: t1)), remoteCard), isTrue);
      expect(SyncEngine.remoteWins<FlashcardModel>(null, remoteCard), isTrue);
    });
  });

  group('SyncEngine - reading articles', () {
    test('guest article migrates, pushes, and a remote article is pulled', () async {
      final readingRemote = FakeRemote<ReadingArticleModel>();
      final readingEngine = SyncEngine(local: readingSyncStore(db), remote: readingRemote);
      readingRemote.rows['r-remote'] = ReadingArticleModel(
        id: 'r-remote',
        userId: uid,
        title: 'Remote',
        text: 'from another device',
        createdAt: t1,
        updatedAt: t1,
      );
      await db.saveLocalArticleEdits([
        ReadingArticleModel(id: 'r-guest', title: 'Guest', text: 'x', createdAt: t2, updatedAt: t2),
      ]);

      final result = await readingEngine.sync(uid);
      expect(result.hasErrors, isFalse);
      expect(readingRemote.rows.keys, unorderedEquals(['r-remote', 'r-guest']));
      final mine = await db.getAllReadingArticles(userId: uid);
      expect(mine.map((a) => a.id), unorderedEquals(['r-remote', 'r-guest']));

      await db.markArticleDeleted('r-remote', t3);
      await readingEngine.sync(uid);
      expect(readingRemote.rows.keys, ['r-guest']);
      expect((await db.getAllReadingArticles(userId: uid)).map((a) => a.id), ['r-guest']);
    });
  });

  group('AppDatabase local edits', () {
    test('deleting a guest row removes it immediately', () async {
      await db.saveLocalFlashcardEdits([card('g1', updatedAt: t1)]);
      await db.markFlashcardDeleted('g1', t2);
      expect(await db.getAllFlashcards(), isEmpty);
      final rows = await db.select(db.flashcardEntries).get();
      expect(rows, isEmpty);
    });
  });

  group('missingColumnFromError', () {
    const candidates = ['learning_step', 'updated_at'];

    test('detects PostgREST schema-cache error for a known column', () {
      const e = PostgrestException(
        message: "Could not find the 'learning_step' column of 'flashcards' in the schema cache",
        code: 'PGRST204',
      );
      expect(missingColumnFromError(e, candidates), 'learning_step');
    });

    test('detects Postgres undefined column error', () {
      const e = PostgrestException(
        message: 'column flashcards.updated_at does not exist',
        code: '42703',
      );
      expect(missingColumnFromError(e, candidates), 'updated_at');
    });

    test('ignores other errors', () {
      expect(missingColumnFromError(Exception('timeout'), candidates), isNull);
      const rls = PostgrestException(
        message: 'new row violates row-level security policy for table "flashcards"',
        code: '42501',
      );
      expect(missingColumnFromError(rls, candidates), isNull);
      const otherColumn = PostgrestException(
        message: "Could not find the 'foo' column of 'flashcards' in the schema cache",
        code: 'PGRST204',
      );
      expect(missingColumnFromError(otherColumn, candidates), isNull);
    });
  });
}
