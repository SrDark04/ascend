import 'package:ascend/application/ports/app_log.dart';
import 'package:ascend/application/ports/file_sharer.dart';
import 'package:ascend/application/ports/settings_repository.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference theme = ThemePreference.system;
  WeightUnit unit = WeightUnit.kg;

  @override
  Future<ThemePreference> loadThemePreference() async => theme;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async =>
      theme = preference;

  @override
  Future<WeightUnit> loadWeightUnit() async => unit;

  @override
  Future<void> saveWeightUnit(WeightUnit unit) async => this.unit = unit;
}

/// Registro en memoria.
class FakeLog implements AppLog, LogStore {
  final entries = <String>[];
  String exportPath = '/tmp/ascend-log.txt';
  String? lastHeader;

  @override
  void info(String message) => entries.add('INFO $message');

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      entries.add('WARN $message :: $error');

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      entries.add('ERROR $message :: $error');

  @override
  Future<List<String>> recentErrors({int limit = 20}) async =>
      entries.where((e) => e.startsWith('ERROR')).toList();

  @override
  Future<String> exportToFile({required String header}) async {
    lastHeader = header;
    return exportPath;
  }
}

class FakeFileSharer implements FileSharer {
  final shared = <String>[];

  @override
  Future<void> shareFile(String path, {String? subject}) async =>
      shared.add(path);
}
