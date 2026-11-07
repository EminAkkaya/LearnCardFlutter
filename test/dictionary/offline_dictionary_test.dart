import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/services/offline_dictionary.dart';
import 'package:sqlite3/sqlite3.dart';

import 'dict_fixture.dart';

void main() {
  late OfflineDictionary dict;
  setUp(() => dict = buildTestDictionary());
  tearDown(() => dict.dispose());

  test('birden çok anlamı türüyle döndürür', () {
    final e = dict.lookup('free')!;
    expect(e.senses.map((s) => s.translations.first), ['serbest', 'özgür', 'bedava']);
    expect(e.senses.last.posLabel, 'zarf');
    expect(e.primaryTranslation, 'serbest');
  });

  test('aynı karşılığı tekrarlayan anlamları birleştirir', () {
    expect(dict.lookup('bank')!.senses, hasLength(1));
  });

  test('noktalama ve büyük harf temizlenir, kalıplar bulunur', () {
    expect(dict.lookup('"Free,"')!.lemma, 'free');
    expect(dict.lookup('Give  up!')!.primaryTranslation, 'pes etmek');
  });

  test('çekimli biçim köke, -ly sıfata gider', () {
    final went = dict.lookup('went')!;
    expect(went.lemma, 'go');
    expect(went.isInflected, isTrue);
    expect(dict.lookup('deeply')!.primaryTranslation, 'derin');
  });

  test('çeviri tablosu ters veriden önce gelir', () {
    final books = dict.lookup('books')!;
    expect(books.lemma, 'book');
    expect(books.senses.single.translations, ['kitap', 'betik']);
    expect(books.senses.single.isReverse, isFalse);
    expect(dict.lookup('achieve')!.senses.single.isReverse, isTrue);
  });

  test('bulunamayan ve boş sorgu null döner', () {
    expect(dict.lookup('serendipity'), isNull);
    expect(dict.lookup('  ...  '), isNull);
  });

  test('paketlenen asset beklenen şemayı ve yaygın kelimeleri içerir', () {
    useSystemSqlite();
    final file = File(OfflineDictionary.assetPath);
    expect(file.existsSync(), isTrue);
    final tmp = File('${Directory.systemTemp.createTempSync('dict').path}/d.sqlite')
      ..writeAsBytesSync(gzip.decode(file.readAsBytesSync()));
    final real = OfflineDictionary(sqlite3.open(tmp.path, mode: OpenMode.readOnly));
    addTearDown(real.dispose);
    for (final w in ['water', 'children', 'took', 'look forward to', 'environment']) {
      expect(real.lookup(w), isNotNull, reason: w);
    }
    expect(real.lookup('water')!.primaryTranslation, 'su');
  });
}
