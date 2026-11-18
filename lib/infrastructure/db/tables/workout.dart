// Drift declara las restricciones CHECK referenciando la propia columna
// (`sex.isIn(...)` dentro de `sex`); no es una recursión real.
// ignore_for_file: recursive_getters

import 'package:ascend/infrastructure/db/converters.dart';
import 'package:ascend/infrastructure/db/tables/common.dart';
import 'package:ascend/infrastructure/db/tables/exercise.dart';
import 'package:ascend/infrastructure/db/tables/user_profile.dart';
import 'package:drift/drift.dart';

/// §6.2 `workout_session`.
@DataClassName('WorkoutSessionRow')
@TableIndex(name: 'idx_session_user_date', columns: {#userId, #localDate})
class WorkoutSessions extends Table with SyncColumns {
  @override
  String get tableName => 'workout_session';

  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get programDayId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Día local del usuario, `AAAA-MM-DD` (rachas y calendario).
  TextColumn get localDate => text().map(const LocalDateConverter())();

  /// sRPE, escala CR-10 (§3.1).
  RealColumn get sessionRpe =>
      real().nullable().check(sessionRpe.isBetweenValues(0, 10))();
  BoolColumn get isDeload => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// §6.2 `workout_set`. La carga se guarda SIEMPRE en kg.
@DataClassName('WorkoutSetRow')
@TableIndex(name: 'idx_set_exercise_date', columns: {#exerciseId, #completedAt})
@TableIndex(name: 'idx_set_session_index', columns: {#sessionId, #setIndex})
class WorkoutSets extends Table with SyncColumns {
  @override
  String get tableName => 'workout_set';

  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get setIndex => integer()();
  TextColumn get setType => text()
      .withDefault(const Constant('working'))
      .check(
        setType.isIn(const ['warmup', 'working', 'drop', 'failure', 'backoff']),
      )();
  RealColumn get weightKg =>
      real().nullable().check(weightKg.isBiggerOrEqualValue(0))();
  IntColumn get reps =>
      integer().nullable().check(reps.isBiggerOrEqualValue(1))();
  RealColumn get rir => real().nullable().check(rir.isBetweenValues(0, 10))();
  RealColumn get rpe => real().nullable().check(rpe.isBetweenValues(0, 10))();
  IntColumn get restS =>
      integer().nullable().check(restS.isBiggerOrEqualValue(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
