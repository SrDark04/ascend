import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ascend/infrastructure/db/app_database.dart';
import 'package:ascend/infrastructure/db/database_key.dart';
import 'package:ascend/infrastructure/db/open_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory dir;
  late File file;
  final key = generateHexKey(Random(1));

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ascend_db_');
    file = File('${dir.path}/ascend_test.db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> insertExercise(AppDatabase db) => db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: '0190f2a0-0000-7000-8000-000000000001',
          name: 'Sentadilla',
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
      );

  test(
    'el archivo está cifrado con SQLCipher y se reabre con su clave',
    () async {
      final db = AppDatabase(openEncryptedDatabase(file, key));
      final info = await db.describe();
      expect(info.schemaVersion, 1);
      expect(info.cipherVersion, isNotEmpty, reason: 'SQLCipher enlazado');
      await insertExercise(db);
      await db.close();

      // Un SQLite sin cifrar empieza por «SQLite format 3».
      final header = String.fromCharCodes(file.readAsBytesSync().take(15));
      expect(header, isNot('SQLite format 3'));
      expect(
        file.readAsStringSync(encoding: latin1).contains('Sentadilla'),
        isFalse,
        reason: 'el texto no aparece en claro en el archivo',
      );

      final reopened = AppDatabase(openEncryptedDatabase(file, key));
      final rows = await reopened.select(reopened.exercises).get();
      expect(rows.single.name, 'Sentadilla');
      await reopened.close();
    },
  );

  test('con otra clave no se puede abrir', () async {
    final db = AppDatabase(openEncryptedDatabase(file, key));
    await insertExercise(db);
    await db.close();

    final wrong = AppDatabase(
      openEncryptedDatabase(file, generateHexKey(Random(2))),
    );
    await expectLater(wrong.select(wrong.exercises).get(), throwsA(anything));
    await wrong.close();
  });

  test('rechaza claves con formato no válido', () {
    expect(() => openEncryptedDatabase(file, 'abc'), throwsArgumentError);
  });
}
