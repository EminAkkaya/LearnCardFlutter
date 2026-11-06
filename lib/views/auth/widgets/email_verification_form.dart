import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../auth_gate.dart';
import '../dialogs/change_email_dialog.dart';
import 'auth_header_widget.dart';
import 'email_badge_widget.dart';
import 'otp_input_row.dart';
import 'resend_countdown_widget.dart';

class EmailVerificationForm extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationForm({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationForm> createState() =>
      _EmailVerificationFormState();
}

class _EmailVerificationFormState extends ConsumerState<EmailVerificationForm> {
  static const int _otpLength = 6;
  static const int _resendCooldownSeconds = 60;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late String _currentEmail;
  Timer? _timer;
  int _secondsRemaining = _resendCooldownSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _secondsRemaining = _resendCooldownSeconds;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      }
    });
  }

  String _getEnteredOtp() => _controllers.map((c) => c.text.trim()).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (int i = 0; i < _otpLength; i++) {
          if (i < digits.length) _controllers[i].text = digits[i];
        }
        final targetIndex =
            digits.length < _otpLength ? digits.length : _otpLength - 1;
        _focusNodes[targetIndex].requestFocus();
        if (digits.length >= _otpLength) _handleVerify();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_getEnteredOtp().length == _otpLength) _handleVerify();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index - 1].text.length),
      );
    }
  }

  Future<void> _handleVerify() async {
    final token = _getEnteredOtp();
    if (token.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 6 haneli doğrulama kodunun tamamını girin.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(
      email: _currentEmail,
      token: token,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-posta adresiniz başarıyla doğrulandı! Giriş yapılıyor...',
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } else {
      final error =
          ref.read(authProvider).error ?? 'Geçersiz veya süresi dolmuş kod.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;

    final success = await ref
        .read(authProvider.notifier)
        .resendOtp(_currentEmail);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni doğrulama kodu e-posta adresinize gönderildi.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _startResendTimer();
    } else {
      final error =
          ref.read(authProvider).error ?? 'Kod gönderilirken bir hata oluştu.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onChangeEmailRequested() {
    ChangeEmailDialog.show(
      context,
      currentEmail: _currentEmail,
      onEmailChanged: (newEmail) async {
        setState(() => _currentEmail = newEmail);
        ref.read(authProvider.notifier).setPendingEmail(newEmail);
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        await _handleResend();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthHeaderWidget(
          title: 'Hesabınızı Doğrulayın',
          subtitle:
              'Lütfen aşağıdaki e-posta adresine gönderdiğimiz 6 haneli güvenlik kodunu girin:',
          icon: Icons.mark_email_read_rounded,
        ),
        const SizedBox(height: 10),
        EmailBadgeWidget(
          email: _currentEmail,
          onTap: _onChangeEmailRequested,
        ),
        const SizedBox(height: 32),
        OtpInputRow(
          otpLength: _otpLength,
          controllers: _controllers,
          focusNodes: _focusNodes,
          onDigitChanged: _onDigitChanged,
          onKeyEvent: _onKeyEvent,
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Kodu Doğrula ve Giriş Yap',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        ResendCountdownWidget(
          canResend: _canResend,
          secondsRemaining: _secondsRemaining,
          isLoading: authState.isLoading,
          onResend: _handleResend,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Giriş Ekranına Geri Dön',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
