import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_article_model.dart';
import '../services/supabase_service.dart';

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

  ReadingState({
    this.articles = const [],
    this.selectedArticle,
    this.isLoading = false,
    this.isFocusMode = false,
    String? currentText,
    this.themeMode = ReaderThemeMode.matteDark,
  }) : currentText = currentText ?? defaultText;

  ReadingState copyWith({
    List<ReadingArticleModel>? articles,
    ReadingArticleModel? selectedArticle,
    bool? isLoading,
    bool? isFocusMode,
    String? currentText,
    ReaderThemeMode? themeMode,
  }) {
    return ReadingState(
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle ?? this.selectedArticle,
      isLoading: isLoading ?? this.isLoading,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      currentText: currentText ?? this.currentText,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ReadingNotifier extends StateNotifier<ReadingState> {
  ReadingNotifier() : super(ReadingState()) {
    loadReadings();
  }

  Future<void> loadReadings() async {
    state = state.copyWith(isLoading: true);
    try {
      final articles = await SupabaseService.getSavedReadings();
      state = state.copyWith(articles: articles, isLoading: false);
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

  void updateCurrentText(String text) {
    state = state.copyWith(currentText: text);
  }

  void setThemeMode(ReaderThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void selectArticle(ReadingArticleModel? article) {
    if (article != null) {
      state = state.copyWith(
        selectedArticle: article,
        currentText: article.text,
      );
    } else {
      state = state.copyWith(selectedArticle: null);
    }
  }

  Future<ReadingArticleModel> saveArticle(String title, String text) async {
    final article = ReadingArticleModel(
      id: 'reading_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}',
      title: title.trim().isEmpty ? 'Untitled Article' : title.trim(),
      text: text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    final updated = [article, ...state.articles.where((a) => a.id != article.id)];
    state = state.copyWith(
      articles: updated,
      selectedArticle: article,
      currentText: text.trim(),
    );

    await SupabaseService.saveReadingArticle(article);
    return article;
  }

  Future<void> deleteArticle(String id) async {
    final updated = state.articles.where((a) => a.id != id).toList();
    ReadingArticleModel? selected = state.selectedArticle;
    if (selected?.id == id) {
      selected = null;
    }
    state = state.copyWith(articles: updated, selectedArticle: selected);
    await SupabaseService.deleteReadingArticle(id);
  }
}

final readingProvider = StateNotifierProvider<ReadingNotifier, ReadingState>((ref) {
  return ReadingNotifier();
});
