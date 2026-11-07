import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'feedback_colors.dart';

/// Minimalist Tasarım Sistemi v1.1'e göre uygulama teması (bkz. [AppPalette]).
class AppTheme {
  /// pubspec.yaml'da gömülü yazı tipi ailesi.
  static const String fontFamily = 'Inter';

  /// Varsayılan vurgu: adaçayı (açık temada etkileşim tonu).
  static const Color defaultAccent = Color(0xFF4D6B5C);

  /// [background] üzerinde daha okunaklı olan yazı rengi (krem beyaz ya da espresso).
  static Color onColorFor(Color background) {
    const light = Color(0xFFFBFAF7);
    const dark = Color(0xFF14110F);
    final bg = background.computeLuminance();
    final lightContrast = (light.computeLuminance() + 0.05) / (bg + 0.05);
    final darkContrast = (bg + 0.05) / (dark.computeLuminance() + 0.05);
    return lightContrast >= darkContrast ? light : dark;
  }

  static ThemeData getLightTheme([Color accent = defaultAccent]) =>
      _build(AppPalette.light, FeedbackColors.light, accent, Brightness.light);

  /// [accent] açık tema değeridir; koyu temadaki karşılığı [darkAccentFor] ile bulunur.
  static ThemeData getDarkTheme([Color accent = defaultAccent]) =>
      _build(AppPalette.dark, FeedbackColors.dark, darkAccentFor(accent), Brightness.dark);

  /// Seçilebilir vurgu renklerinin koyu tema karşılıkları.
  static const Map<int, Color> _darkAccents = {
    0xFF4D6B5C: Color(0xFF83A894), // adaçayı
    0xFF98432E: Color(0xFFD98770), // kiremit
    0xFF3F5F7A: Color(0xFF8FAFC8), // okyanus
    0xFF6B4A6E: Color(0xFFB99BBB), // erik
    0xFF7D550A: Color(0xFFD4A94A), // hardal
    0xFF6F5340: Color(0xFFC2A48C), // toprak
  };

  static Color darkAccentFor(Color lightAccent) =>
      _darkAccents[lightAccent.toARGB32()] ?? Color.lerp(lightAccent, const Color(0xFFEDE8E1), 0.45)!;

  static ThemeData _build(AppPalette p, FeedbackColors fb, Color accent, Brightness brightness) {
    final onAccent = onColorFor(accent);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: Color.alphaBlend(accent.withValues(alpha: 0.14), p.card),
      onPrimaryContainer: p.textPrimary,
      secondary: accent,
      onSecondary: onAccent,
      secondaryContainer: p.subtle,
      onSecondaryContainer: p.textPrimary,
      tertiary: p.accentGraphic,
      onTertiary: onColorFor(p.accentGraphic),
      error: fb.danger,
      onError: fb.onAccent,
      surface: p.card,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.bg,
      surfaceContainerLow: p.subtle,
      surfaceContainer: p.subtle,
      surfaceContainerHigh: p.hover,
      surfaceContainerHighest: p.hover,
      outline: p.controlBorder,
      outlineVariant: p.border,
      shadow: const Color(0xFF2B2722),
      inverseSurface: p.textPrimary,
      onInverseSurface: p.bg,
    );

    final base = ThemeData(useMaterial3: true, brightness: brightness, fontFamily: fontFamily);
    final text = base.textTheme.apply(bodyColor: p.textPrimary, displayColor: p.textPrimary);
    final control = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusControl));

    return base.copyWith(
      colorScheme: scheme,
      extensions: [p, fb],
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      dividerColor: p.border,
      splashFactory: InkRipple.splashFactory,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w500, color: p.textSecondary),
        bodySmall: text.bodySmall?.copyWith(color: p.textMuted),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusCard),
          side: BorderSide(color: p.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: p.textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          shape: control,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: onAccent,
          shape: control,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.controlBorder),
          shape: control,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent, shape: control),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.subtle,
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
          borderSide: BorderSide(color: p.controlBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
          borderSide: BorderSide(color: p.controlBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.radiusControl),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.subtle,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusPill)),
        labelStyle: TextStyle(fontFamily: fontFamily, color: p.textPrimary, fontSize: 13),
        checkmarkColor: p.textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusCard)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppPalette.radiusCard)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.textPrimary,
        contentTextStyle: TextStyle(fontFamily: fontFamily, color: p.bg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppPalette.radiusControl)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.card,
        selectedItemColor: accent,
        unselectedItemColor: p.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: 0,
        shape: control,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent, linearTrackColor: p.border),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(iconColor: p.textSecondary, textColor: p.textPrimary),
      iconTheme: IconThemeData(color: p.textSecondary),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(p.controlBorder),
      ),
    );
  }

  static ThemeData lightTheme = getLightTheme();
  static ThemeData darkTheme = getDarkTheme();
}
