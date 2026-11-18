import 'package:ascend/domain/common/local_date.dart';
import 'package:ascend/infrastructure/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Restricciones del esquema v1 (§6.2) y reglas de validación de series.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final t = DateTime.utc(2026, 11, 10, 18);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(id: 'u1', createdAt: t, updatedAt: t),
        );
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(id: 'e1', name: 'Remo', updatedAt: t),
        );
    await db
        .into(db.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            id: 's1',
            userId: 'u1',
            startedAt: t,
            localDate: LocalDate(2026, 11, 10),
            updatedAt: t,
          ),
        );
  });
  tearDown(() => db.close());

  Future<void> insertSet({
    double? weightKg = 60,
    int? reps = 8,
    double? rir = 2,
    String setType = 'working',
    String sessionId = 's1',
  }) => db
      .into(db.workoutSets)
      .insert(
        WorkoutSetsCompanion.insert(
          id: 'set-${DateTime.now().microsecondsSinceEpoch}',
          sessionId: sessionId,
          exerciseId: 'e1',
          setIndex: 0,
          setType: Value(setType),
          weightKg: Value(weightKg),
          reps: Value(reps),
          rir: Value(rir),
          updatedAt: t,
        ),
      );

  test('una serie válida se guarda en kg con su día local', () async {
    await insertSet();
    final set = await db.select(db.workoutSets).getSingle();
    expect(set.weightKg, 60);
    expect(set.deletedAt, isNull);
    final session = await db.select(db.workoutSessions).getSingle();
    expect(session.localDate, LocalDate(2026, 11, 10));
  });

  test('reps ≥ 1', () async {
    await expectLater(insertSet(reps: 0), throwsA(isA<SqliteException>()));
  });

  test('kg ≥ 0', () async {
    await expectLater(
      insertSet(weightKg: -2.5),
      throwsA(isA<SqliteException>()),
    );
  });

  test('RIR entre 0 y 10', () async {
    await expectLater(insertSet(rir: 11), throwsA(isA<SqliteException>()));
    await insertSet(rir: 0);
  });

  test('tipo de serie dentro de la lista del §3.1', () async {
    await expectLater(
      insertSet(setType: 'giant'),
      throwsA(isA<SqliteException>()),
    );
    for (final type in ['warmup', 'working', 'drop', 'failure', 'backoff']) {
      await insertSet(setType: type);
    }
  });

  test('claves foráneas activas', () async {
    await expectLater(
      insertSet(sessionId: 'no-existe'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('sRPE entre 0 y 10', () async {
    await expectLater(
      (db.update(db.workoutSessions)..where((s) => s.id.equals('s1'))).write(
        const WorkoutSessionsCompanion(sessionRpe: Value(11)),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('todas las tablas tienen updated_at y deleted_at', () async {
    for (final table in db.allTables) {
      final names = table.$columns.map((c) => c.name).toSet();
      expect(
        names,
        containsAll(['updated_at', 'deleted_at']),
        reason: table.actualTableName,
      );
    }
  });
}
