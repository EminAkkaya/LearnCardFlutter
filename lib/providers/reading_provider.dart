import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/app_database.dart';
import '../models/reading_article_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

enum ReaderThemeMode {
  matteDark, // Mat Siyah
  oledBlack, // OLED Siyah (#000000)
  papyrus,   // Papirüs (Açık Sepya)
  darkSepia, // Gece Papirüsü (Karanlık Sepya)
}

class ReaderThemeColors {
  final Color background;
  final Color defaultText;
  final Color surface;
  final Color newWordColor;
  final Color learningWordColor;
  final Color masteredWordColor;
  final Color unaddedWordColor;
  final String label;

  const ReaderThemeColors({
    required this.background,
    required this.defaultText,
    required this.surface,
    required this.newWordColor,
    required this.learningWordColor,
    required this.masteredWordColor,
    required this.unaddedWordColor,
    required this.label,
  });

  static const matteDark = ReaderThemeColors(
    background: Color(0xFF0F172A),
    defaultText: Colors.white,
    surface: Color(0xFF1E293B),
    newWordColor: Color(0xFFEF4444),       // Kırmızı (Öğrenilmemiş / Yeni)
    learningWordColor: Color(0xFFFBBF24),  // Amber/Orange
    masteredWordColor: Color(0xFF34D399),  // Emerald/Green
    unaddedWordColor: Colors.white,
    label: 'Mat Siyah',
  );

  static const oledBlack = ReaderThemeColors(
    background: Color(0xFF000000),
    defaultText: Colors.white,
    surface: Color(0xFF121212),
    newWordColor: Color(0xFFEF4444),       // Kırmızı (Öğrenilmemiş / Yeni)
    learningWordColor: Color(0xFFFBBF24),
    masteredWordColor: Color(0xFF34D399),
    unaddedWordColor: Colors.white,
    label: 'OLED Siyah',
  );

  static const papyrus = ReaderThemeColors(
    background: Color(0xFFFBF0D9),
    defaultText: Color(0xFF2C221E),
    surface: Color(0xFFF3E4C7),
    newWordColor: Color(0xFFDC2626),       // Koyu Kırmızı (Öğrenilmemiş / Yeni)
    learningWordColor: Color(0xFFD97706),  // Deep Amber
    masteredWordColor: Color(0xFF059669),  // Deep Emerald
    unaddedWordColor: Color(0xFF2C221E),   // Dark Ink
    label: 'Papirüs',
  );

  static const darkSepia = ReaderThemeColors(
    background: Color(0xFF241E19),
    defaultText: Color(0xFFE8DCC4),
    surface: Color(0xFF332B24),
    newWordColor: Color(0xFFF87171),       // Mercan Kırmızı (Öğrenilmemiş / Yeni)
    learningWordColor: Color(0xFFF59E0B),
    masteredWordColor: Color(0xFF10B981),
    unaddedWordColor: Color(0xFFE8DCC4),
    label: 'Gece Papirüsü',
  );

  static ReaderThemeColors fromMode(ReaderThemeMode mode) {
    switch (mode) {
      case ReaderThemeMode.matteDark:
        return matteDark;
      case ReaderThemeMode.oledBlack:
        return oledBlack;
      case ReaderThemeMode.papyrus:
        return papyrus;
      case ReaderThemeMode.darkSepia:
        return darkSepia;
    }
  }
}

class ReadingState {
  static const String defaultText =
      "Welcome to LearnCard Interactive Reader! Tap on any word in this paragraph to instantly look up its English definition, hear native audio pronunciation, and fetch Turkish translations. You can also add words directly to your flashcard deck with automatic sentence context extraction. Ephemeral moments pass quickly, but serendipity brings great discoveries to resilient learners who stay pragmatic and persistent.";

  final List<ReadingArticleModel> articles;
  final ReadingArticleModel? selectedArticle;
  final bool isLoading;
  final bool isFocusMode;
  final String currentText;
  final ReaderThemeMode themeMode;
  final double fontSize;
  final double lineHeight;
  final String selectedFolder;
  final List<String> customFolders;

  ReadingState({
    this.articles = const [],
    this.selectedArticle,
    this.isLoading = false,
    this.isFocusMode = false,
    String? currentText,
    this.themeMode = ReaderThemeMode.matteDark,
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.selectedFolder = 'Tümü',
    this.customFolders = const ['Genel', 'Makaleler', 'Hikayeler', 'Haberler'],
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
    ReaderThemeMode? themeMode,
    double? fontSize,
    double? lineHeight,
    String? selectedFolder,
    List<String>? customFolders,
  }) {
    return ReadingState(
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle == _sentinel
          ? this.selectedArticle
          : (selectedArticle as ReadingArticleModel?),
      isLoading: isLoading ?? this.isLoading,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      currentText: currentText ?? this.currentText,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      customFolders: customFolders ?? this.customFolders,
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
      final modeName = await _db.getString('reader_theme_mode');
      final fontSize = await _db.getDouble('reader_font_size');
      final lineHeight = await _db.getDouble('reader_line_height');
      final savedFolders = await _db.getStringList('reader_custom_folders');

      ReaderThemeMode mode = state.themeMode;
      if (modeName != null) {
        mode = ReaderThemeMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => ReaderThemeMode.matteDark,
        );
      }

      state = state.copyWith(
        themeMode: mode,
        fontSize: fontSize ?? 18.0,
        lineHeight: lineHeight ?? 1.6,
        customFolders: savedFolders ?? state.customFolders,
      );
    } catch (_) {}
  }

  Future<void> loadReadings() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await SupabaseService.getSavedReadings();

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
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
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

    if (state.articles.any((a) => a.folder == trimmed)) {
      updatedArticles = state.articles.map((a) {
        if (a.folder == trimmed) {
          final updated = a.copyWith(folder: 'Genel');
          SupabaseService.saveReadingArticle(updated);
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
  }

  Future<void> setThemeMode(ReaderThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      await _db.setString('reader_theme_mode', mode.name);
    } catch (_) {}
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    try {
      await _db.setDouble('reader_font_size', size);
    } catch (_) {}
  }

  Future<void> setLineHeight(double height) async {
    state = state.copyWith(lineHeight: height);
    try {
      await _db.setDouble('reader_line_height', height);
    } catch (_) {}
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
    await SupabaseService.saveReadingArticle(article);
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
    await SupabaseService.saveReadingArticle(article);
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
    await SupabaseService.deleteReadingArticle(id);
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
