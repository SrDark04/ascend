// goldenTest registra la prueba y devuelve un Future que no se espera.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:ascend/ui/components/angled_card.dart';
import 'package:ascend/ui/components/ascend_button.dart';
import 'package:ascend/ui/components/ascend_chip.dart';
import 'package:ascend/ui/components/number_stepper.dart';
import 'package:ascend/ui/components/stat_tile.dart';
import 'package:flutter/material.dart';

import '../../helpers/golden.dart';

void main() {
  goldenTest(
    'AscendButton en claro y oscuro',
    fileName: 'ascend_button',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final v in AscendButtonVariant.values)
          ...themedScenarios(
            v.name,
            (_) => AscendButton(
              label: 'Empezar sesión',
              variant: v,
              icon: Icons.play_arrow,
              onPressed: () {},
            ),
            width: 240,
          ),
        ...themedScenarios(
          'deshabilitado',
          (_) => const AscendButton(label: 'No disponible', onPressed: null),
          width: 240,
        ),
      ],
    ),
  );

  goldenTest(
    'AngledCard en claro y oscuro',
    fileName: 'angled_card',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final accent in [false, true])
          ...themedScenarios(
            accent ? 'acento' : 'normal',
            (_) => AngledCard(
              accent: accent,
              child: const Text('Press de banca · 100 kg × 5'),
            ),
            width: 260,
          ),
      ],
    ),
  );

  goldenTest(
    'StatTile en claro y oscuro',
    fileName: 'stat_tile',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        ...themedScenarios(
          'énfasis',
          (_) => const StatTile(
            label: 'Racha actual',
            value: '42',
            unit: 'días',
            caption: 'Mejor: 57 días',
            icon: Icons.local_fire_department_outlined,
            emphasis: true,
          ),
          width: 220,
        ),
        ...themedScenarios(
          'normal',
          (_) => const StatTile(label: 'Tonelaje', value: '12.450', unit: 'kg'),
          width: 220,
        ),
      ],
    ),
  );

  goldenTest(
    'NumberStepper en claro y oscuro',
    fileName: 'number_stepper',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        ...themedScenarios(
          'kg',
          (_) => NumberStepper(
            label: 'Carga',
            unit: 'kg',
            value: 62.5,
            step: 2.5,
            onChanged: (_) {},
          ),
          width: 300,
        ),
        ...themedScenarios(
          'en el mínimo',
          (_) => NumberStepper(
            label: 'Repeticiones',
            value: 1,
            min: 1,
            onChanged: (_) {},
          ),
          width: 300,
        ),
      ],
    ),
  );

  goldenTest(
    'AscendChip en claro y oscuro',
    fileName: 'ascend_chip',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        ...themedScenarios(
          'RIR',
          (_) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i <= 5; i++)
                AscendChip(
                  label: i == 5 ? '5+' : '$i',
                  selected: i == 2,
                  onSelected: (_) {},
                ),
            ],
          ),
          width: 300,
        ),
        ...themedScenarios(
          'deshabilitada',
          (_) => const Align(
            alignment: Alignment.centerLeft,
            child: AscendChip(label: '3', selected: false, onSelected: null),
          ),
          width: 300,
        ),
      ],
    ),
  );
}
