/// Aynı listeyi yükleyen eşzamanlı çağrıları düzenler: yalnız en son başlayan
/// yükleme durumu yazabilir, yükleme sürerken yapılan yerel düzenlemeler
/// kaydedilir ve gelen (eskimiş olabilecek) anlık görüntünün üzerine uygulanır.
class LoadTracker<T> {
  final String Function(T item) idOf;

  /// Yükleme sırasında eklenen ve görüntüde olmayan öğeler başa mı eklenir.
  final bool addNewFirst;

  int _latest = 0;
  int _settled = 0;
  final Map<String, T?> _edits = {};

  LoadTracker(this.idOf, {this.addNewFirst = false});

  bool get isLoading => _latest != _settled;

  /// Yeni bir yükleme başlatır ve kuşak numarasını döner.
  int begin() => ++_latest;

  /// Bu kuşak hâlâ en son yükleme mi? Değilse sonucu atılmalıdır.
  bool isLatest(int generation) => generation == _latest;

  void recordUpsert(T item) {
    if (isLoading) _edits[idOf(item)] = item;
  }

  void recordDelete(String id) {
    if (isLoading) _edits[id] = null;
  }

  /// En son yüklemenin sonucunu, yükleme sırasında yapılan düzenlemelerle
  /// birleştirir. Yalnız [isLatest] true iken çağrılır.
  List<T> complete(int generation, List<T> loaded) {
    _settled = generation;
    if (_edits.isEmpty) return loaded;

    final merged = <T>[];
    final seen = <String>{};
    for (final item in loaded) {
      final id = idOf(item);
      seen.add(id);
      if (!_edits.containsKey(id)) {
        merged.add(item);
        continue;
      }
      final edited = _edits[id];
      if (edited != null) merged.add(edited);
    }
    final added = <T>[
      for (final entry in _edits.entries)
        if (!seen.contains(entry.key) && entry.value != null) entry.value as T,
    ];
    _edits.clear();
    return addNewFirst ? [...added, ...merged] : [...merged, ...added];
  }

  /// En son yükleme başarısız oldu; mevcut durum korunur.
  void fail(int generation) {
    _settled = generation;
    _edits.clear();
  }
}
