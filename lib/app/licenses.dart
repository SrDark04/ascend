import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registra las licencias OFL de las fuentes empaquetadas para que
/// aparezcan en la pantalla de licencias de la app.
void registerFontLicenses() {
  const fonts = {
    'Barlow Condensed': 'assets/fonts/BarlowCondensed/OFL.txt',
    'IBM Plex Sans': 'assets/fonts/IBMPlexSans/OFL.txt',
    'IBM Plex Mono': 'assets/fonts/IBMPlexMono/OFL.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: name, value: path) in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(path));
    }
  });
}
