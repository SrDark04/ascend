import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';

/// Estado vacío: ícono, título y mensaje centrados.
class EmptyState extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ascendColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AscendSpacing.xl),
        child: MergeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 56, color: colors.primaryText),
              ),
              const SizedBox(height: AscendSpacing.lg),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AscendSpacing.sm),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
