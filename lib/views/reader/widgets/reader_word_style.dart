import 'package:flutter/material.dart';
import '../../../models/reader_theme.dart';

/// Okuyucudaki kelime durumunun görünümü: renk + alt çizgi deseni.
///
/// Renge tek başına güvenilmez (renk körlüğü): her durumun ayrı bir alt çizgi
/// deseni vardır ve lejantta aynı desen metin etiketiyle birlikte gösterilir.
/// Renkler okuyucu temasından gelir; zeminle metin kontrastı 4.5:1'in altına
/// düşerse renk temanın metin rengine doğru koyulaştırılır/açılır.
class ReaderWordStyle {
  final Color color;
  final Color underline;
  final TextDecorationStyle pattern;
  final double thickness;

  const ReaderWordStyle({
    required this.color,
    required this.underline,
    required this.pattern,
    required this.thickness,
  });

  static const double minTextContrast = 4.5;

  /// [status]: 'new' | 'learning' | 'mastered' | null (destede yok).
  factory ReaderWordStyle.forStatus(String? status, ReaderThemeColors colors) {
    Color legible(Color c) => ensureContrast(c, colors.background, colors.defaultText);
    switch (status) {
      case 'new':
        final c = legible(colors.newWordColor);
        return ReaderWordStyle(
          color: c,
          underline: c.withValues(alpha: 0.85),
          pattern: TextDecorationStyle.solid,
          thickness: 2.0,
        );
      case 'learning':
        final c = legible(colors.learningWordColor);
        return ReaderWordStyle(
          color: c,
          underline: c.withValues(alpha: 0.85),
          pattern: TextDecorationStyle.dashed,
          thickness: 2.0,
        );
      case 'mastered':
        final c = legible(colors.masteredWordColor);
        return ReaderWordStyle(
          color: c,
          underline: c.withValues(alpha: 0.85),
          pattern: TextDecorationStyle.dotted,
          thickness: 2.0,
        );
      default:
        return ReaderWordStyle(
          color: colors.unaddedWordColor,
          underline: colors.defaultText.withValues(alpha: 0.25),
          pattern: TextDecorationStyle.solid,
          thickness: 1.0,
        );
    }
  }

  /// WCAG kontrast oranı.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// [fg] zeminde [min] oranına ulaşana dek [toward] rengine (temanın metin
  /// rengi) adım adım yaklaştırılır; tonun kimliği mümkün olduğunca korunur.
  static Color ensureContrast(
    Color fg,
    Color bg,
    Color toward, {
    double min = minTextContrast,
  }) {
    if (contrast(fg, bg) >= min) return fg;
    for (var t = 0.1; t < 1.0; t += 0.1) {
      final c = Color.lerp(fg, toward, t)!;
      if (contrast(c, bg) >= min) return c;
    }
    return toward;
  }
}
