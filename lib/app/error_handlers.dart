import 'package:ascend/application/ports/app_log.dart';
import 'package:flutter/foundation.dart';

/// Envía al registro local los errores no capturados del framework y de
/// la plataforma (§5.5.7). No se envían a ningún servicio externo.
void installErrorHandlers(AppLog log) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    log.error(
      'FlutterError (${details.library ?? 'desconocida'})',
      details.exception,
      details.stack,
    );
    if (kDebugMode) previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.error('Error no capturado', error, stack);
    return true;
  };
}
