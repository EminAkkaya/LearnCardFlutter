/// Çevrimdışı sözlükte bir kelimenin tek anlamı ve Türkçe karşılıkları.
class OfflineSense {
  /// Wiktionary kelime türü kodu (noun, verb, adj ...).
  final String pos;

  /// Anlamın kısa İngilizce açıklaması; boş olabilir.
  final String sense;
  final List<String> translations;

  /// true: Türkçe girdinin İngilizce tanımından ters çevrildi (daha az kesin).
  final bool isReverse;

  const OfflineSense({
    required this.pos,
    required this.sense,
    required this.translations,
    this.isReverse = false,
  });

  /// Kelime türünün Türkçe adı; bilinmiyorsa kodun kendisi.
  String get posLabel => posLabels[pos] ?? pos;

  static const Map<String, String> posLabels = {
    'noun': 'isim',
    'verb': 'fiil',
    'adj': 'sıfat',
    'adv': 'zarf',
    'prep': 'edat',
    'conj': 'bağlaç',
    'pron': 'zamir',
    'intj': 'ünlem',
    'det': 'belirteç',
    'num': 'sayı',
    'phrase': 'ifade',
    'prep_phrase': 'ifade',
    'particle': 'edat',
    'article': 'tanımlık',
  };
}

/// Çevrimdışı sözlük sonucu: aranan kelime, bulunduğu kök biçim ve anlamları.
class OfflineEntry {
  final String query;

  /// Sonucun ait olduğu kelime (ör. "went" için "go").
  final String lemma;
  final List<OfflineSense> senses;

  const OfflineEntry({required this.query, required this.lemma, required this.senses});

  bool get isInflected => lemma != query;

  /// Kart için varsayılan çeviri: ilk anlamın ilk karşılığı.
  String get primaryTranslation => senses.first.translations.first;
}
