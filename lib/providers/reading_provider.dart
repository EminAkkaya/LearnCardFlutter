import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/reading_article_model.dart';
import '../services/supabase_service.dart';
import '../services/sync/sync_engine.dart';
import 'auth_provider.dart';

class ReadingState {
  static const String defaultText =
      "Welcome to LearnCard Interactive Reader! Tap on any word in this paragraph to instantly look up its English definition, hear native audio pronunciation, and fetch Turkish translations. You can also add words directly to your flashcard deck with automatic sentence context extraction. Ephemeral moments pass quickly, but serendipity brings great discoveries to resilient learners who stay pragmatic and persistent.";

  final List<ReadingArticleModel> articles;
  final ReadingArticleModel? selectedArticle;
  final bool isLoading;
  final bool isFocusMode;
  final String currentText;
  final String selectedFolder;
  final List<String> customFolders;

  /// Son eşitleme hatası (veri yerelde güvende, sonraki eşitlemede yeniden denenir).
  final String? syncError;

  ReadingState({
    this.articles = const [],
    this.selectedArticle,
    this.isLoading = false,
    this.isFocusMode = false,
    String? currentText,
    this.selectedFolder = 'Tümü',
    this.customFolders = const ['Genel', 'Makaleler', 'Hikayeler', 'Haberler'],
    this.syncError,
  }) : currentText = currentText ?? defaultText;

  List<String> get allFolders {
    final set = <String>{'Genel', ...customFolders};
    for (final article in articles) {
      if (article.folder.trim().isNotEmpty) {
        set.add(article.folder.trim());
      }
    }
    return set.toList();
  }

  ReadingState copyWith({
    List<ReadingArticleModel>? articles,
    Object? selectedArticle = _sentinel,
    bool? isLoading,
    bool? isFocusMode,
    String? currentText,
    String? selectedFolder,
    List<String>? customFolders,
    Object? syncError = _sentinel,
  }) {
    return ReadingState(
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle == _sentinel
          ? this.selectedArticle
          : (selectedArticle as ReadingArticleModel?),
      isLoading: isLoading ?? this.isLoading,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      currentText: currentText ?? this.currentText,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      customFolders: customFolders ?? this.customFolders,
      syncError: syncError == _sentinel ? this.syncError : syncError as String?,
    );
  }
}

const Object _sentinel = Object();

class ReadingNotifier extends StateNotifier<ReadingState> {
  final AppDatabase _db;

  ReadingNotifier([AppDatabase? database, bool autoInit = true])
      : _db = database ?? appDatabase,
        super(ReadingState()) {
    if (autoInit) {
      _initNotifier();
    }
  }

  Future<void> _initNotifier() async {
    await loadPreferences();
    await loadReadings();
  }

  Future<void> loadPreferences() async {
    try {
      final savedFolders = await _db.getStringList('reader_custom_folders');
      if (savedFolders != null) {
        state = state.copyWith(customFolders: savedFolders);
      }
    } catch (_) {}
  }

