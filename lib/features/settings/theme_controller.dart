import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tema elegido por el usuario. Cambia al instante y se guarda en segundo
/// plano.
final themePreferenceProvider =
    NotifierProvider<ThemePreferenceController, ThemePreference>(
      ThemePreferenceController.new,
    );

class ThemePreferenceController extends Notifier<ThemePreference> {
  @override
  ThemePreference build() => ref.watch(initialThemePreferenceProvider);

  Future<void> select(ThemePreference preference) async {
    if (preference == state) return;
    state = preference;
    await ref.read(settingsRepositoryProvider).saveThemePreference(preference);
  }
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
