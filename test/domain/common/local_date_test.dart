import 'package:ascend/domain/common/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDate', () {
    test('rechaza fechas inexistentes', () {
      expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(LocalDate(2028, 2, 29).day, 29); // bisiesto
    });

    test('fromDateTime toma el día en la zona del DateTime', () {
      // 23:30 local sigue siendo el mismo día aunque en UTC ya sea mañana.
      final late = DateTime(2026, 11, 10, 23, 30);
      expect(LocalDate.fromDateTime(late), LocalDate(2026, 11, 10));
      expect(
        LocalDate.fromDateTime(DateTime.utc(2026, 11, 11, 4, 30)),
        LocalDate(2026, 11, 11),
      );
    });

    test('difference y addDays en días enteros, cruzando meses y años', () {
      final a = LocalDate(2026, 12, 30);
      expect(a.addDays(3), LocalDate(2027, 1, 2));
      expect(LocalDate(2027, 1, 2).difference(a).inDays, 3);
      expect(a.difference(LocalDate(2027, 1, 2)).inDays, -3);
      expect(
        LocalDate(2028, 3, 1).difference(LocalDate(2028, 2, 28)).inDays,
        2,
      );
    });

    test('epochDay: ida y vuelta', () {
      expect(LocalDate(1970, 1, 1).epochDay, 0);
      for (final d in [-1000, -1, 0, 1, 20402, 100000]) {
        expect(LocalDate.fromEpochDay(d).epochDay, d);
      }
    });

    test('orden, igualdad e ISO', () {
      final a = LocalDate(2026, 11, 10);
      final b = LocalDate(2026, 11, 11);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.compareTo(b), lessThan(0));
      expect(a, LocalDate(2026, 11, 10));
      expect({a, LocalDate(2026, 11, 10)}, hasLength(1));
      expect(a.toString(), '2026-11-10');
      expect(LocalDate.parse('2026-11-10'), a);
      expect(() => LocalDate.parse('2026-2-30'), throwsFormatException);
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
    });

    test('weekday ISO: 2026-11-09 es lunes', () {
      expect(LocalDate(2026, 11, 9).weekday, DateTime.monday);
      expect(LocalDate(2026, 11, 15).weekday, DateTime.sunday);
    });
  });
}
