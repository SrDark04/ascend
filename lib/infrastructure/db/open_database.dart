import 'dart:io';

import 'package:ascend/infrastructure/db/database_key.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Abre la BD cifrada con SQLCipher en un isolate de fondo (§5.1).
///
/// La clave es binaria (`x'…'`), así SQLCipher no deriva claves con PBKDF2
/// en cada apertura. Si SQLCipher no está presente o la clave no abre el
/// archivo, falla aquí en lugar de escribir datos sin cifrar.
QueryExecutor openEncryptedDatabase(File file, String hexKey) {
  if (!isValidHexKey(hexKey)) {
    throw ArgumentError('Clave de BD con formato no válido');
  }
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      final cipher = db.select('PRAGMA cipher_version');
      if (cipher.isEmpty || cipher.first.values.first == null) {
        throw StateError('SQLCipher no está disponible: no se abre la BD');
      }
      db
        ..execute("PRAGMA key = \"x'$hexKey'\"")
        // Comprueba la clave: con una clave errónea esto lanza
        // «file is not a database».
        ..select('SELECT count(*) FROM sqlite_master');
    },
  );
}
