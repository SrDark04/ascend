import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/features/settings/theme_controller.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/angled_card.dart';
import 'package:ascend/ui/components/ascend_button.dart';
import 'package:ascend/ui/components/ascend_chip.dart';
import 'package:ascend/ui/components/number_stepper.dart';
import 'package:ascend/ui/components/stat_tile.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:ascend/ui/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catálogo de tema y componentes para revisarlos en el celular (solo dev).
/// El selector de tema vive aquí hasta que exista Perfil (0.6).
class DesignSystemScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends ConsumerState<DesignSystemScreen> {
  double _kg = 60;
  double _reps = 8;
  int? _rir = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final preference = ref.watch(themePreferenceProvider);

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: AscendSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title.toUpperCase(), style: text.headlineSmall),
          ),
          const SizedBox(height: AscendSpacing.md),
          ...children,
        ],
      ),
    );

    const gap = SizedBox(height: AscendSpacing.md);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.designSystemTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AscendSpacing.lg),
        children: [
          section(l10n.themeSectionTitle, [
            SegmentedButton<ThemePreference>(
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {preference},
              onSelectionChanged: (s) =>
                  ref.read(themePreferenceProvider.notifier).select(s.first),
            ),
          ]),
          section(l10n.demoTypography, [
            Text('128', style: text.displayLarge),
            Text('62,5', style: text.displayMedium),
            Text(l10n.demoCardTitle.toUpperCase(), style: text.headlineMedium),
            Text(l10n.demoBodyText, style: text.bodyLarge),
            Text(l10n.demoCardBody, style: text.bodySmall),
            Text('100 × 5 @2  ·  e1RM 121,7', style: ascendMonoStyle(context)),
          ]),
          section(l10n.demoButtons, [
            AscendButton(
              label: l10n.demoPrimaryAction,
              icon: Icons.play_arrow,
              expanded: true,
              onPressed: () {},
            ),
            gap,
            AscendButton(
              label: l10n.demoSecondaryAction,
              variant: AscendButtonVariant.secondary,
              expanded: true,
              onPressed: () {},
            ),
            gap,
            AscendButton(
              label: l10n.demoGhostAction,
              variant: AscendButtonVariant.ghost,
              onPressed: () {},
            ),
            gap,
            AscendButton(label: l10n.demoDisabledAction, onPressed: null),
          ]),
          section(l10n.demoCards, [
            AngledCard(
              accent: true,
              child: StatTile(
                label: l10n.demoStreakLabel,
                value: '42',
                unit: l10n.unitDays,
                caption: l10n.demoBestStreak(57),
                icon: Icons.local_fire_department_outlined,
                emphasis: true,
              ),
            ),
            gap,
            AngledCard(
              onTap: () {},
              child: StatTile(
                label: l10n.demoVolumeLabel,
                value: '12.450',
                unit: l10n.unitKg,
              ),
            ),
          ]),
          section(l10n.demoInputs, [
            NumberStepper(
              label: l10n.loadLabel,
              value: _kg,
              step: 2.5,
              max: 500,
              unit: l10n.unitKg,
              onChanged: (v) => setState(() => _kg = v),
            ),
            gap,
            NumberStepper(
              label: l10n.repsLabel,
              value: _reps,
              min: 1,
              max: 100,
              onChanged: (v) => setState(() => _reps = v),
            ),
            gap,
            Text(l10n.rirLabel, style: text.labelMedium),
            const SizedBox(height: AscendSpacing.sm),
            Wrap(
              spacing: AscendSpacing.sm,
              runSpacing: AscendSpacing.sm,
              children: [
                for (var i = 0; i <= 5; i++)
                  AscendChip(
                    label: i == 5 ? l10n.rirFivePlus : '$i',
                    semanticLabel: i == 5
                        ? l10n.rirFivePlusSemantics
                        : l10n.rirSemantics('$i'),
                    selected: _rir == i,
                    onSelected: (s) => setState(() => _rir = s ? i : null),
                  ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
