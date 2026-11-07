import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../providers/auth_provider.dart';
import '../email_verification_screen.dart';
import 'auth_ui.dart';

class RegisterFormWidget extends ConsumerStatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  ConsumerState<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends ConsumerState<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).signUp(
      email: email,
      password: password,
      fullName: name,
    );

    if (!mounted) return;

    if (success) {
      showAuthSnackBar(
        context,
        'Hesap oluşturuldu! Lütfen e-postanıza gelen 6 haneli kodu doğrulayın.',
        tone: AuthSnackTone.success,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        ),
      );
    } else {
      final error = ref.read(authProvider).error ?? 'Kayıt işlemi başarısız oldu.';
      showAuthSnackBar(context, error, tone: AuthSnackTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: authInputDecoration(
              context,
              labelText: 'Ad Soyad',
              prefixIcon: LucideIcons.user,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Lütfen adınızı ve soyadınızı girin.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: authInputDecoration(
              context,
              labelText: 'E-posta Adresi',
              hintText: 'ornek@email.com',
              prefixIcon: LucideIcons.mail,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Lütfen e-posta adresinizi girin.';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Geçerli bir e-posta formatı girin.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: authInputDecoration(
              context,
              labelText: 'Şifre',
              prefixIcon: LucideIcons.lock,
              suffixIcon: PasswordVisibilityButton(
                obscured: _obscurePassword,
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Lütfen şifrenizi girin.';
              if (val.length < 6) return 'Şifre en az 6 karakter olmalıdır.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            decoration: authInputDecoration(
              context,
              labelText: 'Şifre Tekrar',
              prefixIcon: LucideIcons.lockKeyhole,
              suffixIcon: PasswordVisibilityButton(
                obscured: _obscureConfirmPassword,
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Lütfen şifrenizi tekrar girin.';
              if (val != _passwordController.text) return 'Şifreler birbiriyle eşleşmiyor.';
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleRegister,
              child: authState.isLoading ? const ButtonSpinner() : const Text('Hesap Oluştur'),
            ),
          ),
        ],
      ),
    );
  }
}
