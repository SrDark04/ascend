import 'dart:math';

import 'package:ascend/infrastructure/db/database_key.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryKeyStore implements DatabaseKeyStore {
  String? value;
  int writes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String hexKey) async {
    value = hexKey;
    writes++;
  }
}

void main() {
  test('genera y guarda una clave de 32 bytes si la BD es nueva', () async {
    final store = MemoryKeyStore();
    final key = await obtainDatabaseKey(store: store, databaseExists: false);
    expect(isValidHexKey(key), isTrue);
    expect(key, hasLength(64));
    expect(store.value, key);
  });

  test('reutiliza la clave guardada', () async {
    final store = MemoryKeyStore()..value = generateHexKey(Random(3));
    final key = await obtainDatabaseKey(store: store, databaseExists: true);
    expect(key, store.value);
    expect(store.writes, 0);
  });

  test(
    'si la BD existe y falta la clave, NO genera otra (no borra datos)',
    () async {
      final store = MemoryKeyStore();
      await expectLater(
        obtainDatabaseKey(store: store, databaseExists: true),
        throwsA(isA<DatabaseKeyLostException>()),
      );
      expect(store.writes, 0);
    },
  );

  test('claves distintas en cada generación', () {
    final random = Random.secure();
    expect(generateHexKey(random), isNot(generateHexKey(random)));
  });
}
