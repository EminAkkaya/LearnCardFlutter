import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  final String initialEmail;

  const ForgotPasswordDialog({super.key, required this.initialEmail});

  static Future<void> show(BuildContext context, {String initialEmail = ''}) {
    return showDialog(
      context: context,
      builder: (_) => ForgotPasswordDialog(initialEmail: initialEmail),
    );
  }

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  late final TextEditingController _resetEmailController;

  @override
  void initState() {
    super.initState();
    _resetEmailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitReset() async {
    final email = _resetEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showAuthSnackBar(context, 'Geçerli bir e-posta adresi girin.', tone: AuthSnackTone.error);
      return;
    }

    // Diyalog kapanınca bu widget'ın context'i ve ref'i geçersiz olur; sonucu
    // gösterebilmek için ekranın messenger'ını ve provider container'ını önceden al.
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    Navigator.pop(context);
    final success = await container.read(authProvider.notifier).resetPassword(email);
    if (!messenger.mounted) return;

    final error = container.read(authProvider).error;
    messenger.showSnackBar(buildAuthSnackBar(
      messenger.context,
      success
          ? 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'
          : (error ?? 'Sıfırlama e-postası gönderilemedi.'),
      tone: success ? AuthSnackTone.success : AuthSnackTone.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(LucideIcons.keyRound, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          const Flexible(child: Text('Şifre Sıfırlama')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hesabınıza kayıtlı e-posta adresinizi girin. Şifre sıfırlama bağlantısı gönderilecektir.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: authInputDecoration(
              context,
              labelText: 'E-posta Adresi',
              prefixIcon: LucideIcons.mail,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submitReset,
          child: const Text('Gönder'),
        ),
      ],
    );
  }
}
