import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/offline_entry.dart';
import 'package:learncard_flutter/services/definition_picker.dart';
import 'package:learncard_flutter/services/dictionary_service.dart';

// dictionaryapi.dev'in 2026-11-13 cevaplarından kısaltılmış örnekler.
const _waves = [
  ApiMeaning(partOfSpeech: 'verb', definitions: [
    'To relinquish (a right etc.); to give up claim to; to forego.',
    'To move from side to side; to sway.',
  ]),
  ApiMeaning(partOfSpeech: 'noun', definitions: [
    'A moving disturbance in the level of a body of liquid; an undulation.',
  ]),
];
const _brief = [
  ApiMeaning(partOfSpeech: 'noun', definitions: ['A writ summoning one to answer to any action.']),
  ApiMeaning(partOfSpeech: 'adjective', definitions: ['Of short duration; happening quickly.']),
];
const _stairs = [
  ApiMeaning(partOfSpeech: 'noun', definitions: ['A single step in a staircase.']),
  ApiMeaning(partOfSpeech: 'noun', definitions: ['A contiguous set of steps connecting two floors.']),
];

void main() {
  test('kelime türü tutan anlam seçilir (waves → dalga, waive değil)', () {
    final p = pickDefinition(_waves, pos: 'noun', gloss: 'moving disturbance, undulation')!;
    expect(p.partOfSpeech, 'noun');
    expect(p.definition, startsWith('A moving disturbance'));
  });

  test('sözlük kısaltması API adına çevrilir (adj → adjective)', () {
    final p = pickDefinition(_brief, pos: 'adj', gloss: 'concise')!;
    expect(p.partOfSpeech, 'adjective');
    expect(p.definition, 'Of short duration; happening quickly.');
  });

  test('aynı türde açıklamayla en çok örtüşen tanım seçilir', () {
    final p = pickDefinition(_stairs, pos: 'noun', gloss: 'contiguous set of steps')!;
    expect(p.definition, startsWith('A contiguous set of steps'));
  });

  test('ipucu yoksa ya da tür tutmazsa API sırası korunur', () {
    expect(pickDefinition(_waves)!.definition, startsWith('To relinquish'));
    expect(pickDefinition(_brief, pos: 'verb')!.definition, startsWith('A writ'));
  });

  test('boş anlam listesi null döner', () {
    expect(pickDefinition(const []), isNull);
    expect(pickDefinition(const [ApiMeaning(partOfSpeech: 'noun', definitions: [''])]), isNull);
  });

  test('forSense tanımı ve türü değiştirir, diğer alanları korur', () {
    final r = WordDefinitionResult(
      word: 'waves',
      definition: 'To relinquish (a right etc.); to give up claim to; to forego.',
      trTranslation: '',
      phonetic: '/weɪvz/',
      partOfSpeech: 'verb',
      audioUrl: 'a.mp3',
      meanings: _waves,
    );
    const sense = OfflineSense(pos: 'noun', sense: 'moving disturbance, undulation', translations: ['dalga']);
    final s = r.forSense(sense);
    expect(s.partOfSpeech, 'noun');
    expect(s.definition, startsWith('A moving disturbance'));
    expect(s.phonetic, '/weɪvz/');
    expect(s.audioUrl, 'a.mp3');
    expect(r.forSense(null), same(r));
  });
}
