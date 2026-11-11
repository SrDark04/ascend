import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
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

  testWidgets('dev muestra su nombre y el acceso a Diagnóstico', (
    tester,
  ) async {
    await pumpWith(tester, AppConfig.dev);
    expect(find.text('Ascend Dev'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ascend Dev');

    await tester.tap(find.text('Diagnóstico'));
    await tester.pumpAndSettle();
    expect(find.byType(DiagnosticsScreen), findsOneWidget);
  });

  testWidgets('prod no muestra el acceso a Diagnóstico', (tester) async {
    await pumpWith(tester, AppConfig.prod);
    expect(find.text('Ascend'), findsOneWidget);
    expect(find.text('Diagnóstico'), findsNothing);
  });
}
