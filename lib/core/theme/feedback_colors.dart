import 'package:flutter/material.dart';

/// Oyun ve tekrar ekranlarındaki geri bildirim renkleri (doğru, yanlış, uyarı...).
///
/// Açık ve koyu tema için ayrı tonlar seçildi; her renk tema yüzeyi
/// üzerinde metin olarak WCAG AA (>= 4.5:1) kontrastını sağlar:
/// - Açık (beyaz #FFFFFF üzerinde): success 5.5, danger 6.5, warning 5.0,
///   highlight 6.0, info 6.7. Aynı renkler dolgu olarak beyaz [onAccent] ile
///   aynı oranları verir.
/// - Koyu (#1E293B yüzeyinde): success 5.8, danger 5.3, warning 6.8,
///   highlight 5.5, info 5.8. Dolgu üzerinde koyu [onAccent] (#0F172A) >= 6.4.
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
    success: Color(0xFF047857), // emerald-700
    danger: Color(0xFFB91C1C), // red-700
    warning: Color(0xFFB45309), // amber-700
    info: Color(0xFF1D4ED8), // blue-700
    highlight: Color(0xFFBE185D), // pink-700
    onAccent: Colors.white,
  );

  static const dark = FeedbackColors(
    success: Color(0xFF10B981), // emerald-500
    danger: Color(0xFFF87171), // red-400
    warning: Color(0xFFF59E0B), // amber-500
    info: Color(0xFF60A5FA), // blue-400
    highlight: Color(0xFFF472B6), // pink-400
    onAccent: Color(0xFF0F172A), // slate-900
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
