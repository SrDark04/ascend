import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SettingsRepository] sobre `SharedPreferencesAsync` (§5.1).
class SharedPrefsSettingsRepository implements SettingsRepository {
  new([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const themeKey = 'settings.theme_mode';

  final SharedPreferencesAsync _prefs;

  @override
  Future<ThemePreference> loadThemePreference() async =>
      ThemePreference.fromStorage(await _prefs.getString(themeKey));

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _prefs.setString(themeKey, preference.storageKey);
}
