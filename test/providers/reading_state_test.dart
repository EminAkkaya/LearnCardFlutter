import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/reading_article_model.dart';
import 'package:learncard_flutter/providers/reading_provider.dart';

void main() {
  group('ReadingState & ReaderThemeColors Tests', () {
    test('1. ReaderThemeColors maps each mode to distinct color themes', () {
      final matteDark = ReaderThemeColors.fromMode(ReaderThemeMode.matteDark);
      expect(matteDark.background, equals(const Color(0xFF0F172A)));
      expect(matteDark.label, equals('Mat Siyah'));

      final oledBlack = ReaderThemeColors.fromMode(ReaderThemeMode.oledBlack);
      expect(oledBlack.background, equals(const Color(0xFF000000)));
      expect(oledBlack.label, equals('OLED Siyah'));

      final papyrus = ReaderThemeColors.fromMode(ReaderThemeMode.papyrus);
      expect(papyrus.background, equals(const Color(0xFFFBF0D9)));
      expect(papyrus.label, equals('Papirüs'));

      final darkSepia = ReaderThemeColors.fromMode(ReaderThemeMode.darkSepia);
      expect(darkSepia.background, equals(const Color(0xFF241E19)));
      expect(darkSepia.label, equals('Gece Papirüsü'));
    });

    test('2. ReadingState initial state contains default text, folders, and standard typography', () {
      final state = ReadingState();

      expect(state.currentText, isNotEmpty);
      expect(state.currentText, contains('LearnCard Interactive Reader'));
      expect(state.fontSize, equals(18.0));
      expect(state.lineHeight, equals(1.6));
      expect(state.isFocusMode, isFalse);
      expect(state.selectedFolder, equals('Tümü'));
      expect(state.customFolders, containsAll(['Genel', 'Makaleler', 'Hikayeler', 'Haberler']));
    });

    test('3. allFolders dynamically merges and deduplicates folders from customFolders and articles', () {
      final article1 = ReadingArticleModel(
        id: '1',
        title: 'Tech Article',
        text: 'Content...',
        createdAt: '2026-08-14',
        folder: 'Teknoloji',
      );

      final article2 = ReadingArticleModel(
        id: '2',
        title: 'Science Article',
        text: 'Content...',
        createdAt: '2026-08-14',
        folder: 'Bilim',
      );

      final state = ReadingState(
        articles: [article1, article2],
        customFolders: const ['Genel', 'Makaleler', 'Teknoloji'],
      );

      final folders = state.allFolders;

      expect(folders, containsAll(['Genel', 'Makaleler', 'Teknoloji', 'Bilim']));
      // Verify no duplicates
      expect(folders.where((f) => f == 'Teknoloji').length, equals(1));
    });

    test('4. copyWith correctly updates or clears selectedArticle', () {
      final article = ReadingArticleModel(
        id: 'art_1',
        title: 'Sample',
        text: 'Text',
        createdAt: '2026-08-14',
      );

      final stateWithArticle = ReadingState(selectedArticle: article);
      expect(stateWithArticle.selectedArticle, isNotNull);
      expect(stateWithArticle.selectedArticle!.id, equals('art_1'));

      // Clear selectedArticle
      final stateCleared = stateWithArticle.copyWith(selectedArticle: null);
      expect(stateCleared.selectedArticle, isNull);
    });
  });
}
