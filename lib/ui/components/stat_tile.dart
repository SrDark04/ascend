import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';

/// Métrica con número grande (§7.1, principio 2): etiqueta, valor con
/// cifras tabulares, unidad y nota opcional.
class StatTile extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    super.key,
    this.unit,
    this.caption,
    this.icon,
    this.emphasis = false,
  });

  final String label;

  /// Ya formateado según la configuración regional.
  final String value;
  final String? unit;
  final String? caption;
  final IconData? icon;

  /// Valor en rojo (p. ej. la racha actual).
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ascendColors;
    final valueStyle = theme.textTheme.displaySmall!.copyWith(
      color: emphasis ? colors.primaryText : null,
    );
    final semantic = [label, value, ?unit, ?caption].join(', ');
    return Semantics(
      container: true,
      label: semantic,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.textMuted),
                const SizedBox(width: AscendSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AscendSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: value, style: valueStyle),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AscendSpacing.xs),
            Text(caption!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
