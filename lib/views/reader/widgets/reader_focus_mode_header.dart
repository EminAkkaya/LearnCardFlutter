import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
            icon: const Icon(LucideIcons.palette, size: 20),
            color: themeColors.defaultText.withValues(alpha: 0.8),
            tooltip: 'Tema Seç',
            onPressed: () => ThemeSelectorSheet.show(context, themeColors),
          ),
          IconButton(
            icon: const Icon(LucideIcons.minimize2, size: 22),
            color: themeColors.defaultText.withValues(alpha: 0.8),
            tooltip: 'Odak Modundan Çık',
            onPressed: () => ref.read(readingProvider.notifier).setFocusMode(false),
          ),
        ],
      ),
    );
  }
}
