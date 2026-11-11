import 'package:ascend/app/app_config.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_ascend_app.dart';

Future<AppFakes> openProfile(
  WidgetTester t, {
  AppConfig config = AppConfig.dev,
}) async {
  final fakes = await t.pumpAscendApp(config: config);
  await t.tap(find.text('Perfil'));
  await t.pumpAndSettle();
  return fakes;
}

Future<void> tapVersion(WidgetTester t, AppFakes f, int times) async {
  for (var i = 0; i < times; i++) {
    await t.tap(find.text('Versión'));
    await t.pump(const Duration(milliseconds: 50));
    f.clock.advance(const Duration(milliseconds: 400));
  }
  await t.pumpAndSettle();
}

void main() {
  testWidgets('muestra versión, build y flavor', (t) async {
    await openProfile(t);
    expect(find.text('0.1.0 (1) · dev'), findsOneWidget);
  });

  testWidgets('cambia el tema y lo guarda', (t) async {
    final f = await openProfile(t);
    await t.tap(find.text('Oscuro'));
    await t.pumpAndSettle();
    expect(f.settings.theme, ThemePreference.dark);
    final context = t.element(find.text('Versión'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('cambia la unidad de carga y lo guarda', (t) async {
    final f = await openProfile(t);
    expect(find.textContaining('se guardan siempre en kg'), findsOneWidget);
    await t.tap(find.text('Libras'));
    await t.pumpAndSettle();
    expect(f.settings.unit, WeightUnit.lb);
  });

  testWidgets('7 toques en la versión abren Diagnóstico, con aviso', (t) async {
    final f = await openProfile(t);
    await tapVersion(t, f, 4);
    expect(find.text('A 3 toques del diagnóstico'), findsOneWidget);
    await tapVersion(t, f, 3);
    expect(find.byType(DiagnosticsScreen), findsOneWidget);
  });

  testWidgets('la cuenta se reinicia tras una pausa larga', (t) async {
    final f = await openProfile(t);
    await tapVersion(t, f, 5);
    f.clock.advance(const Duration(seconds: 5));
    await tapVersion(t, f, 2);
    expect(find.byType(DiagnosticsScreen), findsNothing);
  });

  testWidgets('también funciona en prod', (t) async {
    final f = await openProfile(t, config: AppConfig.prod);
    await tapVersion(t, f, 7);
    expect(find.byType(DiagnosticsScreen), findsOneWidget);
  });

  testWidgets('no desborda a 1.3× en 360 dp', (t) async {
    t.view.physicalSize = const Size(360 * 3, 720 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpAscendApp(textScale: 1.3);
    await t.tap(find.text('Perfil'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
