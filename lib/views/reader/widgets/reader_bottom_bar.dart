import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../models/reader_theme.dart';
import 'reader_bottom_action_button.dart';

class ReaderBottomBar extends StatelessWidget {
  final ReaderThemeColors colors;
  final VoidCallback onNewTextTap;
  final VoidCallback onSavedTap;
  final VoidCallback onThemeTap;
  final VoidCallback onSaveTap;
  final VoidCallback onFocusTap;

  const ReaderBottomBar({
    super.key,
    required this.colors,
    required this.onNewTextTap,
    required this.onSavedTap,
    required this.onThemeTap,
    required this.onSaveTap,
    required this.onFocusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.defaultText.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ReaderBottomActionButton(
            icon: LucideIcons.clipboardPaste,
            label: 'Yeni Metin',
            color: colors.defaultText,
            onTap: onNewTextTap,
          ),
          ReaderBottomActionButton(
            icon: LucideIcons.folderOpen,
            label: 'Kayıtlılar',
            color: colors.defaultText,
            onTap: onSavedTap,
          ),
          ReaderBottomActionButton(
            icon: LucideIcons.palette,
            label: 'Tema',
            color: colors.defaultText,
            onTap: onThemeTap,
          ),
          ReaderBottomActionButton(
            icon: LucideIcons.save,
            label: 'Kaydet',
            color: colors.defaultText,
            onTap: onSaveTap,
          ),
          ReaderBottomActionButton(
            icon: LucideIcons.maximize2,
            label: 'Odak Modu',
            color: colors.defaultText,
            onTap: onFocusTap,
          ),
        ],
      ),
    );
  }
}
