import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpWith(WidgetTester tester, AppConfig config) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(config)],
          child: const AscendApp(),
        ),
      );

  testWidgets('muestra el nombre del flavor dev', (tester) async {
    await pumpWith(tester, AppConfig.dev);
    expect(find.text('Ascend Dev'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ascend Dev');
  });

  testWidgets('muestra el nombre del flavor prod', (tester) async {
    await pumpWith(tester, AppConfig.prod);
    expect(find.text('Ascend'), findsOneWidget);
  });
}
