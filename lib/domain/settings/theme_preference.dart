/// Preferencia de tema del usuario (§7.2). Dart puro: la capa de UI la
/// traduce a `ThemeMode`.
enum ThemePreference {
  system,
  light,
  dark;

  /// Valor estable para persistir (no depende del orden del enum).
  String get storageKey => name;

  /// Lee un valor persistido; si falta o es desconocido, [system].
  static ThemePreference fromStorage(String? value) {
    for (final p in values) {
      if (p.storageKey == value) return p;
    }
    return system;
  }
}
