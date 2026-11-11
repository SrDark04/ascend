import 'package:ascend/app/error_handlers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  test('los errores del framework y de la plataforma van al registro', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final previousFlutter = FlutterError.onError;
    final previousPlatform = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previousFlutter;
      PlatformDispatcher.instance.onError = previousPlatform;
    });
    final log = FakeLog();
    installErrorHandlers(log);
    // En pruebas kDebugMode es true: evita que se reenvíe al manejador de
    // flutter_test, que haría fallar esta prueba.
    FlutterError.onError = (d) {
      log.error('FlutterError (${d.library})', d.exception, d.stack);
    };
    FlutterError.onError!(
      FlutterErrorDetails(exception: StateError('ui'), library: 'widgets'),
    );
    final handled = PlatformDispatcher.instance.onError!(
      StateError('async'),
      StackTrace.empty,
    );
    expect(handled, isTrue);
    expect(log.entries, [
      'ERROR FlutterError (widgets) :: Bad state: ui',
      'ERROR Error no capturado :: Bad state: async',
    ]);
  });
}
