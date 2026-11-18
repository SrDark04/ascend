// LocalDate es inmutable (todos sus campos son final) y necesita igualdad
// por valor. No se anota con @immutable para no añadir package:meta al
// dominio puro.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// Fecha local sin hora ni zona (año-mes-día), value object del §4.5.
///
/// Las rachas cuentan días del calendario del usuario, no instantes; usar
/// `DateTime` para eso provoca errores con husos horarios y cambios de
/// hora. Las operaciones de días se hacen sobre un número de día absoluto
/// (días desde 1970-01-01 en el calendario gregoriano proléptico), así que
/// nunca dependen de la zona horaria.
///
/// Las utilidades de semana ISO llegan en la Fase 2 (2.1).
final class LocalDate implements Comparable<LocalDate> {
  /// Lanza [ArgumentError] si la fecha no existe (p. ej. 2026-02-30).
  factory(int year, int month, int day) {
    if (!isValid(year, month, day)) {
      throw ArgumentError('Fecha inexistente: $year-$month-$day');
    }
    return LocalDate._(year, month, day);
  }

  const new _(this.year, this.month, this.day);

  /// Día del calendario de [dateTime] en SU zona: un `DateTime` local da
  /// el día local; uno UTC, el día UTC. Para «hoy» usar `Clock.today()`.
  factory fromDateTime(DateTime dateTime) =>
      LocalDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Desde el número de día absoluto ([epochDay]).
  factory fromEpochDay(int epochDay) {
    final utc = DateTime.fromMillisecondsSinceEpoch(
      epochDay * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return LocalDate._(utc.year, utc.month, utc.day);
  }

  /// Lee `AAAA-MM-DD` (ISO 8601). Lanza [FormatException] si no es válido.
  factory parse(String text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) throw FormatException('Fecha no válida', text);
    final (y, m, d) = (
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
    if (!isValid(y, m, d)) throw FormatException('Fecha inexistente', text);
    return LocalDate._(y, m, d);
  }

  /// `true` si la fecha existe en el calendario gregoriano.
  static bool isValid(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    return utc.year == year && utc.month == month && utc.day == day;
  }

  final int year;
  final int month;
  final int day;

  /// Días desde 1970-01-01 (negativo antes).
  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// 1 = lunes … 7 = domingo (ISO 8601).
  int get weekday => DateTime.utc(year, month, day).weekday;

  LocalDate addDays(int days) => LocalDate.fromEpochDay(epochDay + days);

  /// Diferencia `this − other` en días enteros, como `Duration` para
  /// mantener la API del §4.5 (`today.difference(day).inDays`).
  Duration difference(LocalDate other) =>
      Duration(days: epochDay - other.epochDay);

  bool isBefore(LocalDate other) => epochDay < other.epochDay;
  bool isAfter(LocalDate other) => epochDay > other.epochDay;

  /// Medianoche local de este día (para mostrar o programar avisos).
  DateTime toLocalDateTime() => DateTime(year, month, day);

  @override
  int compareTo(LocalDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `AAAA-MM-DD`.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
