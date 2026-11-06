import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../models/flashcard_model.dart';
import '../../models/reading_article_model.dart';
import '../../models/syncable.dart';
import 'sync_stores.dart';

/// [LocalSyncStore]'un Drift uygulaması. Her iki tablo da aynı eşitleme
/// sütunlarına (`user_id`, `updated_at`, `is_dirty`, `is_deleted`) sahiptir;
/// tabloya özgü kısımlar yapıcıdan verilir.
class DriftSyncStore<T extends Syncable, Tbl extends Table, Row>
    implements LocalSyncStore<T> {
  final AppDatabase _db;
  final TableInfo<Tbl, Row> _table;
  final GeneratedColumn<String> Function(Tbl) _id;
  final GeneratedColumn<String> Function(Tbl) _userId;
  final GeneratedColumn<String> Function(Tbl) _updatedAt;
  final GeneratedColumn<bool> Function(Tbl) _isDirty;
  final GeneratedColumn<bool> Function(Tbl) _isDeleted;
  final LocalRecord<T> Function(Row) _toRecord;
  final Insertable<Row> Function(T item) _toCleanRow;

  /// Misafir taşınırken hesaba aktarılmadan silinecek satırlar (ör. hiç
  /// dokunulmamış örnek kartlar).
  final Expression<bool> Function(Tbl)? _discardOnClaim;

  DriftSyncStore({
    required AppDatabase db,
    required TableInfo<Tbl, Row> table,
    required GeneratedColumn<String> Function(Tbl) id,
    required GeneratedColumn<String> Function(Tbl) userId,
    required GeneratedColumn<String> Function(Tbl) updatedAt,
    required GeneratedColumn<bool> Function(Tbl) isDirty,
    required GeneratedColumn<bool> Function(Tbl) isDeleted,
    required LocalRecord<T> Function(Row) toRecord,
    required Insertable<Row> Function(T item) toCleanRow,
    Expression<bool> Function(Tbl)? discardOnClaim,
  })  : _db = db,
        _table = table,
        _id = id,
        _userId = userId,
        _updatedAt = updatedAt,
        _isDirty = isDirty,
        _isDeleted = isDeleted,
        _toRecord = toRecord,
        _toCleanRow = toCleanRow,
        _discardOnClaim = discardOnClaim;

  Insertable<Row> _raw(Map<GeneratedColumn, Object?> values) {
    return RawValuesInsertable<Row>({
      for (final e in values.entries) e.key.name: Variable(e.value),
    });
  }

  @override
  Future<int> claimGuestRecords(String userId, String now) {
    return _db.transaction(() async {
      final discard = _discardOnClaim;
      if (discard != null) {
        await (_db.delete(_table)
              ..where((t) => _userId(t).isNull() & discard(t)))
            .go();
      }
      // Misafir satırı hiç yüklenmediği için silinmiş olanı bulutta aramaya gerek yok.
      await (_db.delete(_table)
            ..where((t) => _userId(t).isNull() & _isDeleted(t).equals(true)))
          .go();
      final sample = _table.asDslTable;
      await (_db.update(_table)
            ..where((t) => _userId(t).isNull() & _updatedAt(t).isNull()))
          .write(_raw({_updatedAt(sample): now}));
      return (_db.update(_table)..where((t) => _userId(t).isNull())).write(
        _raw({_userId(sample): userId, _isDirty(sample): true}),
      );
    });
  }

  @override
  Future<List<LocalRecord<T>>> dirtyRecords(String userId) async {
    final rows = await (_db.select(_table)
          ..where((t) => _userId(t).equals(userId) & _isDirty(t).equals(true)))
        .get();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<List<LocalRecord<T>>> recordsOf(String userId) async {
    final rows = await (_db.select(_table)
          ..where((t) => _userId(t).equals(userId)))
        .get();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<void> markClean(String id, String? pushedUpdatedAt) async {
    await (_db.update(_table)
          ..where((t) {
            final sameVersion = pushedUpdatedAt == null
                ? _updatedAt(t).isNull()
                : _updatedAt(t).equals(pushedUpdatedAt);
            return _id(t).equals(id) & _isDeleted(t).equals(false) & sameVersion;
          }))
        .write(_raw({_isDirty(_table.asDslTable): false}));
  }

  @override
  Future<void> purgeDeleted(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_db.delete(_table)
          ..where((t) => _id(t).isIn(ids) & _isDeleted(t).equals(true)))
        .go();
  }

  @override
  Future<void> writeClean(List<T> items) async {
    if (items.isEmpty) return;
    await _db.batch((batch) {
      for (final item in items) {
        batch.insert(_table, _toCleanRow(item), mode: InsertMode.insertOrReplace);
      }
    });
  }

  @override
  Future<void> markDirty(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_db.update(_table)..where((t) => _id(t).isIn(ids)))
        .write(_raw({_isDirty(_table.asDslTable): true}));
  }

  @override
  Future<void> deleteClean(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_db.delete(_table)
          ..where((t) => _id(t).isIn(ids) & _isDirty(t).equals(false)))
        .go();
  }

  @override
  Future<R> transaction<R>(Future<R> Function() action) => _db.transaction(action);
}

/// Kart tablosu için yerel eşitleme deposu.
LocalSyncStore<FlashcardModel> flashcardSyncStore(AppDatabase db) {
  return DriftSyncStore<FlashcardModel, $FlashcardEntriesTable, FlashcardEntry>(
    db: db,
    table: db.flashcardEntries,
    id: (t) => t.id,
    userId: (t) => t.userId,
    updatedAt: (t) => t.updatedAt,
    isDirty: (t) => t.isDirty,
    isDeleted: (t) => t.isDeleted,
    toRecord: (row) => LocalRecord(
      db.flashcardFromEntry(row),
      isDirty: row.isDirty,
      isDeleted: row.isDeleted,
    ),
    toCleanRow: (card) => db.flashcardCompanion(
      card.copyWith(updatedAt: card.updatedAt ?? kUnknownSyncTime),
      isDirty: false,
      isDeleted: false,
    ),
    // Hiç dokunulmamış örnek kartlar hesaba taşınmaz; gerekirse hesap için
    // yeniden eklenir.
    discardOnClaim: (t) =>
        t.id.like('seed%') &
        t.isDirty.equals(false) &
        t.repetitions.equals(0) &
        t.status.equals('new'),
  );
}

/// Okuma metinleri tablosu için yerel eşitleme deposu.
LocalSyncStore<ReadingArticleModel> readingSyncStore(AppDatabase db) {
  return DriftSyncStore<ReadingArticleModel, $ReadingArticleEntriesTable,
      ReadingArticleEntry>(
    db: db,
    table: db.readingArticleEntries,
    id: (t) => t.id,
    userId: (t) => t.userId,
    updatedAt: (t) => t.updatedAt,
    isDirty: (t) => t.isDirty,
    isDeleted: (t) => t.isDeleted,
    toRecord: (row) => LocalRecord(
      db.articleFromEntry(row),
      isDirty: row.isDirty,
      isDeleted: row.isDeleted,
    ),
    toCleanRow: (article) => db.articleCompanion(
      article.copyWith(updatedAt: article.updatedAt ?? kUnknownSyncTime),
      isDirty: false,
      isDeleted: false,
    ),
  );
}
