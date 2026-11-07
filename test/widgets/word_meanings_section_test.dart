import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/offline_entry.dart';
import 'package:learncard_flutter/views/reader/widgets/word_meanings_section.dart';

void main() {
  const entry = OfflineEntry(query: 'went', lemma: 'go', senses: [
    OfflineSense(pos: 'verb', sense: 'to move', translations: ['gitmek', 'yürümek']),
  ]);

  Future<void> pump(WidgetTester t, {String? online, required List<String> picked, required List<int> fetched}) {
    return t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WordMeaningsSection(
          entry: entry,
          selected: 'gitmek',
          online: online,
          isOnlineLoading: false,
          onPick: picked.add,
          onFetchOnline: () => fetched.add(1),
        ),
      ),
    ));
  }

  testWidgets('anlamlar, kök ve kaynak görünür; karşılık seçilebilir', (t) async {
    final picked = <String>[], fetched = <int>[];
    await pump(t, picked: picked, fetched: fetched);
    expect(find.text('fiil'), findsNothing); // tür etiketi TextSpan içinde
    expect(find.textContaining('fiil'), findsOneWidget);
    expect(find.text('→ go'), findsOneWidget);
    expect(find.textContaining('Wiktionary'), findsOneWidget);
    await t.tap(find.text('yürümek'));
    expect(picked, ['yürümek']);
    await t.tap(find.text('Çevrimiçi çeviriyi de göster'));
    expect(fetched, [1]);
  });

  testWidgets('çevrimiçi sonuç seçilebilir çip olarak görünür', (t) async {
    final picked = <String>[], fetched = <int>[];
    await pump(t, online: 'gitti', picked: picked, fetched: fetched);
    expect(find.text('Çevrimiçi çeviriyi de göster'), findsNothing);
    await t.tap(find.text('gitti'));
    expect(picked, ['gitti']);
  });
}