  Future<void> loadReadings() async {
    state = state.copyWith(isLoading: true);
    try {
      final loaded = await SupabaseService.getSavedReadings();
      final articles = loaded.items;

      ReadingArticleModel? restoredArticle;
      String restoredText = state.currentText;

      try {
        final lastArticleId = await _db.getString('reader_last_article_id');
        final lastCustomText = await _db.getString('reader_last_custom_text');

        if (lastArticleId != null && lastArticleId.isNotEmpty) {
          for (final a in articles) {
            if (a.id == lastArticleId) {
              restoredArticle = a;
              restoredText = a.text;
              break;
            }
          }
        }

        if (restoredArticle == null && lastCustomText != null && lastCustomText.isNotEmpty) {
          restoredText = lastCustomText;
        }
      } catch (_) {}

      state = state.copyWith(
        articles: articles,
        selectedArticle: restoredArticle,
        currentText: restoredText,
        isLoading: false,
        syncError: loaded.sync.errorMessage,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _recordSync(SyncResult result) {
    if (!mounted) return;
    state = state.copyWith(syncError: result.errorMessage);
  }

  void toggleFocusMode() {
    state = state.copyWith(isFocusMode: !state.isFocusMode);
  }

  void setFocusMode(bool isFocus) {
    state = state.copyWith(isFocusMode: isFocus);
  }

  void updateCurrentText(String text) async {
    final trimmed = text.trim();
    state = state.copyWith(currentText: trimmed, selectedArticle: null);
    try {
      await _db.removeKey('reader_last_article_id');
      await _db.setString('reader_last_custom_text', trimmed);
    } catch (_) {}
  }

  void setSelectedFolder(String folder) {
    state = state.copyWith(selectedFolder: folder);
  }

  Future<void> addCustomFolder(String folderName) async {
    final trimmed = folderName.trim();
    if (trimmed.isEmpty) return;
    if (!state.customFolders.contains(trimmed)) {
      final updatedFolders = [...state.customFolders, trimmed];
      state = state.copyWith(customFolders: updatedFolders);
      try {
        await _db.setStringList('reader_custom_folders', updatedFolders);
      } catch (_) {}
    }
  }

  Future<void> deleteCustomFolder(String folderName) async {
    final trimmed = folderName.trim();
    if (trimmed == 'Genel' || trimmed == 'Tümü') return;

    bool stateChanged = false;
    List<ReadingArticleModel> updatedArticles = state.articles;

    final moved = <ReadingArticleModel>[];
    if (state.articles.any((a) => a.folder == trimmed)) {
      updatedArticles = state.articles.map((a) {
        if (a.folder == trimmed) {
          final updated = a.copyWith(folder: 'Genel');
          moved.add(updated);
          return updated;
        }
        return a;
      }).toList();
      stateChanged = true;
    }

    List<String> updatedFolders = state.customFolders;
    if (state.customFolders.contains(trimmed)) {
      updatedFolders = state.customFolders.where((f) => f != trimmed).toList();
      stateChanged = true;
      try {
        await _db.setStringList('reader_custom_folders', updatedFolders);
      } catch (_) {}
    }

    if (stateChanged) {
      state = state.copyWith(
        articles: updatedArticles,
        customFolders: updatedFolders,
      );
    }
    if (moved.isNotEmpty) {
      _recordSync(await SupabaseService.saveReadingArticles(moved));
    }
  }

  void selectArticle(ReadingArticleModel? article) async {
    if (article != null) {
      state = state.copyWith(
        selectedArticle: article,
        currentText: article.text,
      );
      try {
        await _db.setString('reader_last_article_id', article.id);
        await _db.removeKey('reader_last_custom_text');
      } catch (_) {}
    } else {
      state = state.copyWith(selectedArticle: null);
      try {
        await _db.removeKey('reader_last_article_id');
      } catch (_) {}
    }
  }

  Future<ReadingArticleModel> saveArticle(String title, String text, {String folder = 'Genel'}) async {
    final folderName = folder.trim().isEmpty ? 'Genel' : folder.trim();
    final article = ReadingArticleModel(
      id: 'reading_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}',
      title: title.trim().isEmpty ? 'Untitled Article' : title.trim(),
      text: text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      folder: folderName,
    );

    final updated = [article, ...state.articles.where((a) => a.id != article.id)];
    state = state.copyWith(
      articles: updated,
      selectedArticle: article,
      currentText: text.trim(),
    );

    try {
      await _db.setString('reader_last_article_id', article.id);
      await _db.removeKey('reader_last_custom_text');
    } catch (_) {}

    await addCustomFolder(folderName);
    _recordSync(await SupabaseService.saveReadingArticle(article));
    return article;
  }

  Future<void> updateArticle(ReadingArticleModel article) async {
    final updatedArticles = state.articles.map((a) => a.id == article.id ? article : a).toList();
    ReadingArticleModel? selected = state.selectedArticle;
    if (selected?.id == article.id) {
      selected = article;
    }
    state = state.copyWith(articles: updatedArticles, selectedArticle: selected);
    await addCustomFolder(article.folder);
    _recordSync(await SupabaseService.saveReadingArticle(article));
  }

  Future<void> deleteArticle(String id) async {
    final updated = state.articles.where((a) => a.id != id).toList();
    ReadingArticleModel? selected = state.selectedArticle;
    final wasSelected = (selected?.id == id);
    if (wasSelected) {
      selected = null;
    }
    state = state.copyWith(articles: updated, selectedArticle: selected);
    if (wasSelected) {
      try {
        await _db.removeKey('reader_last_article_id');
      } catch (_) {}
    }
    _recordSync(await SupabaseService.deleteReadingArticle(id));
  }

  String get currentTextKey {
    if (state.selectedArticle != null) {
      return 'article_${state.selectedArticle!.id}';
    }
    return 'text_${state.currentText.hashCode}';
  }

  Future<void> savePosition(int paragraphIndex, double offset) async {
    try {
      final key = currentTextKey;
      await _db.setInt('reader_last_para_$key', paragraphIndex);
      await _db.setDouble('reader_last_offset_$key', offset);
    } catch (_) {}
  }

  Future<Map<String, dynamic>> loadPosition({String? customKey}) async {
    try {
      final key = customKey ?? currentTextKey;
      final para = await _db.getInt('reader_last_para_$key') ?? 0;
      final offset = await _db.getDouble('reader_last_offset_$key') ?? 0.0;
      return {'paragraphIndex': para, 'offset': offset};
    } catch (_) {
      return {'paragraphIndex': 0, 'offset': 0.0};
    }
  }
}

final readingProvider = StateNotifierProvider<ReadingNotifier, ReadingState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final notifier = ReadingNotifier(db);
  ref.listen<AppAuthState>(authProvider, (previous, next) {
    final prevUserId = previous?.user?.id;
    final nextUserId = next.user?.id;
    final prevGuest = previous?.isGuestMode;
    final nextGuest = next.isGuestMode;

    if (prevUserId != nextUserId || prevGuest != nextGuest) {
      notifier.loadReadings();
    }
  });
  return notifier;
});
