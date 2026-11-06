import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/syncable.dart';
import 'sync_stores.dart';

/// Hata, verilen sütunlardan birinin bulut tablosunda olmadığını söylüyorsa
/// o sütunun adını döner; başka her hatada null.
///
/// PostgREST eksik sütun için `PGRST204` ("Could not find the 'x' column ..."),
/// Postgres ise `42703` ("column x does not exist") döner.
String? missingColumnFromError(Object error, Iterable<String> candidates) {
  if (error is! PostgrestException) return null;
  final message = error.message.toLowerCase();
  final codeSaysMissing = error.code == 'PGRST204' || error.code == '42703';
  final textSaysMissing =
      message.contains('does not exist') || message.contains('could not find');
  if (!codeSaysMissing && !textSaysMissing) return null;
  if (!message.contains('column')) return null;
  for (final column in candidates) {
    if (message.contains(column.toLowerCase())) return column;
  }
  return null;
}

/// [RemoteSyncStore]'un Supabase uygulaması (tek tablo).
///
/// [optionalColumns] bulutta henüz olmayabilecek sütunlardır (ör. migration
/// çalıştırılmadan önce `updated_at`). Yalnız sunucu bu sütunun eksik olduğunu
/// söylerse sütun çıkarılıp yeniden denenir; diğer hatalar olduğu gibi fırlar.
class SupabaseRemoteStore<T extends Syncable> implements RemoteSyncStore<T> {
  final SupabaseClient _client;
  final String table;
  final T Function(Map<String, dynamic>) fromRow;
  final Map<String, dynamic> Function(T) toRow;
  final List<String> optionalColumns;
  final Duration timeout;

  final Set<String> _missingColumns = {};

  SupabaseRemoteStore({
    required SupabaseClient client,
    required this.table,
    required this.fromRow,
    required this.toRow,
    this.optionalColumns = const [],
    this.timeout = const Duration(seconds: 6),
  }) : _client = client;

  @override
  Future<List<T>> fetchAll(String userId) async {
    final rows = await _client
        .from(table)
        .select('*')
        .eq('user_id', userId)
        .timeout(timeout);
    return rows.map(fromRow).toList();
  }

  @override
  Future<void> upsert(List<T> items) async {
    if (items.isEmpty) return;
    while (true) {
      final rows = items.map((item) {
        final row = toRow(item);
        for (final column in _missingColumns) {
          row.remove(column);
        }
        return row;
      }).toList();
      try {
        await _client.from(table).upsert(rows, onConflict: 'id').timeout(timeout);
        return;
      } catch (e) {
        final remaining = optionalColumns.where((c) => !_missingColumns.contains(c));
        final missing = missingColumnFromError(e, remaining);
        if (missing == null) rethrow;
        _missingColumns.add(missing);
      }
    }
  }

  @override
  Future<void> deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.from(table).delete().inFilter('id', ids).timeout(timeout);
  }
}
