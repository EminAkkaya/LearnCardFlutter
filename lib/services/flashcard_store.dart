import '../models/flashcard_model.dart';
import 'supabase_service.dart';
import 'sync/sync_engine.dart';

/// Kart sağlayıcısının kalıcılık kapısı (yerel DB + eşitleme). Testlerde
/// sahte bir alt sınıfla değiştirilir.
class FlashcardStore {
  const FlashcardStore();

  Future<SyncedList<FlashcardModel>> load() => SupabaseService.getSavedCards();

  Future<SyncResult> save(List<FlashcardModel> cards) =>
      SupabaseService.saveCardsToSupabase(cards);

  Future<SyncResult> delete(String id) => SupabaseService.deleteCard(id);
}
