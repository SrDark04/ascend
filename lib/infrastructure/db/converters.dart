import 'package:ascend/domain/common/local_date.dart';
import 'package:drift/drift.dart';

/// `LocalDate` ↔ `TEXT 'AAAA-MM-DD'` (§6.2: `local_date`).
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const new();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toString();
}
