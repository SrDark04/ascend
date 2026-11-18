// Drift declara las restricciones CHECK referenciando la propia columna
// (`sex.isIn(...)` dentro de `sex`); no es una recursión real.
// ignore_for_file: recursive_getters

import 'package:ascend/infrastructure/db/tables/common.dart';
import 'package:drift/drift.dart';

/// §6.2 `muscle_group`.
@DataClassName('MuscleGroupRow')
class MuscleGroups extends Table with SyncColumns {
  @override
  String get tableName => 'muscle_group';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get region => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// §6.2 `exercise`.
@DataClassName('ExerciseRow')
class Exercises extends Table with SyncColumns {
  @override
  String get tableName => 'exercise';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get equipment => text().nullable()();
  TextColumn get mechanics => text().nullable().check(
    mechanics.isIn(const ['compound', 'isolation']),
  )();
  BoolColumn get isUnilateral => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// §6.2 `exercise_muscle`: músculos primarios y secundarios.
@DataClassName('ExerciseMuscleRow')
class ExerciseMuscles extends Table with SyncColumns {
  @override
  String get tableName => 'exercise_muscle';

  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get muscleId => text().references(MuscleGroups, #id)();
  TextColumn get role =>
      text().check(role.isIn(const ['primary', 'secondary']))();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}
