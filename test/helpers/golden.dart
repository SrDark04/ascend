import 'package:alchemist/alchemist.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';

/// Escenario en tema claro y en oscuro para un componente.
List<GoldenTestScenario> themedScenarios(
  String name,
  WidgetBuilder builder, {
  double width = 360,
}) => [
  for (final b in Brightness.values)
    GoldenTestScenario(
      name: '$name · ${b == Brightness.light ? 'claro' : 'oscuro'}',
      child: AscendGoldenFrame(brightness: b, width: width, builder: builder),
    ),
];

/// Tema de Ascend + l10n en español alrededor de un componente.
class AscendGoldenFrame extends StatelessWidget {
  const new({
    required this.brightness,
    required this.builder,
    super.key,
    this.width = 360,
  });

  final Brightness brightness;
  final WidgetBuilder builder;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = buildTheme(brightness);
    return Localizations(
      locale: const Locale('es'),
      delegates: AppLocalizations.localizationsDelegates,
      child: Theme(
        data: theme,
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: width,
              child: Builder(builder: builder),
            ),
          ),
        ),
      ),
    );
  }
}
