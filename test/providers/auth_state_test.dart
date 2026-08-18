import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AppAuthState Model Tests', () {
    test('1. Initial AppAuthState defaults to unauthenticated and idle', () {
      const state = AppAuthState();
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('2. AppAuthState copyWith correctly updates loading and error states', () {
      const state = AppAuthState();
      final loadingState = state.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.error, isNull);

      final errorState = loadingState.copyWith(isLoading: false, error: 'Hatalı şifre');
      expect(errorState.isLoading, isFalse);
      expect(errorState.error, equals('Hatalı şifre'));
    });

    test('3. AppAuthState copyWith clearUser clears user session', () {
      final user = User(
        id: 'usr-123',
        appMetadata: {},
        userMetadata: {'full_name': 'Emin Akkaya'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final loggedInState = AppAuthState(user: user);
      expect(loggedInState.isAuthenticated, isTrue);
      expect(loggedInState.user?.id, equals('usr-123'));

      final loggedOutState = loggedInState.copyWith(clearUser: true);
      expect(loggedOutState.isAuthenticated, isFalse);
      expect(loggedOutState.user, isNull);
    });

    test('4. AppAuthState correctly handles unconfirmed vs confirmed email status', () {
      final unconfirmedUser = User(
        id: 'usr-456',
        appMetadata: {},
        userMetadata: {'full_name': 'New User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        emailConfirmedAt: null,
      );

      final unconfirmedState = AppAuthState(
        user: unconfirmedUser,
        pendingEmail: 'user@test.com',
      );
      expect(unconfirmedState.isAuthenticated, isTrue);
      expect(unconfirmedState.isEmailConfirmed, isFalse);
      expect(unconfirmedState.isFullyAuthenticated, isFalse);
      expect(unconfirmedState.pendingEmail, equals('user@test.com'));

      final confirmedUser = User(
        id: 'usr-456',
        appMetadata: {},
        userMetadata: {'full_name': 'New User'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        emailConfirmedAt: DateTime.now().toIso8601String(),
      );

      final confirmedState = unconfirmedState.copyWith(
        user: confirmedUser,
        clearPendingEmail: true,
      );
      expect(confirmedState.isAuthenticated, isTrue);
      expect(confirmedState.isEmailConfirmed, isTrue);
      expect(confirmedState.isFullyAuthenticated, isTrue);
      expect(confirmedState.pendingEmail, isNull);
    });

    test('5. AppAuthState correctly manages isGuestMode flag', () {
      const defaultState = AppAuthState();
      expect(defaultState.isGuestMode, isFalse);
      expect(defaultState.isGuest, isFalse);

      final guestState = defaultState.copyWith(isGuestMode: true);
      expect(guestState.isGuestMode, isTrue);
      expect(guestState.isGuest, isTrue);
      expect(guestState.isAuthenticated, isFalse);

      final loggedInState = guestState.copyWith(
        user: User(
          id: 'user-789',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        isGuestMode: false,
      );
      expect(loggedInState.isAuthenticated, isTrue);
      expect(loggedInState.isGuestMode, isFalse);
    });

    test('6. AppAuthState transitions properly between guest and user states', () {
      final user = User(
        id: 'usr-999',
        appMetadata: {},
        userMetadata: {'full_name': 'Sync Tester'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        emailConfirmedAt: DateTime.now().toIso8601String(),
      );

      AppAuthState state = const AppAuthState(isGuestMode: true);
      expect(state.isGuestMode, isTrue);
      expect(state.user, isNull);

      // Sign in transition
      state = state.copyWith(user: user, isGuestMode: false);
      expect(state.isGuestMode, isFalse);
      expect(state.isAuthenticated, isTrue);
      expect(state.user?.id, equals('usr-999'));

      // Sign out transition
      state = state.copyWith(clearUser: true, isGuestMode: false);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });
  });
}
