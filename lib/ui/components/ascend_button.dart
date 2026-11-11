import 'package:flutter/material.dart';

/// Variantes de [AscendButton].
enum AscendButtonVariant {
  /// Relleno rojo: la acción principal de la pantalla (una sola).
  primary,

  /// Borde rojo: acciones alternativas.
  secondary,

  /// Solo texto: acciones de bajo peso (cancelar, ver más).
  ghost,
}

/// Botón de Ascend. Altura ≥ 52 dp, forma y colores del tema (§7).
class AscendButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AscendButtonVariant.primary,
    this.icon,
    this.expanded = false,
  });

  final String label;

  /// `null` deshabilita el botón.
  final VoidCallback? onPressed;
  final AscendButtonVariant variant;
  final IconData? icon;

  /// Ocupa todo el ancho disponible (acciones en el tercio inferior).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final iconWidget = icon == null ? null : Icon(icon, size: 20);
    final button = switch (variant) {
      AscendButtonVariant.primary =>
        iconWidget == null
            ? FilledButton(onPressed: onPressed, child: text)
            : FilledButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: text,
              ),
      AscendButtonVariant.secondary =>
        iconWidget == null
            ? OutlinedButton(onPressed: onPressed, child: text)
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: text,
              ),
      AscendButtonVariant.ghost =>
        iconWidget == null
            ? TextButton(onPressed: onPressed, child: text)
            : TextButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: text,
              ),
    };
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
