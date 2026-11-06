import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

/// Şifre sıfırlama e-postasındaki bağlantıyla uygulamaya dönen kullanıcının
/// yeni şifresini belirlediği ekran.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  static const int minLength = 6;

  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(authProvider.notifier).updatePassword(_passwordCtrl.text);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? 'Şifren güncellendi.' : (ref.read(authProvider).error ?? 'Şifre güncellenemedi.')),
    ));
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < ResetPasswordScreen.minLength) {
      return 'En az ${ResetPasswordScreen.minLength} karakter olmalı';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Şifre Belirle'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => ref.read(authProvider.notifier).signOut(),
            child: const Text('Vazgeç'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Hesabın için yeni bir şifre gir.'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Yeni şifre',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  validator: (v) => v == _passwordCtrl.text ? null : 'Şifreler eşleşmiyor',
                  decoration: const InputDecoration(
                    labelText: 'Yeni şifre (tekrar)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Şifreyi Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
