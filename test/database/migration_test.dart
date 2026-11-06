import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:sqlite3/open.dart';

/// Şema v2 (eşitleme sütunlarından önce) tabloları.
const _v2Schema = [
  '''CREATE TABLE flashcard_entries (
    id TEXT NOT NULL PRIMARY KEY,
    user_id TEXT NULL,
    word TEXT NOT NULL,
    definition TEXT NOT NULL DEFAULT '',
    tr_translation TEXT NOT NULL DEFAULT '',
    phonetic TEXT NOT NULL DEFAULT '',
    part_of_speech TEXT NOT NULL DEFAULT '',
    example_sentence TEXT NOT NULL DEFAULT '',
    audio_url TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'new',
    interval INTEGER NOT NULL DEFAULT 0,
    repetitions INTEGER NOT NULL DEFAULT 0,
    learning_step INTEGER NOT NULL DEFAULT 0,
    ease_factor REAL NOT NULL DEFAULT 2.5,
    next_review_date TEXT NOT NULL,
    created_at TEXT NOT NULL
  )''',
  '''CREATE TABLE reading_article_entries (
    id TEXT NOT NULL PRIMARY KEY,
    user_id TEXT NULL,
    title TEXT NOT NULL,
    text_content TEXT NOT NULL,
    created_at TEXT NOT NULL,
    folder TEXT NOT NULL DEFAULT 'Genel'
  )''',
  '''CREATE TABLE app_preference_entries (
    "key" TEXT NOT NULL PRIMARY KEY,
    value TEXT NULL
  )''',
  "INSERT INTO flashcard_entries (id, user_id, word, next_review_date, created_at) "
      "VALUES ('c1', 'u1', 'apple', '2026-11-07', '2026-11-01')",
  "INSERT INTO reading_article_entries (id, title, text_content, created_at) "
      "VALUES ('r1', 'Title', 'Body', '2026-11-01')",
  'PRAGMA user_version = 2',
];

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

  test('v2 database upgrades to v3 keeping rows and adding sync columns', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      for (final sql in _v2Schema) {
        raw.execute(sql);
      }
    }));
    addTearDown(db.close);

    final cards = await db.getAllFlashcards(userId: 'u1');
    expect(cards.map((c) => c.id), ['c1']);
    expect(cards.single.updatedAt, isNull);

    final rows = await db.select(db.flashcardEntries).get();
    expect(rows.single.isDirty, isFalse);
    expect(rows.single.isDeleted, isFalse);

    final articles = await db.getAllReadingArticles();
    expect(articles.map((a) => a.id), ['r1']);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 3);
  });
}
