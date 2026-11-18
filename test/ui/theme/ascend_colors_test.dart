import 'dart:math' as math;

import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste WCAG 2.x entre dos colores opacos.
double contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) =>
        v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final la = lum(a);
  final lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('contraste WCAG AA (≥ 4.5:1) de los tokens de texto (§7.2)', () {
    for (final brightness in Brightness.values) {
      final theme = buildTheme(brightness);
      final c = theme.extension<AscendColors>()!;
      final s = theme.colorScheme;
      final bg = theme.scaffoldBackgroundColor;
      final pairs = <String, (Color, Color)>{
        'text/bg': (s.onSurface, bg),
        'text/surface': (s.onSurface, s.surface),
        'text/surfaceAlt': (s.onSurface, c.surfaceAlt),
        'textMuted/bg': (c.textMuted, bg),
        'textMuted/surface': (c.textMuted, s.surface),
        'textMuted/surfaceAlt': (c.textMuted, c.surfaceAlt),
        'primaryText/bg': (c.primaryText, bg),
        'primaryText/surface': (c.primaryText, s.surface),
        'onPrimary/primary': (s.onPrimary, s.primary),
        'success/bg': (c.success, bg),
        'warning/bg': (c.warning, bg),
        'danger/bg': (c.danger, bg),
      };
      for (final MapEntry(key: name, value: (fg, back)) in pairs.entries) {
        test('${brightness.name} · $name', () {
          expect(contrast(fg, back), greaterThanOrEqualTo(4.5));
        });
      }
    }
  });

  group('AscendColors', () {
    test('lerp en los extremos devuelve cada tema', () {
      final a = AscendColors.light;
      final b = AscendColors.dark;
      expect(a.lerp(b, 0).primaryText, a.primaryText);
      expect(a.lerp(b, 1).primaryText, b.primaryText);
      expect(a.lerp(b, 1).targetBand, b.targetBand);
      expect(a.lerp(null, 0.5), same(a));
    });

    test('lerp interpola todos los campos', () {
      final mid = AscendColors.light.lerp(AscendColors.dark, 0.5);
      final fields = <Color Function(AscendColors)>[
        (c) => c.surfaceAlt,
        (c) => c.textMuted,
        (c) => c.primaryText,
        (c) => c.border,
        (c) => c.success,
        (c) => c.warning,
        (c) => c.danger,
        (c) => c.streakTrained,
        (c) => c.streakRest,
        (c) => c.streakMissed,
        (c) => c.chartPrimary,
        (c) => c.chartMuted,
        (c) => c.targetBand,
      ];
      for (final f in fields) {
        final expected = Color.lerp(
          f(AscendColors.light),
          f(AscendColors.dark),
          0.5,
        );
        expect(f(mid), expected);
      }
    });

    test('copyWith cambia solo lo indicado', () {
      final c = AscendColors.light.copyWith(border: const Color(0xFF123456));
      expect(c.border, const Color(0xFF123456));
      expect(c.textMuted, AscendColors.light.textMuted);
      expect(c.streakRest, AscendColors.light.streakRest);
    });
  });

  group('buildTheme', () {
    test('usa Material 3, la paleta y las fuentes empaquetadas', () {
      final light = buildTheme(Brightness.light);
      final dark = buildTheme(Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme.primary, AscendPalette.crimson);
      expect(dark.colorScheme.primary, AscendPalette.ember);
      expect(light.scaffoldBackgroundColor, AscendPalette.bone);
      expect(dark.scaffoldBackgroundColor, AscendPalette.ink);
      expect(light.textTheme.displayLarge!.fontFamily, 'BarlowCondensed');
      expect(light.textTheme.bodyMedium!.fontFamily, 'IBMPlexSans');
      expect(dark.extension<AscendColors>(), same(AscendColors.dark));
    });

    test('los números grandes usan cifras tabulares', () {
      final t = buildTheme(Brightness.light).textTheme;
      for (final style in [t.displayLarge, t.displayMedium, t.displaySmall]) {
        expect(
          style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('botones con objetivo táctil de al menos 48 dp', () {
      final theme = buildTheme(Brightness.light);
      final size = theme.filledButtonTheme.style!.minimumSize!.resolve({})!;
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
