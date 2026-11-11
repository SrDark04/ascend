/// Unidad de carga que ve el usuario. En la base de datos la carga se
/// guarda SIEMPRE en kg; la unidad solo afecta a lo que se muestra.
enum WeightUnit {
  kg,
  lb;

  /// Definición exacta: 1 lb = 0,45359237 kg.
  static const kgPerLb = 0.45359237;

  String get storageKey => name;

  static WeightUnit fromStorage(String? value) {
    for (final u in values) {
      if (u.storageKey == value) return u;
    }
    return kg;
  }

  /// Convierte kg (almacenados) a esta unidad para mostrar.
  double fromKg(double kg) => switch (this) {
    WeightUnit.kg => kg,
    WeightUnit.lb => kg / kgPerLb,
  };

  /// Convierte un valor introducido en esta unidad a kg para guardar.
  double toKg(double value) => switch (this) {
    WeightUnit.kg => value,
    WeightUnit.lb => value * kgPerLb,
  };
}
