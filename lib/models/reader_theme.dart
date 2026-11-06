import 'package:flutter/material.dart';

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
