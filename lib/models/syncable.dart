/// Yerel veritabanı ile bulut arasında eşitlenen bir kaydın ortak alanları.
abstract interface class Syncable {
  String get id;
  String? get userId;

  /// Son değişiklik zamanı (ISO-8601 UTC) ya da bilinmiyorsa null.
  String? get updatedAt;
}
