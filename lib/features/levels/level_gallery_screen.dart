import 'package:ascend/domain/streak/ascend_levels.dart';
import 'package:ascend/features/levels/ascend_level_l10n.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';

/// Galería de los 6 niveles de ascenso en tema claro y oscuro, para revisar
/// las insignias. Solo accesible desde Diagnóstico en el flavor dev.
///
/// La galería para el usuario (siluetas, días que faltan) es de la Fase 2.
class LevelGalleryScreen extends StatelessWidget {
  const new({super.key, this.levels = defaultAscendLevels});

  final List<AscendLevel> levels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.levelGalleryTitle)),
      body: ListView(
        children: [
          _ThemedSection(
            brightness: Brightness.light,
            title: l10n.themeLight,
            levels: levels,
          ),
          _ThemedSection(
            brightness: Brightness.dark,
            title: l10n.themeDark,
            levels: levels,
          ),
        ],
      ),
    );
  }
}

class _ThemedSection extends StatelessWidget {
  const new({
    required this.brightness,
    required this.title,
    required this.levels,
  });

  final Brightness brightness;
  final String title;
  final List<AscendLevel> levels;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(brightness),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Material(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      final columns = (constraints.maxWidth / 180)
                          .floor()
                          .clamp(2, 6);
                      final tileWidth =
                          (constraints.maxWidth - spacing * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: 16,
                        children: [
                          for (final level in levels)
                            SizedBox(
                              width: tileWidth,
                              child: _LevelTile(level: level),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const new({required this.level});

  final AscendLevel level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = l10n.ascendLevelName(level);
    return MergeSemantics(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Decodifica al tamaño mostrado, no a 768 px.
                final dpr = MediaQuery.devicePixelRatioOf(context);
                return Semantics(
                  image: true,
                  label: l10n.levelBadgeSemantics(name),
                  child: Image.asset(
                    level.assetPath,
                    cacheWidth: (constraints.maxWidth * dpr).round(),
                    excludeFromSemantics: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.levelMinStreakDays(level.minStreakDays),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
