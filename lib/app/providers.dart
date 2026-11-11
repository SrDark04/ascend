import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/infrastructure/preferences/shared_prefs_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición: une los puertos con su implementación. En pruebas
/// se sobrescriben con `ProviderScope(overrides: …)`.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPrefsSettingsRepository(),
);

/// Tema guardado, leído en `bootstrap()` antes del primer frame para que
/// la app no arranque con un tema y cambie al instante.
final initialThemePreferenceProvider = Provider<ThemePreference>(
  (ref) => ThemePreference.system,
);
