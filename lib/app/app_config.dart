import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Variante de compilación (§5.5.4).
enum Flavor { dev, prod }

/// Configuración que cambia según el flavor. Se crea en `main_<flavor>.dart`
/// y se inyecta con [appConfigProvider].
@immutable
class AppConfig {
  const new({
    required this.flavor,
    required this.appName,
    required this.databaseName,
    required this.loadSeedData,
  });

  /// «Ascend Dev»: datos de prueba, se puede borrar sin miedo.
  static const dev = AppConfig(
    flavor: Flavor.dev,
    appName: 'Ascend Dev',
    databaseName: 'ascend_dev.db',
    loadSeedData: true,
  );

  /// «Ascend»: los datos reales del usuario.
  static const prod = AppConfig(
    flavor: Flavor.prod,
    appName: 'Ascend',
    databaseName: 'ascend.db',
    loadSeedData: false,
  );

  final Flavor flavor;

  /// Nombre visible de la app (coincide con la etiqueta del lanzador).
  final String appName;

  /// Nombre del archivo SQLite; distinto por flavor para no mezclar datos.
  final String databaseName;

  /// Si se cargan datos semilla de prueba (solo dev).
  final bool loadSeedData;

  bool get isDev => flavor == Flavor.dev;
}

/// Configuración del flavor actual. Se sobrescribe en `bootstrap()`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'appConfigProvider debe sobrescribirse en bootstrap()',
  ),
);
