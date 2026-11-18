import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_ascend_app.dart';

void main() {
  testWidgets('arranca en Hoy con 5 pestañas', (t) async {
    await t.pumpAscendApp();
    expect(find.byType(TodayScreen), findsOneWidget);
    final bar = t.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations, hasLength(5));
    for (final label in [
      'Hoy',
      'Entrenar',
      'Historial',
      'Progreso',
      'Perfil',
    ]) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('Progreso muestra «Disponible en v0.5»', (t) async {
    await t.pumpAscendApp();
    await t.tap(find.text('Progreso'));
    await t.pumpAndSettle();
    expect(find.text('Disponible en v0.5'), findsOneWidget);
  });

  testWidgets('cada pestaña conserva su pila de navegación', (t) async {
    final fakes = await t.pumpAscendApp();
    await t.tap(find.text('Perfil'));
    await t.pumpAndSettle();
    for (var i = 0; i < 7; i++) {
      await t.tap(find.text('Versión'));
      await t.pump(const Duration(milliseconds: 100));
      fakes.clock.advance(const Duration(milliseconds: 300));
    }
    await t.pumpAndSettle();
    expect(find.text('Diagnóstico'), findsOneWidget);

    await t.tap(find.text('Hoy'));
    await t.pumpAndSettle();
    await t.tap(find.text('Perfil'));
    await t.pumpAndSettle();
    expect(find.text('Diagnóstico'), findsOneWidget, reason: 'sigue abierto');

    // Tocar la pestaña activa vuelve a su raíz.
    await t.tap(find.text('Perfil').last);
    await t.pumpAndSettle();
    expect(find.text('Versión'), findsOneWidget);
  });

  testWidgets('el MaterialApp lleva el nombre del flavor', (t) async {
    await t.pumpAscendApp(config: AppConfig.prod);
    final app = t.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ascend');
  });

  testWidgets('la barra inferior no desborda a 1.3× en 360 dp', (t) async {
    t.view.physicalSize = const Size(360 * 3, 720 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpAscendApp(textScale: 1.3);
    for (final tab in ['Entrenar', 'Historial', 'Progreso', 'Perfil']) {
      await t.tap(find.text(tab));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('pestañas accesibles en claro y oscuro', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpAscendApp();
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(t, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
