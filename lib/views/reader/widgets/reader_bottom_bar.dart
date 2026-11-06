import 'package:flutter/material.dart';
import '../../../providers/reading_provider.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.defaultText.withValues(alpha: 0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ReaderBottomActionButton(
            icon: Icons.paste_rounded,
            label: 'Yeni Metin',
            color: colors.defaultText,
            onTap: onNewTextTap,
          ),
          ReaderBottomActionButton(
            icon: Icons.folder_open_rounded,
            label: 'Kayıtlılar',
            color: colors.defaultText,
            onTap: onSavedTap,
          ),
          ReaderBottomActionButton(
            icon: Icons.palette_outlined,
            label: 'Tema',
            color: colors.defaultText,
            onTap: onThemeTap,
          ),
          ReaderBottomActionButton(
            icon: Icons.save_outlined,
            label: 'Kaydet',
            color: colors.defaultText,
            onTap: onSaveTap,
          ),
          ReaderBottomActionButton(
            icon: Icons.fullscreen_rounded,
            label: 'Odak Modu',
            color: colors.defaultText,
            onTap: onFocusTap,
          ),
        ],
      ),
    );
  }
}
