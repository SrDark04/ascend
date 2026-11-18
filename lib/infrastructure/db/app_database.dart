import 'package:ascend/application/ports/database_diagnostics.dart';
import 'package:ascend/domain/common/local_date.dart';
import 'package:ascend/infrastructure/db/converters.dart';
import 'package:ascend/infrastructure/db/tables/exercise.dart';
import 'package:ascend/infrastructure/db/tables/user_profile.dart';
import 'package:ascend/infrastructure/db/tables/workout.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Base de datos local de Ascend (Drift sobre SQLCipher, §5.1 y §9).
///
/// ⚠ Los datos reales del usuario viven aquí. Cada cambio de esquema:
/// 1. sube [schemaVersion];
/// 2. `dart run drift_dev make-migrations` (dump + pasos + pruebas);
/// 3. añade el paso en [migration] y una prueba con datos de la versión
///    anterior. Ninguna migración puede perder datos.
@DriftDatabase(
  tables: [
    UserProfiles,
    MuscleGroups,
    Exercises,
    ExerciseMuscles,
    WorkoutSessions,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase implements DatabaseDiagnostics {
  new(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  @override
  Future<DatabaseInfo> describe() async {
    final version = await customSelect('PRAGMA user_version').getSingle();
    final cipher = await customSelect('PRAGMA cipher_version').get();
    return DatabaseInfo(
      schemaVersion: version.data.values.first as int,
      cipherVersion: cipher.isEmpty
          ? null
          : cipher.first.data.values.first as String?,
    );
  }
}
