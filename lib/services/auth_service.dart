import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Returns the current authenticated Supabase user (if any)
  static User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Returns the current user ID
  static String? get currentUserId {
    try {
      return _client?.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Returns true if a user session is active
  static bool get isAuthenticated {
    try {
      return _client?.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Stream of authentication state changes
  static Stream<AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Signs in an existing user with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized');
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs up a new user with email, password, and optional full name metadata
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized');
    final Map<String, dynamic> data = {};
    if (fullName != null && fullName.trim().isNotEmpty) {
      data['full_name'] = fullName.trim();
    }

    return await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: data.isNotEmpty ? data : null,
    );
  }

  /// Sends a password reset email to the specified address
  static Future<void> resetPassword(String email) async {
    final client = _client;
    if (client == null) return;
    await client.auth.resetPasswordForEmail(email.trim());
  }

  /// Verifies a 6-digit OTP code for email confirmation
  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized');
    try {
      return await client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.signup,
      );
    } catch (_) {
      // Fallback to OtpType.email if signup type fails
      return await client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
    }
  }

  /// Resends the 6-digit verification code to the specified email
  static Future<void> resendVerificationOtp({required String email}) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } catch (_) {
      await client.auth.resend(
        type: OtpType.email,
        email: email.trim(),
      );
    }
  }

  /// Checks if the user's email has been verified
  static bool isEmailConfirmed(User? user) {
    if (user == null) return false;
    if (user.emailConfirmedAt != null) return true;
    try {
      final current = _client?.auth.currentUser;
      if (current != null && current.emailConfirmedAt != null) return true;
    } catch (_) {
      // Handles uninitialized Supabase client in unit tests
    }
    return false;
  }

  /// Signs out the current user
  static Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }
}
