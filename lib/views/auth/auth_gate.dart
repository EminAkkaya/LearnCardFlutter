import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../home_screen.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sıfırlama bağlantısı uygulamaya döndüğünde üstte açık kalan giriş sayfası
    // (ör. Ayarlar'dan açılan LoginScreen) ya da diyaloglar ResetPasswordScreen'i
    // örtmesin diye kök rotaya dönülür.
    ref.listen<bool>(authProvider.select((s) => s.isPasswordRecovery), (prev, next) {
      if (next && prev != true) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final authState = ref.watch(authProvider);
    final onboardingDone = ref.watch(onboardingProvider);

    // Tanıtım yalnız oturum açmamış ilk kullanıcıya gösterilir.
    if (!authState.isAuthenticated && !authState.isGuestMode) {
      if (onboardingDone == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!onboardingDone) return const OnboardingScreen();
    }

    if (authState.isPasswordRecovery && authState.isAuthenticated) {
      return const ResetPasswordScreen();
    }

    if (authState.isAuthenticated) {
      if (authState.isEmailConfirmed) {
        return const HomeScreen();
      } else {
        return EmailVerificationScreen(
          email: authState.user?.email ?? authState.pendingEmail ?? '',
        );
      }
    } else if (authState.isGuestMode) {
      return const HomeScreen();
    } else {
      if (authState.pendingEmail != null && authState.pendingEmail!.isNotEmpty) {
        return EmailVerificationScreen(
          email: authState.pendingEmail!,
        );
      }
      return const LoginScreen();
    }
  }
}
