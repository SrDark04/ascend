import 'package:flutter/material.dart';

/// Colores base de la marca (§7.2). No usar directamente en widgets:
/// pasar por `Theme.of(context).colorScheme` o [AscendColors].
abstract final class AscendPalette {
  static const crimson = Color(0xFFC1121F);
  static const ember = Color(0xFFE5383B);
  static const emberText = Color(0xFFFF4D57);
  static const blood = Color(0xFF7A0C14);
  static const ink = Color(0xFF0B0B0D);
  static const ink2 = Color(0xFF17171B);
  static const ink3 = Color(0xFF222228);
  static const bone = Color(0xFFF7F5F2);
  static const white = Color(0xFFFFFFFF);

  // Tokens de la tabla §7.2 que no están arriba.
  static const boneAlt = Color(0xFFEFECE8); // surfaceAlt claro
  static const textDark = Color(0xFFF5F5F5); // text oscuro
  static const mutedLight = Color(0xFF52525B); // textMuted claro
  static const mutedDark = Color(0xFFA1A1AA); // textMuted oscuro
  static const borderLight = Color(0xFFD9D4CE);
  static const borderDark = Color(0xFF2E2E35);
  static const successLight = Color(0xFF1F7A4D);
  static const successDark = Color(0xFF3DDC97);
  static const warningLight = Color(0xFFB45309);
  static const warningDark = Color(0xFFF5A524);
}

/// Tokens propios que Material no cubre (§7.2): texto secundario y rojo de
/// texto, estados (siempre acompañados de ícono + texto), racha y gráficas.
@immutable
class AscendColors extends ThemeExtension<AscendColors> {
  const new({
    required this.surfaceAlt,
    required this.textMuted,
    required this.primaryText,
    required this.primaryDeep,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.streakTrained,
    required this.streakRest,
    required this.streakMissed,
    required this.chartPrimary,
    required this.chartMuted,
    required this.targetBand,
  });

  /// Tema claro. Los colores de racha y gráficas derivan de la paleta:
  /// rojo intenso = entrenado, rojo tenue = descanso, gris = perdido (§4.6).
  static final light = AscendColors(
    surfaceAlt: AscendPalette.boneAlt,
    textMuted: AscendPalette.mutedLight,
    primaryText: AscendPalette.crimson,
    primaryDeep: AscendPalette.blood,
    border: AscendPalette.borderLight,
    success: AscendPalette.successLight,
    warning: AscendPalette.warningLight,
    danger: AscendPalette.crimson,
    streakTrained: AscendPalette.crimson,
    streakRest: Color.alphaBlend(
      AscendPalette.crimson.withValues(alpha: 0.30),
      AscendPalette.bone,
    ),
    streakMissed: AscendPalette.borderLight,
    chartPrimary: AscendPalette.crimson,
    chartMuted: AscendPalette.mutedLight,
    targetBand: AscendPalette.crimson.withValues(alpha: 0.12),
  );

  /// Tema oscuro.
  static final dark = AscendColors(
    surfaceAlt: AscendPalette.ink3,
    textMuted: AscendPalette.mutedDark,
    primaryText: AscendPalette.emberText,
    primaryDeep: AscendPalette.blood,
    border: AscendPalette.borderDark,
    success: AscendPalette.successDark,
    warning: AscendPalette.warningDark,
    danger: AscendPalette.emberText,
    streakTrained: AscendPalette.ember,
    streakRest: Color.alphaBlend(
      AscendPalette.ember.withValues(alpha: 0.35),
      AscendPalette.ink,
    ),
    streakMissed: AscendPalette.borderDark,
    chartPrimary: AscendPalette.ember,
    chartMuted: AscendPalette.mutedDark,
    targetBand: AscendPalette.ember.withValues(alpha: 0.16),
  );

  /// Inputs, filas alternas.
  final Color surfaceAlt;

  /// Texto secundario (≥ 7:1 sobre el fondo).
  final Color textMuted;

  /// Rojo para texto e íconos (más claro en oscuro para mantener contraste).
  final Color primaryText;

  /// Gradientes y sombras de acento.
  final Color primaryDeep;

  /// Divisores y bordes de tarjeta.
  final Color border;

  /// Estado OK; siempre con ícono ✓.
  final Color success;

  /// Precaución; siempre con ícono ⚠.
  final Color warning;

  /// Alerta; siempre con ícono ⛔ y texto (el rojo también es la marca).
  final Color danger;

  final Color streakTrained;
  final Color streakRest;
  final Color streakMissed;
  final Color chartPrimary;
  final Color chartMuted;
  final Color targetBand;

  @override
  AscendColors copyWith({
    Color? surfaceAlt,
    Color? textMuted,
    Color? primaryText,
    Color? primaryDeep,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? streakTrained,
    Color? streakRest,
    Color? streakMissed,
    Color? chartPrimary,
    Color? chartMuted,
    Color? targetBand,
  }) {
    return AscendColors(
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textMuted: textMuted ?? this.textMuted,
      primaryText: primaryText ?? this.primaryText,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      streakTrained: streakTrained ?? this.streakTrained,
      streakRest: streakRest ?? this.streakRest,
      streakMissed: streakMissed ?? this.streakMissed,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartMuted: chartMuted ?? this.chartMuted,
      targetBand: targetBand ?? this.targetBand,
    );
  }

  @override
  AscendColors lerp(AscendColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AscendColors(
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      textMuted: l(textMuted, other.textMuted),
      primaryText: l(primaryText, other.primaryText),
      primaryDeep: l(primaryDeep, other.primaryDeep),
      border: l(border, other.border),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
      streakTrained: l(streakTrained, other.streakTrained),
      streakRest: l(streakRest, other.streakRest),
      streakMissed: l(streakMissed, other.streakMissed),
      chartPrimary: l(chartPrimary, other.chartPrimary),
      chartMuted: l(chartMuted, other.chartMuted),
      targetBand: l(targetBand, other.targetBand),
    );
  }
}

/// Acceso corto: `context.ascendColors`.
extension AscendColorsContext on BuildContext {
  AscendColors get ascendColors => Theme.of(this).extension<AscendColors>()!;
}
