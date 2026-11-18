/// Puerto de registro local (§5.5.7). Sin servicios externos: todo queda
/// en un archivo rotativo del dispositivo.
///
/// ⚠ Privacidad (§9): los mensajes NUNCA incluyen datos de salud ni de
/// entrenamiento (medidas, cargas, notas, dolor…). Registrar solo eventos
/// técnicos: qué falló y dónde, no con qué valores del usuario.
abstract interface class AppLog {
  void info(String message);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Lectura y exportación del registro (pantalla Diagnóstico).
abstract interface class LogStore {
  /// Últimas entradas de error, de la más antigua a la más reciente.
  Future<List<String>> recentErrors({int limit = 20});

  /// Une los archivos rotados en uno solo y devuelve su ruta.
  Future<String> exportToFile({required String header});
}
