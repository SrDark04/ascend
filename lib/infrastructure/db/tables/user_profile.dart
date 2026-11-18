// Drift declara las restricciones CHECK referenciando la propia columna
// (`sex.isIn(...)` dentro de `sex`); no es una recursión real.
// ignore_for_file: recursive_getters

import 'package:ascend/infrastructure/db/converters.dart';
import 'package:ascend/infrastructure/db/tables/common.dart';
import 'package:drift/drift.dart';

/// §6.2 `user_profile`. Usuario único (uso personal).
@DataClassName('UserProfileRow')
class UserProfiles extends Table with SyncColumns {
  @override
  String get tableName => 'user_profile';

  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get sex =>
      text().nullable().check(sex.isIn(const ['M', 'F', 'X']))();
  TextColumn get birthDate =>
      text().map(const LocalDateConverter()).nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get unitSystem => text().withDefault(const Constant('metric'))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
