import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/design_system_screen.dart';
import 'package:ascend/features/levels/level_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_ascend_app.dart';

Future<AppFakes> openDiagnostics(
  WidgetTester t, {
  AppConfig config = AppConfig.dev,
  AppFakes? fakes,
}) async {
  final f = await t.pumpAscendApp(config: config, fakes: fakes);
  await t.tap(find.text('Perfil'));
  await t.pumpAndSettle();
  for (var i = 0; i < 7; i++) {
    await t.tap(find.text('Versión'));
    await t.pump(const Duration(milliseconds: 50));
  }
  await t.pumpAndSettle();
  return f;
}

void main() {
  testWidgets('dev: datos, sin errores y herramientas de desarrollo', (
    t,
  ) async {
    await openDiagnostics(t);
    expect(find.text('Variante: dev'), findsOneWidget);
    expect(find.text('Base de datos: ascend_dev.db'), findsOneWidget);
    expect(find.text('Sin errores registrados'), findsOneWidget);

    await t.scrollUntilVisible(find.text('Galería de niveles'), 200);
    await t.tap(find.text('Galería de niveles'));
    await t.pumpAndSettle();
    expect(find.byType(LevelGalleryScreen), findsOneWidget);
  });

  testWidgets('dev: abre el sistema de diseño', (t) async {
    await openDiagnostics(t);
    await t.scrollUntilVisible(find.text('Sistema de diseño'), 200);
    await t.tap(find.text('Sistema de diseño'));
    await t.pumpAndSettle();
    expect(find.byType(DesignSystemScreen), findsOneWidget);
  });

  testWidgets('prod: sin herramientas de desarrollo', (t) async {
    await openDiagnostics(t, config: AppConfig.prod);
    expect(find.text('Variante: prod'), findsOneWidget);
    expect(find.text('Galería de niveles'), findsNothing);
    expect(find.text('Sistema de diseño'), findsNothing);
  });

  testWidgets('muestra los últimos errores registrados', (t) async {
    final fakes = AppFakes()..log.error('Algo falló', StateError('x'));
    await openDiagnostics(t, fakes: fakes);
    expect(find.textContaining('Algo falló'), findsOneWidget);
  });

  testWidgets('«Exportar log» genera el archivo y lo comparte', (t) async {
    final f = await openDiagnostics(t);
    await t.scrollUntilVisible(find.text('Exportar log'), 200);
    await t.tap(find.text('Exportar log'));
    await t.pumpAndSettle();
    expect(f.sharer.shared, [f.log.exportPath]);
    expect(f.log.lastHeader, 'Ascend Dev 0.1.0+1 (dev)');
    expect(find.byType(SnackBar), findsNothing);
  });
}
