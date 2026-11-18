/// Niveles de ascenso: las 6 insignias que se desbloquean según los días de
/// racha (§4.6). Dart puro, sin Flutter.
///
/// En la lámina original aparecen como «FASE N»; en el código se llaman
/// «niveles de ascenso» para no confundirlos con las fases del roadmap.
///
/// La lógica completa de rachas (motor, tokens, desbloqueo persistente)
/// pertenece a la Fase 2; aquí solo está el modelo y la búsqueda de nivel.
library;

/// Un nivel de ascenso.
final class AscendLevel {
  const new({
    required this.number,
    required this.minStreakDays,
    required this.assetPath,
    required this.nameKey,
  });

  /// Número del nivel, de 1 a N.
  final int number;

  /// Días de racha mínimos para alcanzar el nivel (el nivel 1 empieza en 0).
  final int minStreakDays;

  /// Ruta del asset de la insignia (PNG con fondo transparente).
  final String assetPath;

  /// Clave del nombre en los ARB (`lib/l10n/app_es.arb`).
  final String nameKey;

  @override
  String toString() => 'AscendLevel($number, ≥$minStreakDays días)';
}

/// Umbrales en días de racha, definidos por el usuario el 2026-11-10:
/// 0 · 30 · 60 · 120 · 180 · 365. Siguen siendo configurables (parámetro
/// `levels`); en la Fase 2 (2.9) se confirma si se desbloquean por la mejor
/// racha o por la actual.
const List<AscendLevel> defaultAscendLevels = [
  AscendLevel(
    number: 1,
    minStreakDays: 0,
    assetPath: 'assets/images/streak/nivel_1.png',
    nameKey: 'ascendLevel1',
  ),
  AscendLevel(
    number: 2,
    minStreakDays: 30,
    assetPath: 'assets/images/streak/nivel_2.png',
    nameKey: 'ascendLevel2',
  ),
  AscendLevel(
    number: 3,
    minStreakDays: 60,
    assetPath: 'assets/images/streak/nivel_3.png',
    nameKey: 'ascendLevel3',
  ),
  AscendLevel(
    number: 4,
    minStreakDays: 120,
    assetPath: 'assets/images/streak/nivel_4.png',
    nameKey: 'ascendLevel4',
  ),
  AscendLevel(
    number: 5,
    minStreakDays: 180,
    assetPath: 'assets/images/streak/nivel_5.png',
    nameKey: 'ascendLevel5',
  ),
  AscendLevel(
    number: 6,
    minStreakDays: 365,
    assetPath: 'assets/images/streak/nivel_6.png',
    nameKey: 'ascendLevel6',
  ),
];

/// Comprueba que una tabla de niveles es coherente: no vacía, numerada
/// 1..N, el primer umbral es 0 y los umbrales crecen estrictamente.
///
/// Lanza [ArgumentError] si no lo es.
void validateAscendLevels(List<AscendLevel> levels) {
  if (levels.isEmpty) {
    throw ArgumentError.value(levels, 'levels', 'no puede estar vacía');
  }
  if (levels.first.minStreakDays != 0) {
    throw ArgumentError.value(
      levels.first.minStreakDays,
      'levels.first.minStreakDays',
      'el primer nivel debe empezar en 0 días',
    );
  }
  for (var i = 0; i < levels.length; i++) {
    if (levels[i].number != i + 1) {
      throw ArgumentError.value(
        levels[i].number,
        'levels[$i].number',
        'los niveles deben numerarse 1..N en orden',
      );
    }
    if (i > 0 && levels[i].minStreakDays <= levels[i - 1].minStreakDays) {
      throw ArgumentError.value(
        levels[i].minStreakDays,
        'levels[$i].minStreakDays',
        'los umbrales deben crecer estrictamente',
      );
    }
  }
}

/// Nivel que corresponde a [days] días de racha: el más alto cuyo umbral
/// es ≤ [days].
///
/// [levels] permite configurar los umbrales; debe cumplir
/// [validateAscendLevels]. Lanza [ArgumentError] si [days] es negativo.
AscendLevel levelForStreak(
  int days, {
  List<AscendLevel> levels = defaultAscendLevels,
}) {
  if (days < 0) {
    throw ArgumentError.value(days, 'days', 'no puede ser negativo');
  }
  validateAscendLevels(levels);
  var result = levels.first;
  for (final level in levels) {
    if (level.minStreakDays > days) break;
    result = level;
  }
  return result;
}
