import '../../models/syncable.dart';

/// Buluttan gelen ama `updated_at` değeri olmayan satırlar yerelde bu değerle
/// saklanır: "eşitlendi, zamanı bilinmiyor". Yerelde `updatedAt == null` ise
/// satır yeni şemadan önce yazılmış ve hiç uzlaştırılmamış demektir.
const String kUnknownSyncTime = '1970-01-01T00:00:00.000Z';

/// Yerel bir kayıt ve eşitleme bayrakları.
class LocalRecord<T extends Syncable> {
  final T item;
  final bool isDirty;
  final bool isDeleted;

  const LocalRecord(this.item, {this.isDirty = false, this.isDeleted = false});
}

/// Eşitleme motorunun yerel veritabanından beklediği işlemler.
abstract class LocalSyncStore<T extends Syncable> {
  /// Hiçbir hesaba bağlı olmayan (misafir) satırları [userId]'ye bağlar ve
  /// kirli işaretler. Bağlanan satır sayısını döner.
  Future<int> claimGuestRecords(String userId, String now);

  /// [userId]'ye ait kirli satırlar (silinmiş olanlar dahil).
  Future<List<LocalRecord<T>>> dirtyRecords(String userId);

  /// [userId]'ye ait tüm satırlar (silinmiş olanlar dahil).
  Future<List<LocalRecord<T>>> recordsOf(String userId);

  /// Satır gönderildikten sonra değişmediyse kirli bayrağını temizler.
  Future<void> markClean(String id, String? pushedUpdatedAt);

  /// Bulutta silinmesi onaylanan yumuşak silinmiş satırları kalıcı siler.
  Future<void> purgeDeleted(List<String> ids);

  /// Buluttan gelen satırları temiz olarak yazar; `updatedAt` yoksa
  /// [kUnknownSyncTime] saklar.
  Future<void> writeClean(List<T> items);

  /// Satırları yeniden yüklenmek üzere kirli işaretler.
  Future<void> markDirty(List<String> ids);

  /// Kirli olmayan satırları kalıcı siler.
  Future<void> deleteClean(List<String> ids);

  Future<R> transaction<R>(Future<R> Function() action);
}

/// Eşitleme motorunun buluttan beklediği işlemler. Hatalar fırlatılır.
abstract class RemoteSyncStore<T extends Syncable> {
  Future<List<T>> fetchAll(String userId);
  Future<void> upsert(List<T> items);
  Future<void> deleteByIds(List<String> ids);
}
