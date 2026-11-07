import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/feedback_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/logout_dialog.dart';

/// Hesap kartı: misafir için yerel mod bilgisi ve giriş çağrısı, oturum açmış
/// kullanıcı için ad/e-posta, çıkış ve hesap silme.
class AccountSectionCard extends ConsumerWidget {
  const AccountSectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: user == null
            ? const _GuestAccountView()
            : _SignedInAccountView(
                userName: user.userMetadata?['full_name']?.toString() ??
                    (user.email != null ? user.email!.split('@')[0] : 'Misafir Kullanıcı'),
                userEmail: user.email ?? 'Yerel Mod (Hesap Bağlanmadı)',
              ),
      ),
    );
  }
}

class _GuestAccountView extends StatelessWidget {
  const _GuestAccountView();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.subtle,
                borderRadius: BorderRadius.circular(AppPalette.radiusCard),
                border: Border.all(color: palette.border),
              ),
              child: Icon(LucideIcons.userRound, size: 22, color: palette.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Misafir Kullanıcı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const _LocalModeBadge(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Veriler yalnızca bu cihazda kayıtlı',
                    style: TextStyle(fontSize: 12, color: palette.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kelimelerinizi bulutta yedeklemek ve diğer cihazlarınızla senkronize etmek için istediğiniz zaman giriş yapabilirsiniz.',
          style: TextStyle(fontSize: 13, height: 1.5, color: palette.textSecondary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(LucideIcons.logIn, size: 18),
            label: const Text('Giriş Yap veya Hesap Oluştur'),
          ),
        ),
      ],
    );
  }
}

/// "Yerel Mod" rozeti: uyarı zemini + ikon + metin.
class _LocalModeBadge extends StatelessWidget {
  const _LocalModeBadge();

  @override
  Widget build(BuildContext context) {
    final feedback = FeedbackColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: feedback.warningContainer,
        borderRadius: BorderRadius.circular(AppPalette.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.smartphone, size: 12, color: feedback.warning),
          const SizedBox(width: 4),
          Text(
            'Yerel Mod',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: feedback.warning),
          ),
        ],
      ),
    );
  }
}

class _SignedInAccountView extends ConsumerWidget {
  final String userName;
  final String userEmail;

  const _SignedInAccountView({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final feedback = FeedbackColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppPalette.radiusCard),
              ),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 13, color: palette.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(LucideIcons.logOut, size: 20, color: palette.textSecondary),
              tooltip: 'Çıkış Yap',
              onPressed: () => LogoutDialog.show(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => DeleteAccountDialog.show(context),
          icon: const Icon(LucideIcons.trash2, size: 16),
          label: const Text('Hesabı Sil'),
          style: TextButton.styleFrom(foregroundColor: feedback.danger),
        ),
      ],
    );
  }
}
