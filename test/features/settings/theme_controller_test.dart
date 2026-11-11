import 'package:ascend/app/providers.dart';
import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/features/settings/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference stored = ThemePreference.system;
  int saves = 0;

  @override
  Future<ThemePreference> loadThemePreference() async => stored;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    stored = preference;
    saves++;
  }
}

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
    expect(repo.stored, ThemePreference.light);
    expect(repo.saves, 1);
  });

  test('elegir el mismo tema no vuelve a guardar', () async {
    await container
        .read(themePreferenceProvider.notifier)
        .select(ThemePreference.dark);
    expect(repo.saves, 0);
  });

  test('se traduce a ThemeMode', () {
    expect(ThemePreference.system.themeMode, ThemeMode.system);
    expect(ThemePreference.light.themeMode, ThemeMode.light);
    expect(ThemePreference.dark.themeMode, ThemeMode.dark);
  });
}
