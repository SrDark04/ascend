import 'package:ascend/domain/streak/ascend_levels.dart';
import 'package:ascend/features/levels/level_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('muestra los 6 niveles en tema claro y en oscuro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpApp(const LevelGalleryScreen());

    expect(find.text('Tema claro'), findsOneWidget);
    expect(find.text('Tema oscuro'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(12));
    for (final level in defaultAscendLevels) {
      expect(find.text('Nivel ${level.number}'), findsNWidgets(2));
    }
    expect(find.text('Desde el primer día'), findsNWidgets(2));
    expect(find.text('Desde 365 días de racha'), findsNWidgets(2));
  });

  testWidgets('cada insignia tiene etiqueta para lector de pantalla', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpApp(const LevelGalleryScreen());

    expect(
      find.bySemanticsLabel(RegExp('Insignia del Nivel 1')),
      findsNWidgets(2),
    );
    handle.dispose();
  });

  testWidgets('no desborda con texto a 1.3× en un teléfono', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpApp(const LevelGalleryScreen(), textScale: 1.3);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cumple las guías de accesibilidad de Flutter', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const LevelGalleryScreen());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
