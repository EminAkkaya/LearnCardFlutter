import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir e-posta adresi girin.')),
      );
      return;
    }

    Navigator.pop(context);
    widget.onEmailChanged(newEmail);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: Color(0xFF6366F1)),
          SizedBox(width: 10),
          Text('E-postayı Değiştir'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doğrulama kodunun gönderileceği yeni e-posta adresini girin:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Yeni E-posta Adresi',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
