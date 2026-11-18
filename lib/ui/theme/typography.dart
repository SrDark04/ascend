import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:flutter/material.dart';

/// Familias empaquetadas en assets/fonts (licencia OFL, §7.3). No se
/// descarga nada en tiempo de ejecución.
abstract final class AscendFonts {
  static const display = 'BarlowCondensed';
  static const body = 'IBMPlexSans';
  static const mono = 'IBMPlexMono';

  /// Cifras de ancho fijo: los números no «bailan» al cambiar.
  static const tabular = [FontFeature.tabularFigures()];
}

/// Escala tipográfica (§7.3):
/// - display: Barlow Condensed ExtraBold 40–72, cifras tabulares;
/// - títulos: Barlow Condensed SemiBold 20–28, tracking +2 %;
/// - cuerpo: IBM Plex Sans 14–17;
/// - datos: IBM Plex Mono 13–15 (ver [ascendMonoStyle]).
TextTheme ascendTextTheme(ColorScheme scheme, AscendColors colors) {
  final on = scheme.onSurface;
  final muted = colors.textMuted;

  TextStyle display(double size) => TextStyle(
    fontFamily: AscendFonts.display,
    fontWeight: FontWeight.w800,
    fontSize: size,
    height: 1,
    color: on,
    fontFeatures: AscendFonts.tabular,
  );

  TextStyle heading(double size) => TextStyle(
    fontFamily: AscendFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: size,
    height: 1.15,
    letterSpacing: size * 0.02,
    color: on,
    fontFeatures: AscendFonts.tabular,
  );

  TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.4,
  }) => TextStyle(
    fontFamily: AscendFonts.body,
    fontWeight: weight,
    fontSize: size,
    height: height,
    color: color ?? on,
  );

  return TextTheme(
    displayLarge: display(72),
    displayMedium: display(56),
    displaySmall: display(40),
    headlineLarge: heading(28),
    headlineMedium: heading(24),
    headlineSmall: heading(20),
    titleLarge: heading(22),
    titleMedium: body(17, weight: FontWeight.w600, height: 1.3),
    titleSmall: body(15, weight: FontWeight.w600, height: 1.3),
    bodyLarge: body(17),
    bodyMedium: body(15),
    bodySmall: body(14, color: muted),
    labelLarge: body(15, weight: FontWeight.w600, height: 1.2),
    labelMedium: body(14, weight: FontWeight.w500, height: 1.2),
    labelSmall: body(13, weight: FontWeight.w500, height: 1.2, color: muted),
  );
}

/// Estilo para datos tabulares (IBM Plex Mono, 13–15).
TextStyle ascendMonoStyle(BuildContext context, {double size = 15}) {
  return TextStyle(
    fontFamily: AscendFonts.mono,
    fontSize: size,
    height: 1.3,
    color: Theme.of(context).colorScheme.onSurface,
    fontFeatures: AscendFonts.tabular,
  );
}
