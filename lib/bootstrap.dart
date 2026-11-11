import 'dart:async';
import 'dart:io';

import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:ascend/app/app_version.dart';
import 'package:ascend/app/error_handlers.dart';
import 'package:ascend/app/licenses.dart';
import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/common/clock.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/infrastructure/logging/rotating_file_log.dart';
import 'package:ascend/infrastructure/preferences/shared_prefs_settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Arranque común a todos los flavors: registro local, captura de errores,
/// ajustes guardados y `ProviderScope`. La BD se abre aquí en 0.7.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();

  const clock = SystemClock();
  final supportDir = await getApplicationSupportDirectory();
  final log = RotatingFileLog(
    directory: Directory('${supportDir.path}/logs'),
    clock: clock,
    echoToConsole: kDebugMode,
  );
  installErrorHandlers(log);
  log.info('Arranque ${config.flavor.name} $appVersion+$appBuildNumber');

  final settings = SharedPrefsSettingsRepository();
  var theme = ThemePreference.system;
  var unit = WeightUnit.kg;
  try {
    theme = await settings.loadThemePreference();
    unit = await settings.loadWeightUnit();
  } on Exception catch (e, s) {
    // Si el almacenamiento falla, se arranca con los valores por defecto.
    log.warning('No se pudieron leer los ajustes', e, s);
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        clockProvider.overrideWithValue(clock),
        appLogProvider.overrideWithValue(log),
        logStoreProvider.overrideWithValue(log),
        settingsRepositoryProvider.overrideWithValue(settings),
        initialThemePreferenceProvider.overrideWithValue(theme),
        initialWeightUnitProvider.overrideWithValue(unit),
      ],
      child: const AscendApp(),
    ),
  );
}
