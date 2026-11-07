import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/offline_entry.dart';

/// Uygulamayla gelen EN->TR sözlük (Wiktionary, CC BY-SA 4.0).
///
/// Veri `tool/dictionary/build_en_tr.py` ile üretilir. Tablolar:
/// `entry(word, pos, sense, tr, source)` ve `form(word, lemma)`.
class OfflineDictionary {
  static const String assetPath = 'assets/dictionary/en_tr.sqlite.gz';

  /// Asset değişince artır; eski açılmış kopya yerine yenisi yazılır.
  static const int dataVersion = 1;
  static const int _maxSenses = 8;

  final Database _db;

  OfflineDictionary(this._db);

  /// Asset'i ilk kullanımda uygulama destek klasörüne açar ve salt okunur bağlar.
  static Future<OfflineDictionary> openBundled() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/en_tr_v$dataVersion.sqlite');
    if (!file.existsSync()) {
      final data = await rootBundle.load(assetPath);
      final bytes = gzip.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(file.path);
      _deleteOldVersions(dir);
    }
    return OfflineDictionary(sqlite3.open(file.path, mode: OpenMode.readOnly));
  }

  static void _deleteOldVersions(Directory dir) {
    for (final f in dir.listSync().whereType<File>()) {
      final name = f.uri.pathSegments.last;
      if (name.startsWith('en_tr_v') && name != 'en_tr_v$dataVersion.sqlite') {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
  }

  /// Okuyucudaki dokunulan kelimeyi sözlük anahtarına çevirir.
  static String normalize(String text) {
    final lower = text.toLowerCase().replaceAll('’', "'").trim();
    return lower
        .replaceAll(RegExp(r"^[^a-z0-9]+|[^a-z0-9]+$"), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Kelimeyi ya da kalıbı arar. Sıra: çeviri tablosu (kelime → kök → -ly'siz),
  /// sonra ters çevrilmiş tanımlar. Bulunamazsa null.
  OfflineEntry? lookup(String text) {
    final query = normalize(text);
    if (query.isEmpty) return null;
    final candidates = <String>[query];
    final lemma = _lemmaOf(query);
    if (lemma != null) candidates.add(lemma);
    if (query.length > 4 && query.endsWith('ly')) candidates.add(query.substring(0, query.length - 2));
    if (query.endsWith("'s")) candidates.add(query.substring(0, query.length - 2));

    for (final source in const ['t', 'r']) {
      for (final word in candidates) {
        final senses = _senses(word, source);
        if (senses.isNotEmpty) return OfflineEntry(query: query, lemma: word, senses: senses);
      }
    }
    return null;
  }

  String? _lemmaOf(String word) {
    final rows = _db.select('SELECT lemma FROM form WHERE word = ?', [word]);
    return rows.isEmpty ? null : rows.first['lemma'] as String;
  }

  List<OfflineSense> _senses(String word, String source) {
    final rows = _db.select(
      'SELECT pos, sense, tr FROM entry WHERE word = ? AND source = ? ORDER BY rowid LIMIT ?',
      [word, source, _maxSenses],
    );
    final seen = <String>{};
    final senses = <OfflineSense>[];
    for (final r in rows) {
      final pos = r['pos'] as String;
      final tr = r['tr'] as String;
      // Aynı türde aynı karşılıkları tekrar eden anlamlar ekranda gürültü olur.
      if (tr.isEmpty || !seen.add('$pos|$tr')) continue;
      senses.add(OfflineSense(
        pos: pos,
        sense: r['sense'] as String,
        translations: tr.split(', '),
        isReverse: source == 'r',
      ));
    }
    return senses;
  }

  void dispose() => _db.dispose();
}
