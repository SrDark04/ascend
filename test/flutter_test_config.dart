import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Goldens (alchemist):
/// - `goldens/ci/`: texto sustituido por bloques; estables en cualquier
///   máquina. Son los que protegen contra regresiones de layout.
/// - `goldens/linux/`: con las fuentes reales, para revisión visual.
Future<void> testExecutable(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.linux},
      ),
    ),
    run: () async => await testMain(),
  );
}
