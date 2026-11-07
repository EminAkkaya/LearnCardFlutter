import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/auth_ui.dart';

class ChangeEmailDialog extends StatefulWidget {
  final String currentEmail;
  final ValueChanged<String> onEmailChanged;

  const ChangeEmailDialog({
    super.key,
    required this.currentEmail,
    required this.onEmailChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentEmail,
    required ValueChanged<String> onEmailChanged,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ChangeEmailDialog(
        currentEmail: currentEmail,
        onEmailChanged: onEmailChanged,
      ),
    );
  }

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  late final TextEditingController _newEmailController;

  @override
  void initState() {
    super.initState();
    _newEmailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }

  void _submit() {
    final newEmail = _newEmailController.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@') || !newEmail.contains('.')) {
      showAuthSnackBar(context, 'Geçerli bir e-posta adresi girin.', tone: AuthSnackTone.error);
      return;
    }

    Navigator.pop(context);
    widget.onEmailChanged(newEmail);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(LucideIcons.squarePen, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          const Flexible(child: Text('E-postayı Değiştir')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doğrulama kodunun gönderileceği yeni e-posta adresini girin:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: authInputDecoration(
              context,
              labelText: 'Yeni E-posta Adresi',
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
          onPressed: _submit,
          child: const Text('Güncelle ve Kod Gönder'),
        ),
      ],
    );
  }
}
