import 'package:ascend/app/providers.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unidad de carga para mostrar. Los datos siempre se guardan en kg.
final weightUnitProvider = NotifierProvider<WeightUnitController, WeightUnit>(
  WeightUnitController.new,
);

class WeightUnitController extends Notifier<WeightUnit> {
  @override
  WeightUnit build() => ref.watch(initialWeightUnitProvider);

  Future<void> select(WeightUnit unit) async {
    if (unit == state) return;
    state = unit;
    await ref.read(settingsRepositoryProvider).saveWeightUnit(unit);
  }
}
