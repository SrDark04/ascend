import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';

/// Puerto de ajustes del usuario. Lo implementa la infraestructura
/// (shared_preferences) y se inyecta con Riverpod.
abstract interface class SettingsRepository {
  Future<ThemePreference> loadThemePreference();
  Future<void> saveThemePreference(ThemePreference preference);
  Future<WeightUnit> loadWeightUnit();
  Future<void> saveWeightUnit(WeightUnit unit);
}
