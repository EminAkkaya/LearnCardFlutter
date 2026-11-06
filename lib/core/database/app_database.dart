import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard_model.dart';
import '../../models/reading_article_model.dart';

part 'app_database.g.dart';

// -----------------------------------------------------------------------------
// 1. TABLES
// -----------------------------------------------------------------------------

@DataClassName('FlashcardEntry')
class FlashcardEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get word => text()();
  TextColumn get definition => text().withDefault(const Constant(''))();
  TextColumn get trTranslation => text().withDefault(const Constant(''))();
  TextColumn get phonetic => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  TextColumn get exampleSentence => text().withDefault(const Constant(''))();
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('new'))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get learningStep => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  TextColumn get nextReviewDate => text()();
  TextColumn get createdAt => text()();

  // Eşitleme meta verisi (bkz. services/sync/sync_engine.dart).
  TextColumn get updatedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReadingArticleEntry')
class ReadingArticleEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get textContent => text()();
  TextColumn get createdAt => text()();
  TextColumn get folder => text().withDefault(const Constant('Genel'))();

  // Eşitleme meta verisi (bkz. services/sync/sync_engine.dart).
  TextColumn get updatedAt => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppPreferenceEntry')
class AppPreferenceEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// -----------------------------------------------------------------------------
// 2. DATABASE IMPLEMENTATION
// -----------------------------------------------------------------------------

