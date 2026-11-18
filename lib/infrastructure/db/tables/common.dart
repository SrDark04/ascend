import 'package:drift/drift.dart';

/// Columnas comunes a todas las tablas: `updated_at` para fusionar
/// respaldos por id + fecha (§5.6) y `deleted_at` para el borrado lógico.
mixin SyncColumns on Table {
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
