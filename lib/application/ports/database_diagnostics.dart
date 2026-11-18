/// Datos técnicos de la BD para la pantalla Diagnóstico.
abstract interface class DatabaseDiagnostics {
  Future<DatabaseInfo> describe();
}

class DatabaseInfo {
  const new({required this.schemaVersion, this.cipherVersion});

  final int schemaVersion;

  /// Versión de SQLCipher; `null` si la BD no está cifrada.
  final String? cipherVersion;
}
