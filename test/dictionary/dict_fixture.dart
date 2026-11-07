import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:learncard_flutter/services/offline_dictionary.dart';

/// Gerçek asset şemasıyla küçük, bellek içi bir sözlük.
OfflineDictionary buildTestDictionary() {
  useSystemSqlite();
  final db = sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE entry (word TEXT NOT NULL, pos TEXT NOT NULL, sense TEXT NOT NULL, tr TEXT NOT NULL, source TEXT NOT NULL);
    CREATE TABLE form (word TEXT PRIMARY KEY, lemma TEXT NOT NULL) WITHOUT ROWID;
  ''');
  final ins = db.prepare('INSERT INTO entry VALUES (?,?,?,?,?)');
  for (final r in const [
    ['free', 'adj', 'unconstrained', 'serbest', 't'],
    ['free', 'adj', 'not imprisoned', 'özgür', 't'],
    ['free', 'adv', 'without needing to pay', 'bedava', 't'],
    ['bank', 'noun', 'institution', 'banka', 't'],
    ['bank', 'noun', 'branch office', 'banka', 't'],
    ['go', 'verb', 'to move', 'gitmek', 't'],
    ['deep', 'adj', 'extending far down', 'derin', 't'],
    ['give up', 'verb', 'admit defeat', 'pes etmek', 't'],
    ['achieve', 'verb', 'to attain, achieve', 'ermek', 'r'],
    ['books', 'noun', 'inventory; books', 'defter', 'r'],
    ['book', 'noun', 'collection of sheets', 'kitap, betik', 't'],
  ]) {
    ins.execute(r);
  }
  ins.dispose();
  db.execute("INSERT INTO form VALUES ('went', 'go'), ('books', 'book')");
  return OfflineDictionary(db);
}

/// Linux test ortamında sistemdeki libsqlite3'ü kullan (diğer DB testleriyle aynı).
void useSystemSqlite() {
  if (!Platform.isLinux) return;
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open('libsqlite3.so');
    } catch (_) {
      return DynamicLibrary.open('libsqlite3.so.0');
    }
  });
}
