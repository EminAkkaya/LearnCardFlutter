/// Boş listeye örnek veri eklemeyi sıraya alır.
///
/// Aynı anda iki yükleme boş liste görüp ikisi birden örnek eklerse veri
/// iki kat olur. Kontrol ve ekleme tek sırada, kilidin içinde tekrar okunarak yapılır.
class SeedGate {
  Future<void> _tail = Future.value();

  Future<List<T>> fillIfEmpty<T>({
    required Future<List<T>> Function() read,
    required Future<void> Function() seed,
  }) {
    final run = _tail.then((_) async {
      final current = await read();
      if (current.isNotEmpty) return current;
      await seed();
      return read();
    });
    _tail = run.then((_) {}, onError: (_) {});
    return run;
  }
}
