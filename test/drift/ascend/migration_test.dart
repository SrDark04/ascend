// Pruebas de migración (§5.5.5). Al subir schemaVersion:
//   dart run drift_dev make-migrations
// genera el dump nuevo, los pasos y los helpers; añade aquí una prueba
// «vN → vN+1 conserva los datos».
import 'package:ascend/infrastructure/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('el esquema actual coincide con el último dump', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('una BD creada desde cero valida contra el dump v1', () async {
    final db = AppDatabase(DatabaseConnection(await verifier.startAt(1)));
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('los datos de una BD v1 se leen con la versión actual', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    final now = DateTime.utc(2026, 11, 10).toIso8601String();
    await old.customStatement(
      'INSERT INTO exercise (id, name, mechanics, updated_at) '
      "VALUES ('e1', 'Press de banca', 'compound', '$now')",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final rows = await db.select(db.exercises).get();
    expect(rows.single.name, 'Press de banca');
    expect(rows.single.isCustom, isFalse);
    await db.close();
  });
}
