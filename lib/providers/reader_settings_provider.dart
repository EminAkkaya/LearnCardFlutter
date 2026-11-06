import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/reader_theme.dart';

/// Okuyucunun görünüm tercihleri: tema, yazı boyutu, satır aralığı.
@immutable
class ReaderSettings {
  static const double defaultFontSize = 18.0;
  static const double defaultLineHeight = 1.6;

  final ReaderThemeMode themeMode;
  final double fontSize;
  final double lineHeight;

  const ReaderSettings({
    this.themeMode = ReaderThemeMode.matteDark,
    this.fontSize = defaultFontSize,
    this.lineHeight = defaultLineHeight,
  });

  ReaderThemeColors get colors => ReaderThemeColors.fromMode(themeMode);

  ReaderSettings copyWith({ReaderThemeMode? themeMode, double? fontSize, double? lineHeight}) {
    return ReaderSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  static const _themeKey = 'reader_theme_mode';
  static const _fontKey = 'reader_font_size';
  static const _lineKey = 'reader_line_height';

  final AppDatabase _db;

  ReaderSettingsNotifier(this._db, {bool autoLoad = true}) : super(const ReaderSettings()) {
    if (autoLoad) load();
  }

  Future<void> load() async {
    try {
      final modeName = await _db.getString(_themeKey);
      final fontSize = await _db.getDouble(_fontKey);
      final lineHeight = await _db.getDouble(_lineKey);

      state = ReaderSettings(
        themeMode: ReaderThemeMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => state.themeMode,
        ),
        fontSize: fontSize ?? ReaderSettings.defaultFontSize,
        lineHeight: lineHeight ?? ReaderSettings.defaultLineHeight,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ReaderThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      await _db.setString(_themeKey, mode.name);
    } catch (_) {}
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    try {
      await _db.setDouble(_fontKey, size);
    } catch (_) {}
  }

  Future<void> setLineHeight(double height) async {
    state = state.copyWith(lineHeight: height);
    try {
      await _db.setDouble(_lineKey, height);
    } catch (_) {}
  }
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  return ReaderSettingsNotifier(ref.watch(appDatabaseProvider));
});
