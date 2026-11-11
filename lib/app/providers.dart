import 'package:ascend/application/ports/app_log.dart';
import 'package:ascend/application/ports/file_sharer.dart';
import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/common/clock.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/infrastructure/preferences/shared_prefs_settings_repository.dart';
import 'package:ascend/infrastructure/sharing/share_plus_file_sharer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de composición: une los puertos con su implementación. En pruebas
/// se sobrescriben con `ProviderScope(overrides: …)`.

/// Hora actual. Nunca llamar a `DateTime.now()` fuera de aquí.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPrefsSettingsRepository(),
);

final fileSharerProvider = Provider<FileSharer>(
  (ref) => const SharePlusFileSharer(),
);

/// Registro local. Se crea en `bootstrap()` (necesita el directorio de la
/// app) y se inyecta con override.
final appLogProvider = Provider<AppLog>(
  (ref) => throw UnimplementedError('appLogProvider se crea en bootstrap()'),
);

final logStoreProvider = Provider<LogStore>(
  (ref) => throw UnimplementedError('logStoreProvider se crea en bootstrap()'),
);

/// Ajustes leídos en `bootstrap()` antes del primer frame, para que la app
/// no arranque con un valor y cambie al instante.
final initialThemePreferenceProvider = Provider<ThemePreference>(
  (ref) => ThemePreference.system,
);

final initialWeightUnitProvider = Provider<WeightUnit>((ref) => WeightUnit.kg);
