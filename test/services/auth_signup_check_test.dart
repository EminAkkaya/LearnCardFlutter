import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

User _user({List<UserIdentity>? identities}) => User(
      id: 'u1',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-11-07T00:00:00Z',
      identities: identities,
    );

void main() {
  group('AuthService.isExistingAccountSignUp', () {
    test('empty identities means the e-mail is already registered', () {
      expect(AuthService.isExistingAccountSignUp(_user(identities: const [])), isTrue);
    });

    test('a fresh sign-up with an identity is a new account', () {
      final identity = UserIdentity(
        id: 'i1',
        userId: 'u1',
        identityData: const {},
        identityId: 'i1',
        provider: 'email',
        createdAt: '2026-11-07T00:00:00Z',
        lastSignInAt: '2026-11-07T00:00:00Z',
      );
      expect(AuthService.isExistingAccountSignUp(_user(identities: [identity])), isFalse);
    });

    test('missing user or identities is not treated as existing', () {
      expect(AuthService.isExistingAccountSignUp(null), isFalse);
      expect(AuthService.isExistingAccountSignUp(_user()), isFalse);
    });
  });
}
