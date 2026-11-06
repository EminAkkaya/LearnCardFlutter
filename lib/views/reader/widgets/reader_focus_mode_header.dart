import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reader_theme.dart';
import '../../../providers/reading_provider.dart';
import 'theme_selector_sheet.dart';

class ReaderFocusModeHeader extends ConsumerWidget {
  final ReaderThemeColors themeColors;

  const ReaderFocusModeHeader({super.key, required this.themeColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 24),
            color: themeColors.defaultText.withValues(alpha: 0.7),
            tooltip: 'Tema Seç',
            onPressed: () => ThemeSelectorSheet.show(context, themeColors),
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_exit_rounded, size: 28),
            color: themeColors.defaultText.withValues(alpha: 0.7),
            tooltip: 'Odak Modundan Çık',
            onPressed: () => ref.read(readingProvider.notifier).setFocusMode(false),
          ),
        ],
      ),
    );
  }
}
