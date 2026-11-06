import '../models/reading_article_model.dart';
import 'supabase_service.dart';
import 'sync/sync_engine.dart';

/// Okuma sağlayıcısının kalıcılık kapısı (yerel DB + eşitleme). Testlerde
/// sahte bir alt sınıfla değiştirilir.
class ReadingStore {
  const ReadingStore();

  Future<SyncedList<ReadingArticleModel>> load() => SupabaseService.getSavedReadings();

  Future<SyncResult> save(List<ReadingArticleModel> articles) =>
      SupabaseService.saveReadingArticles(articles);

  Future<SyncResult> delete(String id) => SupabaseService.deleteReadingArticle(id);
}
