import 'dart:io';

import 'package:ascend/domain/streak/ascend_levels.dart';
import 'package:flutter_test/flutter_test.dart';

/// Los assets los genera tool/prepare_assets.py; si alguien olvida
/// regenerarlos o cambia una ruta, esta prueba lo detecta.
void main() {
  test('existen todos los assets de niveles y de ícono', () {
    final paths = [
      for (final level in defaultAscendLevels) level.assetPath,
      'assets/icon/icon.png',
      'assets/icon/icon_dev.png',
      'assets/icon/icon_foreground.png',
      'assets/icon/icon_foreground_dev.png',
      'assets/splash/splash.png',
      'assets/splash/splash_android12.png',
      'assets/fonts/BarlowCondensed/OFL.txt',
    ];
    for (final path in paths) {
      expect(File(path).existsSync(), isTrue, reason: 'falta $path');
    }
  });
}
