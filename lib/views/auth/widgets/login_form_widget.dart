import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../providers/auth_provider.dart';
import '../dialogs/forgot_password_dialog.dart';
import '../email_verification_screen.dart';
import 'auth_ui.dart';
import '../../../core/theme/feedback_colors.dart';

class LoginFormWidget extends ConsumerStatefulWidget {
  const LoginFormWidget({super.key});

  @override
  ConsumerState<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends ConsumerState<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      showAuthSnackBar(context, 'Başarıyla giriş yapıldı! Hoş geldiniz.', tone: AuthSnackTone.success);
      if (Navigator.canPop(context)) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      final currentAuthState = ref.read(authProvider);
      final error = currentAuthState.error ?? 'Giriş yapılamadı.';
      final isUnconfirmed = currentAuthState.pendingEmail != null &&
          currentAuthState.pendingEmail!.isNotEmpty;

      showAuthSnackBar(
        context,
        error,
        tone: isUnconfirmed ? AuthSnackTone.info : AuthSnackTone.error,
        action: isUnconfirmed
              ? SnackBarAction(
                  label: 'Doğrula',
                  textColor: FeedbackColors.of(context).onAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmailVerificationScreen(email: email),
                      ),
                    );
                  },
                )
              : null,
      );

      if (isUnconfirmed) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email),
          ),
        );
      }
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => ForgotPasswordDialog.show(
                context,
                initialEmail: _emailController.text,
              ),
              child: const Text(
                'Şifremi Unuttum',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              child: authState.isLoading ? const ButtonSpinner() : const Text('Giriş Yap'),
            ),
          ),
        ],
      ),
    );
  }
}
