import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/models/flashcard_model.dart';
import 'package:learncard_flutter/models/reader_theme.dart';
import 'package:learncard_flutter/views/reader/widgets/reader_legend_bar.dart';
import 'package:learncard_flutter/views/reader/widgets/reader_word_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:learncard_flutter/views/reader/widgets/word_detail_action_button.dart';

void main() {
  const themes = [
    ReaderThemeColors.matteDark,
    ReaderThemeColors.oledBlack,
    ReaderThemeColors.papyrus,
    ReaderThemeColors.darkSepia,
  ];

  test('durum renkleri her okuyucu zemininde metin kontrastı ≥ 4.5:1', () {
    for (final colors in themes) {
      for (final status in ['new', 'learning', 'mastered']) {
        final look = ReaderWordStyle.forStatus(status, colors);
        expect(
          ReaderWordStyle.contrast(look.color, colors.background),
          greaterThanOrEqualTo(ReaderWordStyle.minTextContrast),
          reason: '${colors.label} / $status',
        );
      }
    }
  });

  test('durumlar renge ek olarak alt çizgi deseniyle de ayrışır', () {
    final patterns = {
      for (final s in ['new', 'learning', 'mastered'])
        ReaderWordStyle.forStatus(s, ReaderThemeColors.papyrus).pattern,
    };
    expect(patterns.length, 3);
  });

  testWidgets('lejant her durumu metin etiketiyle gösterir', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(body: ReaderLegendBar(colors: ReaderThemeColors.papyrus)),
    ));
    for (final label in ['Öğrenilmemiş', 'Öğrenilmekte', 'Öğrenildi', 'Destede Yok']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('destede olan kelime: ikon + durum metni', (t) async {
    final card = FlashcardModel(
      id: '1',
      word: 'go',
      status: 'learning',
      nextReviewDate: '2026-01-01',
      createdAt: '2026-01-01',
    );
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WordDetailActionButton(existingCard: card, isAdding: false, onAdd: () {}),
      ),
    ));
    expect(find.text('Destede Var (ÖĞRENİLİYOR)'), findsOneWidget);
    expect(find.byIcon(LucideIcons.circleCheck), findsOneWidget);
  });
}
