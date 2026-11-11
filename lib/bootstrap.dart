import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:ascend/app/licenses.dart';
import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/infrastructure/preferences/shared_prefs_settings_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Arranque común a todos los flavors. Aquí se inicializarán la BD,
/// el logger y la captura de errores (0.6–0.7).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  final settings = SharedPrefsSettingsRepository();
  var theme = ThemePreference.system;
  try {
    theme = await settings.loadThemePreference();
  } on Exception {
    // Si el almacenamiento falla, se arranca con el tema del sistema.
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        settingsRepositoryProvider.overrideWithValue(settings),
        initialThemePreferenceProvider.overrideWithValue(theme),
      ],
      child: const AscendApp(),
    ),
  );
}
