import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/features/settings/theme_controller.dart';
import 'package:ascend/features/settings/weight_unit_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeSettingsRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeSettingsRepository();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        initialThemePreferenceProvider.overrideWithValue(ThemePreference.dark),
      ],
    );
    addTearDown(container.dispose);
  });

  test('arranca con el tema leído en bootstrap', () {
    expect(container.read(themePreferenceProvider), ThemePreference.dark);
  });

  test('select cambia el estado y lo guarda', () async {
    await container
        .read(themePreferenceProvider.notifier)
        .select(ThemePreference.light);
    expect(container.read(themePreferenceProvider), ThemePreference.light);
    expect(repo.theme, ThemePreference.light);
  });

  test('la unidad de carga cambia y se guarda', () async {
    expect(container.read(weightUnitProvider), WeightUnit.kg);
    await container.read(weightUnitProvider.notifier).select(WeightUnit.lb);
    expect(container.read(weightUnitProvider), WeightUnit.lb);
    expect(repo.unit, WeightUnit.lb);
  });

  test('se traduce a ThemeMode', () {
    expect(ThemePreference.system.themeMode, ThemeMode.system);
    expect(ThemePreference.light.themeMode, ThemeMode.light);
    expect(ThemePreference.dark.themeMode, ThemeMode.dark);
  });
}
