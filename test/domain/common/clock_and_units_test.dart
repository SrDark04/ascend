import 'package:ascend/domain/common/clock.dart';
import 'package:ascend/domain/common/local_date.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixedClock: today y advance', () {
    final clock = FixedClock(DateTime(2026, 11, 10, 23, 59));
    expect(clock.today(), LocalDate(2026, 11, 10));
    clock.advance(const Duration(minutes: 2));
    expect(clock.today(), LocalDate(2026, 11, 11));
  });

  test('SystemClock devuelve una hora local', () {
    expect(const SystemClock().now().isUtc, isFalse);
  });

  group('WeightUnit', () {
    test('kg ↔ lb con la definición exacta', () {
      expect(WeightUnit.lb.fromKg(100), closeTo(220.462, 0.001));
      expect(WeightUnit.lb.toKg(225), closeTo(102.058, 0.001));
      expect(WeightUnit.kg.fromKg(62.5), 62.5);
      for (final kg in <double>[0, 2.5, 60, 142.5]) {
        expect(WeightUnit.lb.toKg(WeightUnit.lb.fromKg(kg)), closeTo(kg, 1e-9));
      }
    });

    test('almacenamiento', () {
      expect(WeightUnit.fromStorage('lb'), WeightUnit.lb);
      expect(WeightUnit.fromStorage(null), WeightUnit.kg);
      expect(WeightUnit.fromStorage('stone'), WeightUnit.kg);
    });
  });
}
