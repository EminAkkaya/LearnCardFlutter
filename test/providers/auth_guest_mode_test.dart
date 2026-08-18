import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/providers/auth_provider.dart';
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so');
        } catch (_) {
          return DynamicLibrary.open('libsqlite3.so.0');
        }
      });
    }
  });

  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  group('Auth Guest Mode Tests', () {
    test('1. Guest mode starts as false by default when db is clean', () async {
      final notifier = AuthNotifier(testDb);
      expect(notifier.state.isGuestMode, isFalse);
      expect(notifier.state.isAuthenticated, isFalse);
    });

    test('2. continueAsGuest sets isGuestMode to true and persists to db', () async {
      final notifier = AuthNotifier(testDb);
      await notifier.continueAsGuest();

      expect(notifier.state.isGuestMode, isTrue);
      expect(notifier.state.isGuest, isTrue);

      final isSaved = await testDb.getBool('auth_is_guest_mode');
      expect(isSaved, isTrue);
    });

    test('3. AuthNotifier restores isGuestMode on cold boot if user is null', () async {
      await testDb.setBool('auth_is_guest_mode', true);

      final notifier = AuthNotifier(testDb);
      // Wait for _loadGuestModeStatus async call
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isGuestMode, isTrue);
      expect(notifier.state.isGuest, isTrue);
    });

    test('4. exitGuestMode resets isGuestMode to false and clears preference', () async {
      final notifier = AuthNotifier(testDb);
      await notifier.continueAsGuest();
      expect(notifier.state.isGuestMode, isTrue);

      await notifier.exitGuestMode();
      expect(notifier.state.isGuestMode, isFalse);

      final isSaved = await testDb.getBool('auth_is_guest_mode');
      expect(isSaved, isFalse);
    });
  });
}
