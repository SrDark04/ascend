import 'package:ascend/domain/common/local_date.dart';

/// Fuente de la hora actual. Es el ÚNICO lugar donde se llama a
/// `DateTime.now()` ([SystemClock]); el resto del código recibe un [Clock]
/// inyectado (provider de Riverpod), lo que hace el tiempo controlable en
/// pruebas y en el flavor dev (Fase 2: «avanzar N días»).
abstract interface class Clock {
  /// Instante actual en la zona local del dispositivo.
  DateTime now();
}

/// Reloj real del dispositivo.
final class SystemClock implements Clock {
  const new();

  @override
  DateTime now() => DateTime.now();
}

/// Reloj fijo para pruebas. [advance] permite moverlo.
final class FixedClock implements Clock {
  new(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}

extension ClockDates on Clock {
  /// Día local actual.
  LocalDate today() => LocalDate.fromDateTime(now());
}
