import 'package:ascend/app/app.dart';
import 'package:ascend/app/app_config.dart';
import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/common/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Dependencias falsas de la app completa, accesibles desde la prueba.
class AppFakes {
  final settings = FakeSettingsRepository();
  final log = FakeLog();
  final sharer = FakeFileSharer();
  final clock = FixedClock(DateTime(2026, 11, 10, 18));
}

extension PumpAscendApp on WidgetTester {
  /// Monta la app completa (router, tema, l10n) con dependencias falsas.
  Future<AppFakes> pumpAscendApp({
    AppConfig config = AppConfig.dev,
    AppFakes? fakes,
    double textScale = 1,
  }) async {
    final f = fakes ?? AppFakes();
    await pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            clockProvider.overrideWithValue(f.clock),
            appLogProvider.overrideWithValue(f.log),
            logStoreProvider.overrideWithValue(f.log),
            fileSharerProvider.overrideWithValue(f.sharer),
            settingsRepositoryProvider.overrideWithValue(f.settings),
          ],
          child: const AscendApp(),
        ),
      ),
    );
    await pumpAndSettle();
    return f;
  }
}
