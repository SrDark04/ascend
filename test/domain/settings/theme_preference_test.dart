import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ida y vuelta por el almacenamiento', () {
    for (final p in ThemePreference.values) {
      expect(ThemePreference.fromStorage(p.storageKey), p);
    }
  });

  test('valores ausentes o desconocidos → sistema', () {
    expect(ThemePreference.fromStorage(null), ThemePreference.system);
    expect(ThemePreference.fromStorage('morado'), ThemePreference.system);
  });
}