@DriftDatabase(tables: [FlashcardEntries, ReadingArticleEntries, AppPreferenceEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(flashcardEntries, flashcardEntries.userId);
          await m.addColumn(readingArticleEntries, readingArticleEntries.userId);
        }
        if (from < 3) {
          // Mevcut satırlar updatedAt = null ile kalır: eşitleme motoru bunları
          // "hiç uzlaştırılmamış" kabul eder ve bulutta yoksa silmek yerine yükler.
          await m.addColumn(flashcardEntries, flashcardEntries.updatedAt);
          await m.addColumn(flashcardEntries, flashcardEntries.isDirty);
          await m.addColumn(flashcardEntries, flashcardEntries.isDeleted);
          await m.addColumn(readingArticleEntries, readingArticleEntries.updatedAt);
          await m.addColumn(readingArticleEntries, readingArticleEntries.isDirty);
          await m.addColumn(readingArticleEntries, readingArticleEntries.isDeleted);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'learncard_drift_db');
  }

  // ---------------------------------------------------------------------------
  // FLASHCARD OPERATIONS
  // ---------------------------------------------------------------------------

  Future<List<FlashcardModel>> getAllFlashcards({String? userId}) async {
    final query = select(flashcardEntries);
    if (userId != null && userId.isNotEmpty) {
      query.where((t) => t.userId.equals(userId) | t.userId.isNull());
    } else {
      // Misafir modu: yalnız hiçbir hesaba bağlı olmayan yerel veriyi göster.
      query.where((t) => t.userId.isNull());
    }
    query.where((t) => t.isDeleted.equals(false));
    query.orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    final rows = await query.get();
    return rows.map(flashcardFromEntry).toList();
  }

  Future<void> upsertFlashcard(FlashcardModel card) async {
    await into(flashcardEntries).insertOnConflictUpdate(flashcardCompanion(card));
  }

  Future<void> batchUpsertFlashcards(List<FlashcardModel> cards) async {
    await batch((batch) {
      for (final card in cards) {
        batch.insert(
          flashcardEntries,
          flashcardCompanion(card),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Kullanıcının yerel düzenlemesi: satırı yazar ve buluta gönderilmek üzere
  /// kirli işaretler. Çağıran [FlashcardModel.updatedAt] alanını damgalar.
  Future<void> saveLocalFlashcardEdits(List<FlashcardModel> cards) async {
    await batch((batch) {
      for (final card in cards) {
        batch.insert(
          flashcardEntries,
          flashcardCompanion(card, isDirty: true, isDeleted: false),
          onConflict: DoUpdate(
            (_) => flashcardCompanion(card, isDirty: true, isDeleted: false),
          ),
        );
      }
    });
  }

  /// Yumuşak silme: bulutta da silinene kadar satır gizli ve kirli kalır.
  /// Hiçbir hesaba bağlı olmayan (misafir) satır hiç yüklenmediği için
  /// doğrudan silinir.
  Future<void> markFlashcardDeleted(String id, String updatedAt) async {
    await transaction(() async {
      await (delete(flashcardEntries)
            ..where((t) => t.id.equals(id) & t.userId.isNull()))
          .go();
      await (update(flashcardEntries)..where((t) => t.id.equals(id))).write(
        FlashcardEntriesCompanion(
          isDeleted: const Value(true),
          isDirty: const Value(true),
          updatedAt: Value(updatedAt),
        ),
      );
    });
  }

  Future<void> deleteFlashcard(String id) async {
    await (delete(flashcardEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllFlashcards({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await (delete(flashcardEntries)..where((t) => t.userId.equals(userId))).go();
    } else {
      await (delete(flashcardEntries)..where((t) => t.userId.isNull())).go();
    }
  }

  FlashcardModel flashcardFromEntry(FlashcardEntry row) {
    return FlashcardModel(
      id: row.id,
      userId: row.userId,
      word: row.word,
      definition: row.definition,
      trTranslation: row.trTranslation,
      phonetic: row.phonetic,
      partOfSpeech: row.partOfSpeech,
      exampleSentence: row.exampleSentence,
      audioUrl: row.audioUrl,
      status: row.status,
      interval: row.interval,
      repetitions: row.repetitions,
      learningStep: row.learningStep,
      easeFactor: row.easeFactor,
      nextReviewDate: row.nextReviewDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Satırın tamamını yazar. [isDirty]/[isDeleted] verilmezse mevcut değerler
  /// (ya da yeni satırda varsayılanlar) korunur.
  FlashcardEntriesCompanion flashcardCompanion(
    FlashcardModel card, {
    bool? isDirty,
    bool? isDeleted,
  }) {
    return FlashcardEntriesCompanion(
      id: Value(card.id),
      userId: Value(card.userId),
      word: Value(card.word),
      definition: Value(card.definition),
      trTranslation: Value(card.trTranslation),
      phonetic: Value(card.phonetic),
      partOfSpeech: Value(card.partOfSpeech),
      exampleSentence: Value(card.exampleSentence),
      audioUrl: Value(card.audioUrl),
      status: Value(card.status),
      interval: Value(card.interval),
      repetitions: Value(card.repetitions),
      learningStep: Value(card.learningStep),
      easeFactor: Value(card.easeFactor),
      nextReviewDate: Value(card.nextReviewDate),
      createdAt: Value(card.createdAt),
      updatedAt: Value(card.updatedAt),
      isDirty: isDirty == null ? const Value.absent() : Value(isDirty),
      isDeleted: isDeleted == null ? const Value.absent() : Value(isDeleted),
    );
  }

  // ---------------------------------------------------------------------------
  // READING ARTICLE OPERATIONS
  // ---------------------------------------------------------------------------

  Future<List<ReadingArticleModel>> getAllReadingArticles({String? userId}) async {
    final query = select(readingArticleEntries);
    if (userId != null && userId.isNotEmpty) {
      query.where((t) => t.userId.equals(userId) | t.userId.isNull());
    } else {
      // Misafir modu: yalnız hiçbir hesaba bağlı olmayan yerel veriyi göster.
      query.where((t) => t.userId.isNull());
    }
    query.where((t) => t.isDeleted.equals(false));
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(articleFromEntry).toList();
  }

  Future<void> upsertReadingArticle(ReadingArticleModel article) async {
    await into(readingArticleEntries).insertOnConflictUpdate(articleCompanion(article));
  }

  Future<void> batchUpsertReadingArticles(List<ReadingArticleModel> articles) async {
    await batch((batch) {
      for (final article in articles) {
        batch.insert(
          readingArticleEntries,
          articleCompanion(article),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Bkz. [saveLocalFlashcardEdits].
  Future<void> saveLocalArticleEdits(List<ReadingArticleModel> articles) async {
    await batch((batch) {
      for (final article in articles) {
        batch.insert(
          readingArticleEntries,
          articleCompanion(article, isDirty: true, isDeleted: false),
          onConflict: DoUpdate(
            (_) => articleCompanion(article, isDirty: true, isDeleted: false),
          ),
        );
      }
    });
  }

  /// Bkz. [markFlashcardDeleted].
  Future<void> markArticleDeleted(String id, String updatedAt) async {
    await transaction(() async {
      await (delete(readingArticleEntries)
            ..where((t) => t.id.equals(id) & t.userId.isNull()))
          .go();
      await (update(readingArticleEntries)..where((t) => t.id.equals(id))).write(
        ReadingArticleEntriesCompanion(
          isDeleted: const Value(true),
          isDirty: const Value(true),
          updatedAt: Value(updatedAt),
        ),
      );
    });
  }

  Future<void> deleteReadingArticle(String id) async {
    await (delete(readingArticleEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllReadingArticles({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await (delete(readingArticleEntries)..where((t) => t.userId.equals(userId))).go();
    } else {
      await (delete(readingArticleEntries)..where((t) => t.userId.isNull())).go();
    }
  }

  ReadingArticleModel articleFromEntry(ReadingArticleEntry row) {
    return ReadingArticleModel(
      id: row.id,
      userId: row.userId,
      title: row.title,
      text: row.textContent,
      createdAt: row.createdAt,
      folder: row.folder,
      updatedAt: row.updatedAt,
    );
  }

  ReadingArticleEntriesCompanion articleCompanion(
    ReadingArticleModel article, {
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ReadingArticleEntriesCompanion(
      id: Value(article.id),
      userId: Value(article.userId),
      title: Value(article.title),
      textContent: Value(article.text),
      createdAt: Value(article.createdAt),
      folder: Value(article.folder),
      updatedAt: Value(article.updatedAt),
      isDirty: isDirty == null ? const Value.absent() : Value(isDirty),
      isDeleted: isDeleted == null ? const Value.absent() : Value(isDeleted),
    );
  }

  // ---------------------------------------------------------------------------
  // APP PREFERENCES KEY-VALUE STORE (SHARED_PREFERENCES REPLACEMENT)
  // ---------------------------------------------------------------------------

  Future<String?> getString(String key) async {
    final row = await (select(appPreferenceEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String value) async {
    await into(appPreferenceEntries).insertOnConflictUpdate(
      AppPreferenceEntriesCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  Future<int?> getInt(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return int.tryParse(str);
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  Future<double?> getDouble(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return double.tryParse(str);
  }

  Future<void> setDouble(String key, double value) async {
    await setString(key, value.toString());
  }

  Future<bool?> getBool(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return str.toLowerCase() == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  Future<List<String>?> getStringList(String key) async {
    final str = await getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    final encoded = jsonEncode(value);
    await setString(key, encoded);
  }

  Future<void> removeKey(String key) async {
    await (delete(appPreferenceEntries)..where((t) => t.key.equals(key))).go();
  }
}

// -----------------------------------------------------------------------------
// 3. SINGLETON & PROVIDER
// -----------------------------------------------------------------------------

final appDatabase = AppDatabase();

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return appDatabase;
});
