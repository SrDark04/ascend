import 'dart:async';

import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ficha seleccionable (p. ej. RIR 0–5+). La selección no depende solo del
/// color: la ficha elegida muestra además un ✓ y lo anuncia el lector.
class AscendChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
    this.semanticLabel,
  });

  final String label;
  final bool selected;

  /// `null` deshabilita la ficha.
  final ValueChanged<bool>? onSelected;

  /// Texto para el lector de pantalla si [label] es ambiguo (p. ej. «5+»).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.ascendColors;
    final enabled = onSelected != null;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final bg = selected ? scheme.primary : colors.surfaceAlt;
    final borderColor = selected ? scheme.primary : colors.border;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AscendShapes.radius)),
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: bg,
          shape: shape.copyWith(side: BorderSide(color: borderColor)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    onSelected!(!selected);
                  }
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AscendShapes.minTouch,
                minHeight: AscendShapes.minTouch,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AscendSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      Icon(Icons.check, size: 16, color: fg),
                      const SizedBox(width: AscendSpacing.xs),
                    ],
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
