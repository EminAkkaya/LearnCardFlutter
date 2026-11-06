import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learncard_flutter/views/settings/widgets/app_info_card.dart';

void main() {
  testWidgets('app info card opens the privacy policy screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AppInfoCard(primaryColor: Colors.indigo))),
    ));
    await tester.tap(find.text('Gizlilik Politikası'));
    await tester.pumpAndSettle();
    expect(find.text('Misafir modu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Silme hakkın'), 200);
    expect(find.text('Silme hakkın'), findsOneWidget);
  });
}
