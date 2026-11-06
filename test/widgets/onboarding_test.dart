import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/providers/onboarding_provider.dart';
import 'package:learncard_flutter/views/onboarding/onboarding_screen.dart';
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

  testWidgets('onboarding pages lead to completion which is persisted', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      onboardingProvider.overrideWith((ref) => OnboardingNotifier(db)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: OnboardingScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Okurken öğren'), findsOneWidget);
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    expect(find.text('Unutmadan tekrar et'), findsOneWidget);
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();

    expect(container.read(onboardingProvider), isTrue);
    expect(await tester.runAsync(() => db.getBool(OnboardingNotifier.storageKey)), isTrue);
  });
}
