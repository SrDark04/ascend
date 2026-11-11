import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Arranque común a todos los flavors. Aquí se inicializarán la BD,
/// el logger y la captura de errores (0.6–0.7).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const AscendApp(),
    ),
  );
}
