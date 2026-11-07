import 'package:flutter/material.dart';

/// Minimalist Tasarım Sistemi v1.1 (projeler/design/design_minimalist.md) token'ları.
///
/// Krem / espresso zemin, sıcak kahve metin, adaçayı vurgu. Kurallar: gradient yok,
/// emoji yok, saf siyah/beyaz zemin yok, cam efekti yok. Metin ≥ 4.5:1, anlamlı
/// ikon/grafik ≥ 3:1. Bileşenlerde ham renk yerine bu token'lar kullanılır:
/// `AppPalette.of(context).textSecondary`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Sayfa zemini (hamur beyazı / koyu espresso).
  final Color bg;

  /// Kart yüzeyi.
  final Color card;

  /// Alt zemin: input, rozet, ikincil yüzey.
  final Color subtle;

  /// Basılı/üzerine gelme yüzeyi.
  final Color hover;

  /// Dekoratif kart/ayırıcı kenarlığı.
  final Color border;

  /// Etkileşimli kontrol kenarı (input, ghost buton) — ≥ 3:1.
  final Color controlBorder;

  final Color textPrimary;
  final Color textSecondary;

  /// Yardımcı metin; yine de ≥ 4.5:1.
  final Color textMuted;

  /// Yalnız ikon/grafik vurgu rengi (metin ve buton dolgusu olarak kullanma).
  final Color accentGraphic;

  final bool isDark;

  const AppPalette({
    required this.bg,
    required this.card,
    required this.subtle,
    required this.hover,
    required this.border,
    required this.controlBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentGraphic,
    this.isDark = false,
  });

  static const light = AppPalette(
    bg: Color(0xFFFBFAF7),
    card: Color(0xFFFFFFFF),
    subtle: Color(0xFFF7F5F0),
    hover: Color(0xFFF6F3EE),
    border: Color(0xFFE8E2D8),
    controlBorder: Color(0xFF8A8178),
    textPrimary: Color(0xFF2B2722),
    textSecondary: Color(0xFF706962),
    textMuted: Color(0xFF766F66),
    accentGraphic: Color(0xFF6B8A7A),
  );

  static const dark = AppPalette(
    bg: Color(0xFF14110F),
    card: Color(0xFF221C18),
    subtle: Color(0xFF1C1714),
    hover: Color(0xFF2B2420),
    border: Color(0xFF3A322B),
    controlBorder: Color(0xFF6E665F),
    textPrimary: Color(0xFFEDE8E1),
    textSecondary: Color(0xFF9A9088),
    textMuted: Color(0xFF8A8178),
    accentGraphic: Color(0xFF83A894),
    isDark: true,
  );

  /// Köşe yarıçapları: kart 12, buton/input 8, rozet tam yuvarlak.
  static const double radiusCard = 12;
  static const double radiusControl = 8;
  static const double radiusPill = 999;

  /// Hareket süreleri: buton/toggle, dropdown/toast, modal/drawer.
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionBase = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 320);

  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ?? (theme.brightness == Brightness.dark ? dark : light);
  }

  /// Açık temada çok hafif gölge; koyu temada gölge yerine kenarlık kullanılır.
  List<BoxShadow> get cardShadow => isDark
      ? const []
      : const [BoxShadow(color: Color(0x0A2B2722), blurRadius: 12, offset: Offset(0, 4))];

  /// Standart kart dekorasyonu (opak yüzey + 1px kenarlık).
  BoxDecoration cardDecoration({Color? color, double radius = radiusCard}) => BoxDecoration(
        color: color ?? card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: cardShadow,
      );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? card,
    Color? subtle,
    Color? hover,
    Color? border,
    Color? controlBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentGraphic,
  }) =>
      AppPalette(
        bg: bg ?? this.bg,
        card: card ?? this.card,
        subtle: subtle ?? this.subtle,
        hover: hover ?? this.hover,
        border: border ?? this.border,
        controlBorder: controlBorder ?? this.controlBorder,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        accentGraphic: accentGraphic ?? this.accentGraphic,
        isDark: isDark,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      subtle: l(subtle, other.subtle),
      hover: l(hover, other.hover),
      border: l(border, other.border),
      controlBorder: l(controlBorder, other.controlBorder),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      accentGraphic: l(accentGraphic, other.accentGraphic),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
