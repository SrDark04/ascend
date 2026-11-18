import 'dart:math';

import 'package:ascend/domain/common/clock.dart';

/// Generador de UUID versión 7 (RFC 9562): 48 bits de milisegundos Unix
/// seguidos de bits aleatorios. Los id quedan ordenados por fecha de
/// creación, lo que favorece los índices y la fusión de respaldos.
class UuidV7Generator {
  new({required this._clock, Random? random})
    : _random = random ?? Random.secure();

  final Clock _clock;
  final Random _random;

  String next() {
    final ms = _clock.now().millisecondsSinceEpoch;
    final bytes = List<int>.filled(16, 0);
    for (var i = 0; i < 6; i++) {
      bytes[i] = (ms >> (8 * (5 - i))) & 0xff;
    }
    for (var i = 6; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    bytes[6] = 0x70 | (bytes[6] & 0x0f); // versión 7
    bytes[8] = 0x80 | (bytes[8] & 0x3f); // variante RFC 4122/9562
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20),
    ].join('-');
  }
}
