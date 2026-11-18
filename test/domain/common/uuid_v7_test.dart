import 'dart:math';

import 'package:ascend/domain/common/clock.dart';
import 'package:ascend/domain/common/uuid_v7.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('formato, versión 7 y variante RFC 9562', () {
    final gen = UuidV7Generator(clock: FixedClock(DateTime.utc(2026, 11, 10)));
    for (var i = 0; i < 100; i++) {
      expect(gen.next(), matches(pattern));
    }
  });

  test('los primeros 48 bits son los milisegundos del Clock', () {
    final now = DateTime.utc(2026, 11, 10, 18, 30, 15, 123);
    final id = UuidV7Generator(clock: FixedClock(now)).next();
    final ms = int.parse(id.replaceAll('-', '').substring(0, 12), radix: 16);
    expect(ms, now.millisecondsSinceEpoch);
  });

  test('ordenados por tiempo y sin repetirse', () {
    final clock = FixedClock(DateTime.utc(2026, 11, 10));
    final gen = UuidV7Generator(clock: clock, random: Random(7));
    final ids = <String>[];
    for (var i = 0; i < 50; i++) {
      ids.add(gen.next());
      clock.advance(const Duration(milliseconds: 1));
    }
    expect([...ids]..sort(), ids);
    expect(ids.toSet(), hasLength(ids.length));
  });
}
