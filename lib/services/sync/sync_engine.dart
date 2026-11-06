import '../../models/syncable.dart';
import 'sync_stores.dart';

/// Bir eşitleme turunun özeti. Hatalar yutulmaz, burada raporlanır.
class SyncResult {
  final int migrated;
  final int pushed;
  final int remoteDeleted;
  final int pulled;
  final int localDeleted;
  final int failed;
  final bool pullSucceeded;
  final List<String> errors;

  const SyncResult({
    this.migrated = 0,
    this.pushed = 0,
    this.remoteDeleted = 0,
    this.pulled = 0,
    this.localDeleted = 0,
    this.failed = 0,
    this.pullSucceeded = false,
    this.errors = const [],
  });

  /// Kullanıcı yok veya bulut kullanılamıyor: yerel veri olduğu gibi kalır.
  static const SyncResult skipped = SyncResult();

  bool get hasErrors => errors.isNotEmpty;
  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');

  @override
  String toString() =>
      'SyncResult(migrated: $migrated, pushed: $pushed, remoteDeleted: $remoteDeleted, '
      'pulled: $pulled, localDeleted: $localDeleted, failed: $failed, '
      'pullSucceeded: $pullSucceeded, errors: $errors)';
}

class _Tally {
  int migrated = 0;
  int pushed = 0;
  int remoteDeleted = 0;
  int pulled = 0;
  int localDeleted = 0;
  int failed = 0;
  bool pullSucceeded = false;
  final List<String> errors = [];

  SyncResult build() => SyncResult(
        migrated: migrated,
        pushed: pushed,
        remoteDeleted: remoteDeleted,
        pulled: pulled,
        localDeleted: localDeleted,
        failed: failed,
        pullSucceeded: pullSucceeded,
        errors: List.unmodifiable(errors),
      );
}

/// Yerel öncelikli (offline-first) eşitleme: misafir verisini hesaba taşır,
/// kirli satırları gönderir, sonra buluttaki satırları son-yazan-kazanır
/// kuralıyla yerele çeker.
class SyncEngine<T extends Syncable> {
  final LocalSyncStore<T> local;
  final RemoteSyncStore<T> remote;
  final DateTime Function() _clock;

  SyncEngine({
    required this.local,
    required this.remote,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  String get _nowIso => _clock().toUtc().toIso8601String();

  /// Tam tur: misafir taşıma → gönder → çek.
  Future<SyncResult> sync(String userId) async {
    final tally = _Tally();
    tally.migrated = await local.claimGuestRecords(userId, _nowIso);
    await _push(userId, tally);
    final resurrected = await _pull(userId, tally);
    if (resurrected > 0) {
      await _push(userId, tally);
    }
    return tally.build();
  }

  /// Yalnız kirli satırları gönderir (yerel bir düzenlemeden sonra).
  Future<SyncResult> push(String userId) async {
    final tally = _Tally();
    await _push(userId, tally);
    return tally.build();
  }

  Future<void> _push(String userId, _Tally tally) async {
    final dirty = await local.dirtyRecords(userId);
    final upserts = [for (final r in dirty) if (!r.isDeleted) r.item];
    final deletes = [for (final r in dirty) if (r.isDeleted) r.item.id];

    if (upserts.isNotEmpty) {
      try {
        await remote.upsert(upserts);
        for (final item in upserts) {
          await local.markClean(item.id, item.updatedAt);
        }
        tally.pushed += upserts.length;
      } catch (e) {
        tally.failed += upserts.length;
        tally.errors.add('push: $e');
      }
    }

    if (deletes.isNotEmpty) {
      try {
        await remote.deleteByIds(deletes);
        await local.purgeDeleted(deletes);
        tally.remoteDeleted += deletes.length;
      } catch (e) {
        tally.failed += deletes.length;
        tally.errors.add('delete: $e');
      }
    }
  }

  /// Çeker ve birleştirir. Bulutta olmayan eski (hiç uzlaştırılmamış) satırlar
  /// silinmek yerine yeniden yüklenmek üzere işaretlenir; sayıları döner.
  Future<int> _pull(String userId, _Tally tally) async {
    final List<T> remoteItems;
    try {
      remoteItems = await remote.fetchAll(userId);
    } catch (e) {
      tally.errors.add('pull: $e');
      return 0;
    }
    tally.pullSucceeded = true;

    return local.transaction(() async {
      final records = await local.recordsOf(userId);
      final byId = {for (final r in records) r.item.id: r};

      final toWrite = <T>[];
      for (final item in remoteItems) {
        if (remoteWins(byId[item.id], item)) toWrite.add(item);
      }

      final remoteIds = {for (final item in remoteItems) item.id};
      final toDelete = <String>[];
      final toResurrect = <String>[];
      for (final r in records) {
        if (r.isDirty || remoteIds.contains(r.item.id)) continue;
        if (r.item.updatedAt == null) {
          toResurrect.add(r.item.id);
        } else {
          toDelete.add(r.item.id);
        }
      }

      await local.writeClean(toWrite);
      await local.deleteClean(toDelete);
      await local.markDirty(toResurrect);
      tally.pulled += toWrite.length;
      tally.localDeleted += toDelete.length;
      return toResurrect.length;
    });
  }

  /// Buluttaki satır yerel satırın üzerine yazılmalı mı?
  ///
  /// Kirli yerel satır her zaman kazanır. Aksi halde yerel satır yalnız
  /// zaman damgası buluttakinden kesin yeniyse kalır; bulutta damga yoksa
  /// (sütun henüz eklenmemiş) bulut kazanır.
  static bool remoteWins<T extends Syncable>(LocalRecord<T>? localRecord, T remoteItem) {
    if (localRecord == null) return true;
    if (localRecord.isDirty) return false;
    final remoteTime = _parse(remoteItem.updatedAt);
    final localTime = _parse(localRecord.item.updatedAt);
    if (remoteTime == null || localTime == null) return true;
    return !localTime.isAfter(remoteTime);
  }

  static DateTime? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}
