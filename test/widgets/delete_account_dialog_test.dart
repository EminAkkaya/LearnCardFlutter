import 'dart:ffi';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/core/database/app_database.dart';
import 'package:learncard_flutter/providers/auth_provider.dart';
import 'package:learncard_flutter/views/settings/dialogs/delete_account_dialog.dart';
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

  testWidgets('delete button stays disabled until confirm word is typed', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => AuthNotifier(db))],
        child: const MaterialApp(home: Scaffold(body: DeleteAccountDialog())),
      ),
    );

    ElevatedButton deleteButton() =>
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Kalıcı Olarak Sil'));

    expect(deleteButton().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'SILME');
    await tester.pump();
    expect(deleteButton().onPressed, isNull);
    for (final word in ['SİL', 'SIL', 'sil']) {
      await tester.enterText(find.byType(TextField), word);
      await tester.pump();
      expect(deleteButton().onPressed, isNotNull, reason: word);
    }
  });
}
