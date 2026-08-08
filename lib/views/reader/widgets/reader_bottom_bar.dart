import 'package:flutter/material.dart';
import '../../../providers/reading_provider.dart';

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

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 10,
      ),
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
          _buildBottomAction(
            icon: Icons.paste_rounded,
            label: 'Yeni Metin',
            color: colors.defaultText,
            onTap: onNewTextTap,
          ),
          _buildBottomAction(
            icon: Icons.folder_open_rounded,
            label: 'Kayıtlılar',
            color: colors.defaultText,
            onTap: onSavedTap,
          ),
          _buildBottomAction(
            icon: Icons.palette_outlined,
            label: 'Tema',
            color: colors.defaultText,
            onTap: onThemeTap,
          ),
          _buildBottomAction(
            icon: Icons.save_outlined,
            label: 'Kaydet',
            color: colors.defaultText,
            onTap: onSaveTap,
          ),
          _buildBottomAction(
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
