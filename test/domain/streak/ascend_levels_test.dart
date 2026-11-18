import 'package:ascend/domain/streak/ascend_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultAscendLevels', () {
    test('son 6 niveles válidos con los umbrales definidos', () {
      expect(defaultAscendLevels, hasLength(6));
      expect(() => validateAscendLevels(defaultAscendLevels), returnsNormally);
      expect(defaultAscendLevels.map((l) => l.minStreakDays), [
        0,
        30,
        60,
        120,
        180,
        365,
      ]);
    });

    test('cada nivel apunta a su asset y a su clave i18n', () {
      for (final level in defaultAscendLevels) {
        final n = level.number;
        expect(level.assetPath, 'assets/images/streak/nivel_$n.png');
        expect(level.nameKey, 'ascendLevel$n');
      }
    });
  });

  group('levelForStreak', () {
    // (días de racha, nivel esperado): bordes de cada umbral.
    const cases = <(int, int)>[
      (0, 1),
      (29, 1),
      (30, 2),
      (59, 2),
      (60, 3),
      (119, 3),
      (120, 4),
      (179, 4),
      (180, 5),
      (364, 5),
      (365, 6),
      (10000, 6),
    ];
    for (final (days, expected) in cases) {
      test('$days días → nivel $expected', () {
        expect(levelForStreak(days).number, expected);
      });
    }

    test('rechaza días negativos', () {
      expect(() => levelForStreak(-1), throwsArgumentError);
    });

    test('acepta umbrales configurables', () {
      const custom = [
        AscendLevel(number: 1, minStreakDays: 0, assetPath: 'a', nameKey: 'a'),
        AscendLevel(number: 2, minStreakDays: 3, assetPath: 'b', nameKey: 'b'),
      ];
      expect(levelForStreak(2, levels: custom).number, 1);
      expect(levelForStreak(3, levels: custom).number, 2);
    });

    test('es monótono: más días nunca bajan de nivel', () {
      var previous = 1;
      for (var d = 0; d <= 400; d++) {
        final n = levelForStreak(d).number;
        expect(n, greaterThanOrEqualTo(previous));
        previous = n;
      }
    });
  });

  group('validateAscendLevels', () {
    AscendLevel lvl(int n, int min) =>
        AscendLevel(number: n, minStreakDays: min, assetPath: '', nameKey: '');

    test('rechaza una tabla vacía', () {
      expect(() => validateAscendLevels(const []), throwsArgumentError);
    });

    test('rechaza que el primer umbral no sea 0', () {
      expect(() => validateAscendLevels([lvl(1, 1)]), throwsArgumentError);
    });

    test('rechaza umbrales que no crecen', () {
      expect(
        () => validateAscendLevels([lvl(1, 0), lvl(2, 7), lvl(3, 7)]),
        throwsArgumentError,
      );
    });

    test('rechaza numeración fuera de orden', () {
      expect(
        () => validateAscendLevels([lvl(1, 0), lvl(3, 7)]),
        throwsArgumentError,
      );
    });
  });
}
