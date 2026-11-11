import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
import 'package:ascend/features/levels/level_gallery_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('en dev muestra la galería de niveles y la abre', (tester) async {
    await tester.pumpApp(const DiagnosticsScreen());
    expect(find.text('Variante: dev'), findsOneWidget);
    expect(find.text('Base de datos: ascend_dev.db'), findsOneWidget);

    await tester.tap(find.text('Galería de niveles'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelGalleryScreen), findsOneWidget);
  });

  testWidgets('en prod no ofrece la galería de niveles', (tester) async {
    await tester.pumpApp(const DiagnosticsScreen(), config: AppConfig.prod);
    expect(find.text('Variante: prod'), findsOneWidget);
    expect(find.text('Galería de niveles'), findsNothing);
  });
}
