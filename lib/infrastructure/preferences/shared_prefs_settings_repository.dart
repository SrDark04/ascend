import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SettingsRepository] sobre `SharedPreferencesAsync` (§5.1).
class SharedPrefsSettingsRepository implements SettingsRepository {
  new([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const themeKey = 'settings.theme_mode';
  static const weightUnitKey = 'settings.weight_unit';

  final SharedPreferencesAsync _prefs;

  @override
  Future<ThemePreference> loadThemePreference() async =>
      ThemePreference.fromStorage(await _prefs.getString(themeKey));

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _prefs.setString(themeKey, preference.storageKey);

  @override
  Future<WeightUnit> loadWeightUnit() async =>
      WeightUnit.fromStorage(await _prefs.getString(weightUnitKey));

  @override
  Future<void> saveWeightUnit(WeightUnit unit) =>
      _prefs.setString(weightUnitKey, unit.storageKey);
}
