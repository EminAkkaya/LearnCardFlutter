import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';

class EmailBadgeWidget extends StatelessWidget {
  final String email;
  final VoidCallback onTap;

  const EmailBadgeWidget({
    super.key,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final radius = BorderRadius.circular(AppPalette.radiusPill);

    return Center(
      child: Material(
        color: palette.subtle,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.mail, size: 16, color: palette.textSecondary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    email.isNotEmpty ? email : 'Belirtilmedi',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.pencil, size: 14, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
