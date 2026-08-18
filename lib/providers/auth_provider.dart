import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../core/database/app_database.dart';
import '../services/auth_service.dart';

class AppAuthState {
  final sb.User? user;
  final bool isLoading;
  final String? error;
  final String? pendingEmail;
  final bool isGuestMode;

  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.pendingEmail,
    this.isGuestMode = false,
  });

  bool get isAuthenticated => user != null;
  bool get isGuest => isGuestMode;
  bool get isEmailConfirmed => AuthService.isEmailConfirmed(user);
  bool get isFullyAuthenticated => isAuthenticated && isEmailConfirmed;

  AppAuthState copyWith({
    sb.User? user,
    bool? isLoading,
    String? error,
    String? pendingEmail,
    bool? isGuestMode,
    bool clearUser = false,
    bool clearPendingEmail = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingEmail: clearPendingEmail
          ? null
          : (pendingEmail ?? this.pendingEmail),
      isGuestMode: isGuestMode ?? this.isGuestMode,
    );
  }
}

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AppDatabase _db;
  StreamSubscription<sb.AuthState>? _authSubscription;

  AuthNotifier([AppDatabase? database])
      : _db = database ?? appDatabase,
        super(AppAuthState(user: AuthService.currentUser)) {
    _initAuthListener();
    _loadGuestModeStatus();
  }

  Future<void> _loadGuestModeStatus() async {
    try {
      final isGuest = await _db.getBool('auth_is_guest_mode') ?? false;
      if (isGuest && state.user == null) {
        state = state.copyWith(isGuestMode: true);
      }
    } catch (_) {}
  }

  void _initAuthListener() {
    try {
      _authSubscription = AuthService.authStateChanges.listen((data) {
        final user = data.session?.user;
        if (user != null) {
          _db.setBool('auth_is_guest_mode', false);
        }
        state = state.copyWith(
          user: user,
          clearUser: user == null,
          isGuestMode: user != null ? false : state.isGuestMode,
        );
      }, onError: (_) {
        // Gracefully ignore offline auth token refresh / network errors
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setPendingEmail(String? email) {
    state = state.copyWith(
      pendingEmail: email,
      clearPendingEmail: email == null,
    );
  }

  Future<void> continueAsGuest() async {
    try {
      await _db.setBool('auth_is_guest_mode', true);
    } catch (_) {}
    state = state.copyWith(
      isGuestMode: true,
      error: null,
      clearPendingEmail: true,
    );
  }

  Future<void> exitGuestMode() async {
    try {
      await _db.setBool('auth_is_guest_mode', false);
    } catch (_) {}
    state = state.copyWith(isGuestMode: false);
  }

  String _parseAuthError(dynamic e) {
    final message = e is sb.AuthException ? e.message : e.toString();
    final lower = message.toLowerCase();

    if (lower.contains('error sending confirmation email') ||
        lower.contains('unexpected_failure')) {
      return 'Doğrulama e-postası gönderilemedi. Supabase saatlik e-posta limitine ulaşılmış olabilir.';
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('email_not_confirmed')) {
      return 'E-posta adresiniz henüz doğrulanmamış. Lütfen doğrulama kodunu girin.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('user_already_exists')) {
      return 'Bu e-posta adresi ile zaten kayıtlı bir kullanıcı bulunmaktadır.';
    }
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (lower.contains('over_email_send_rate_limit') ||
        lower.contains('rate limit')) {
      return 'Çok fazla istek yapıldı. Lütfen birkaç dakika bekleyin.';
    }
    if (lower.contains('token has expired') || lower.contains('otp_expired')) {
      return 'Girdiğiniz kodun süresi dolmuş. Lütfen yeni kod isteyin.';
    }
    if (lower.contains('invalid token') || lower.contains('otp_invalid')) {
      return 'Girdiğiniz doğrulama kodu geçersiz.';
    }

    return message;
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
      final isConfirmed = AuthService.isEmailConfirmed(response.user);
      try {
        await _db.setBool('auth_is_guest_mode', false);
      } catch (_) {}
      state = state.copyWith(
        user: response.user,
        pendingEmail: isConfirmed ? null : email,
        clearPendingEmail: isConfirmed,
        isGuestMode: false,
        isLoading: false,
      );
      return true;
    } on sb.AuthException catch (e) {
      final isUnconfirmed =
          e.message.toLowerCase().contains('email not confirmed') ||
          e.code == 'email_not_confirmed';
      state = state.copyWith(
        isLoading: false,
        error: _parseAuthError(e),
        pendingEmail: isUnconfirmed ? email : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      try {
        await _db.setBool('auth_is_guest_mode', false);
      } catch (_) {}
      state = state.copyWith(
        user: response.user,
        pendingEmail: email,
        isGuestMode: false,
        isLoading: false,
      );
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await AuthService.verifyEmailOtp(
        email: email,
        token: token,
      );
      final verifiedUser = response.user ?? AuthService.currentUser;
      try {
        await _db.setBool('auth_is_guest_mode', false);
      } catch (_) {}
      state = state.copyWith(
        user: verifiedUser,
        isGuestMode: false,
        isLoading: false,
        clearPendingEmail: true,
      );
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.resendVerificationOtp(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseAuthError(e));
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _db.setBool('auth_is_guest_mode', false);
    } catch (_) {}
    try {
      await AuthService.signOut();
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        clearPendingEmail: true,
        isGuestMode: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuthNotifier(db);
});
