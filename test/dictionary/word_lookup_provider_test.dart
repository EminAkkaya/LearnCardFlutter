import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/word_lookup_provider.dart';
import 'package:learncard_flutter/services/definition_picker.dart';
import 'package:learncard_flutter/services/dictionary_service.dart';

import 'dict_fixture.dart';

WordDefinitionResult _details(String w) => w == 'bank'
    ? WordDefinitionResult(
        word: w,
        definition: 'The edge of a river.',
        trTranslation: '',
        phonetic: '',
        partOfSpeech: 'noun',
        audioUrl: '',
        meanings: const [
          ApiMeaning(partOfSpeech: 'noun', definitions: ['The edge of a river.', 'A financial institution.']),
        ],
      )
    : WordDefinitionResult(
        word: w, definition: 'def of $w', trTranslation: '', phonetic: '', partOfSpeech: '', audioUrl: '');

void main() {
  late List<String> onlineCalls;
  late ProviderContainer container;

  setUp(() {
    onlineCalls = [];
    final dict = buildTestDictionary();
    container = ProviderContainer(overrides: [
      offlineDictionaryProvider.overrideWith((ref) async => dict),
      englishDetailsFetcherProvider.overrideWithValue((w) async => _details(w)),
      onlineTranslatorProvider.overrideWithValue((t) async {
        onlineCalls.add(t);
        return t == 'xyzzy' ? DictionaryService.notFoundText : 'çevrimiçi:$t';
      }),
    ]);
    addTearDown(container.dispose);
  });

  Future<WordLookupState> loaded(String word) async {
    final sub = container.listen(wordLookupProvider(word), (_, _) {});
    addTearDown(sub.close);
    while (container.read(wordLookupProvider(word)).isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    return container.read(wordLookupProvider(word));
  }

  test('sözlükte varsa çevrimiçi servise gitmez', () async {
    final s = await loaded('free');
    expect(s.offline, isNotNull);
    expect(s.suggestedTranslation, 'serbest');
    expect(s.details!.definition, 'def of free');
    expect(onlineCalls, isEmpty);
  });

  test('İngilizce tanım, varsayılan çeviriyle aynı anlamdan seçilir', () async {
    final s = await loaded('bank');
    expect(s.suggestedTranslation, 'banka');
    expect(s.details!.definition, 'A financial institution.');
  });

  test('sözlükte yoksa çevrimiçi çeviri otomatik gelir', () async {
    final s = await loaded('serendipity');
    expect(s.offline, isNull);
    expect(s.suggestedTranslation, 'çevrimiçi:serendipity');
    expect(onlineCalls, ['serendipity']);
  });

  test('kullanıcı isterse çevrimiçi çeviri bir kez getirilir', () async {
    await loaded('free');
    final n = container.read(wordLookupProvider('free').notifier);
    await n.fetchOnline();
    await n.fetchOnline();
    final s = container.read(wordLookupProvider('free'));
    expect(s.online, 'çevrimiçi:free');
    expect(s.suggestedTranslation, 'serbest');
    expect(onlineCalls, ['free']);
  });

  test('çeviri bulunamazsa alan boş kalır', () async {
    final s = await loaded('xyzzy');
    expect(s.suggestedTranslation, '');
  });
}
