import 'package:ascend/app/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('dev usa BD propia y carga datos semilla', () {
      expect(AppConfig.dev.flavor, Flavor.dev);
      expect(AppConfig.dev.appName, 'Ascend Dev');
      expect(AppConfig.dev.databaseName, 'ascend_dev.db');
      expect(AppConfig.dev.loadSeedData, isTrue);
      expect(AppConfig.dev.isDev, isTrue);
    });

    test('prod usa ascend.db y nunca carga datos semilla', () {
      expect(AppConfig.prod.flavor, Flavor.prod);
      expect(AppConfig.prod.appName, 'Ascend');
      expect(AppConfig.prod.databaseName, 'ascend.db');
      expect(AppConfig.prod.loadSeedData, isFalse);
      expect(AppConfig.prod.isDev, isFalse);
    });

    test('los flavors nunca comparten base de datos', () {
      expect(AppConfig.dev.databaseName, isNot(AppConfig.prod.databaseName));
    });
  });
}
