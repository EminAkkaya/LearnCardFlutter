import 'package:flutter/material.dart';

/// Oyun ve tekrar ekranlarındaki geri bildirim renkleri (doğru, yanlış, uyarı...).
///
/// Minimalist Tasarım Sistemi v1.1 semantik çiftleri (`-fg` tonları): her renk kart
/// yüzeyinde metin olarak ≥ 4.5:1 verir. Açık: success #3B6B38, danger #98432E,
/// warning #7D550A, info (okyanus) #3F5F7A, highlight (toprak) #8A4F2B.
/// Koyu (#221C18 üzerinde): success #86B37D, danger #D98770, warning #D4A94A,
/// info #8FAFC8, highlight #D9A27A. Dolgu üzerinde [onAccent] kullanılır.
/// Durum göstergesinde renge tek başına güvenilmez: renk + ikon + metin birlikte.
@immutable
class FeedbackColors extends ThemeExtension<FeedbackColors> {
  final Color success;
  final Color danger;
  final Color warning;
  final Color info;

  /// Oyuna özgü vurgu (boşluk doldurma pembesi).
  final Color highlight;

  /// Yukarıdaki renklerle doldurulmuş buton/rozet üzerindeki metin ve ikon rengi.
  final Color onAccent;

  const FeedbackColors({
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
    required this.highlight,
    required this.onAccent,
  });

  static const light = FeedbackColors(
    success: Color(0xFF3B6B38),
    danger: Color(0xFF98432E),
    warning: Color(0xFF7D550A),
    info: Color(0xFF3F5F7A),
    highlight: Color(0xFF8A4F2B),
    onAccent: Color(0xFFFBFAF7),
  );

  static const dark = FeedbackColors(
    success: Color(0xFF86B37D),
    danger: Color(0xFFD98770),
    warning: Color(0xFFD4A94A),
    info: Color(0xFF8FAFC8),
    highlight: Color(0xFFD9A27A),
    onAccent: Color(0xFF14110F),
  );

  /// Temadaki eklentiyi döndürür; eklenti yoksa (ör. testlerde düz
  /// `MaterialApp`) parlaklığa göre varsayılanı kullanır.
  static FeedbackColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<FeedbackColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  Color get successContainer => success.withValues(alpha: 0.15);
  Color get dangerContainer => danger.withValues(alpha: 0.15);
  Color get warningContainer => warning.withValues(alpha: 0.12);

  @override
  FeedbackColors copyWith({
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
    Color? highlight,
    Color? onAccent,
  }) {
    return FeedbackColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      highlight: highlight ?? this.highlight,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  FeedbackColors lerp(FeedbackColors? other, double t) {
    if (other == null) return this;
    return FeedbackColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
