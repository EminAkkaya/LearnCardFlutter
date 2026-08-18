import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

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
