import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Escala de espaciado de 4 pt (§7.3).
abstract final class AscendSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Radios y tamaños comunes.
abstract final class AscendShapes {
  /// Radio base (§7.3).
  static const radius = 6.0;

  /// Lado de la esquina cortada de las tarjetas destacadas.
  static const cut = 16.0;

  /// Objetivo táctil mínimo (Material / WCAG).
  static const minTouch = 48.0;

  /// Altura de los botones principales (pulgar primero, §7.1).
  static const buttonHeight = 52.0;
}

/// Tema Material 3 de Ascend para [brightness] (§7.2).
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = dark ? AscendColors.dark : AscendColors.light;
  final bg = dark ? AscendPalette.ink : AscendPalette.bone;
  final surface = dark ? AscendPalette.ink2 : AscendPalette.white;
  final onSurface = dark ? AscendPalette.textDark : AscendPalette.ink;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? AscendPalette.ember : AscendPalette.crimson,
    onPrimary: dark ? AscendPalette.ink : AscendPalette.white,
    secondary: AscendPalette.blood,
    onSecondary: AscendPalette.white,
    error: dark ? AscendPalette.emberText : AscendPalette.crimson,
    onError: dark ? AscendPalette.ink : AscendPalette.white,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: colors.textMuted,
    surfaceContainerLowest: bg,
    surfaceContainerLow: surface,
    surfaceContainer: surface,
    surfaceContainerHigh: surface,
    surfaceContainerHighest: colors.surfaceAlt,
    outline: colors.border,
    outlineVariant: colors.border,
    surfaceTint: Colors.transparent,
  );
  final text = ascendTextTheme(scheme, colors);
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AscendShapes.radius)),
  );
  const buttonSize = Size(AscendShapes.minTouch, AscendShapes.buttonHeight);
  const buttonPadding = EdgeInsets.symmetric(horizontal: AscendSpacing.xl);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    canvasColor: bg,
    fontFamily: AscendFonts.body,
    textTheme: text,
    extensions: [colors],
    materialTapTargetSize: MaterialTapTargetSize.padded,
    dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.headlineSmall,
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shape.copyWith(side: BorderSide(color: colors.border)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        padding: buttonPadding,
        shape: shape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        padding: buttonPadding,
        shape: shape,
        foregroundColor: colors.primaryText,
        side: BorderSide(color: colors.primaryText, width: 1.5),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: buttonSize,
        padding: buttonPadding,
        shape: shape,
        foregroundColor: colors.primaryText,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AscendShapes.minTouch),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AscendShapes.radius),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AscendShapes.radius),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AscendShapes.radius),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: shape,
      titleTextStyle: text.headlineSmall,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.textMuted,
      minTileHeight: AscendShapes.minTouch + AscendSpacing.sm,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: const Size.square(AscendShapes.minTouch),
        selectedBackgroundColor: scheme.primary,
        selectedForegroundColor: scheme.onPrimary,
        side: BorderSide(color: colors.border),
        textStyle: text.labelMedium,
      ),
    ),
  );
}
