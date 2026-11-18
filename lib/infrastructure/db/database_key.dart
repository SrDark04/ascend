import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacén de la clave de la BD (Keystore de Android vía
/// flutter_secure_storage, §9).
abstract interface class DatabaseKeyStore {
  Future<String?> read();
  Future<void> write(String hexKey);
}

class SecureStorageDatabaseKeyStore implements DatabaseKeyStore {
  new({required this.storageKey, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Nombre de la entrada; incluye el nombre de la BD del flavor.
  final String storageKey;
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: storageKey);

  @override
  Future<void> write(String hexKey) =>
      _storage.write(key: storageKey, value: hexKey);
}

/// La BD existe pero su clave ya no está (p. ej. se borraron los datos del
/// Keystore). Nunca se borra la BD automáticamente: se avisa.
class DatabaseKeyLostException implements Exception {
  const new();

  @override
  String toString() =>
      'DatabaseKeyLostException: la base de datos existe pero no su clave';
}

/// Devuelve la clave (64 caracteres hex = 32 bytes) de la BD. La genera
/// solo si la BD todavía no existe.
Future<String> obtainDatabaseKey({
  required DatabaseKeyStore store,
  required bool databaseExists,
  Random? random,
}) async {
  final existing = await store.read();
  if (existing != null && isValidHexKey(existing)) return existing;
  if (databaseExists) throw const DatabaseKeyLostException();
  final key = generateHexKey(random ?? Random.secure());
  await store.write(key);
  return key;
}

String generateHexKey(Random random) => List.generate(
  32,
  (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

bool isValidHexKey(String key) => RegExp(r'^[0-9a-f]{64}$').hasMatch(key);
