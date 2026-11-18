import 'dart:io';

import 'package:ascend/application/ports/app_log.dart';
import 'package:ascend/domain/common/clock.dart';
import 'package:logger/logger.dart';

/// Registro local en archivos rotativos (`ascend.log`, `ascend.1.log`, …)
/// usando el paquete `logger` (§5.1). Implementa [AppLog] y [LogStore].
///
/// Formato de una entrada (una línea; las siguientes, sangradas):
/// `2026-11-10T20:15:03.120 ERROR mensaje :: error`
class RotatingFileLog implements AppLog, LogStore {
  new({
    required this.directory,
    required this.clock,
    this.maxBytes = 512 * 1024,
    this.maxFiles = 3,
    this.echoToConsole = false,
  }) {
    _logger = Logger(
      filter: _MinLevelFilter(),
      printer: _LinePrinter(),
      output: MultiOutput([
        _RotatingFileOutput(this),
        if (echoToConsole) ConsoleOutput(),
      ]),
    );
  }

  static const baseName = 'ascend';
  static const _stackLines = 12;

  final Directory directory;
  final Clock clock;

  /// Tamaño a partir del cual se rota el archivo actual.
  final int maxBytes;

  /// Archivos que se conservan en total (actual + rotados).
  final int maxFiles;
  final bool echoToConsole;
  late final Logger _logger;

  File _file(int index) => File(
    '${directory.path}/${index == 0 ? '$baseName.log' : '$baseName.$index.log'}',
  );

  /// Archivos existentes, del más antiguo al más reciente.
  List<File> get files => [
    for (var i = maxFiles - 1; i >= 0; i--)
      if (_file(i).existsSync()) _file(i),
  ];

  @override
  void info(String message) =>
      _logger.log(Level.info, message, time: clock.now());

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(
        Level.warning,
        message,
        time: clock.now(),
        error: error,
        stackTrace: stackTrace,
      );

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(
        Level.error,
        message,
        time: clock.now(),
        error: error,
        stackTrace: stackTrace,
      );

  void _append(List<String> lines) {
    directory.createSync(recursive: true);
    final current = _file(0);
    if (current.existsSync() && current.lengthSync() >= maxBytes) _rotate();
    current.writeAsStringSync('${lines.join('\n')}\n', mode: FileMode.append);
  }

  void _rotate() {
    final oldest = _file(maxFiles - 1);
    if (oldest.existsSync()) oldest.deleteSync();
    for (var i = maxFiles - 2; i >= 0; i--) {
      final f = _file(i);
      if (f.existsSync()) f.renameSync(_file(i + 1).path);
    }
  }

  @override
  Future<List<String>> recentErrors({int limit = 20}) async {
    final errors = <String>[];
    for (final f in files) {
      for (final line in await f.readAsLines()) {
        if (line.contains(' ERROR ') && !line.startsWith(' ')) {
          errors.add(line);
        }
      }
    }
    return errors.length <= limit
        ? errors
        : errors.sublist(errors.length - limit);
  }

  @override
  Future<String> exportToFile({required String header}) async {
    final today = clock.today();
    final out = File('${directory.path}/export/ascend-log-$today.txt');
    await out.parent.create(recursive: true);
    final buffer = StringBuffer('$header\n\n');
    for (final f in files) {
      buffer.write(await f.readAsString());
    }
    await out.writeAsString(buffer.toString());
    return out.path;
  }
}

/// Registra desde info, también en release (el filtro por defecto de
/// `logger` lo descarta todo en release).
class _MinLevelFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => event.level.value >= Level.info.value;
}

class _LinePrinter extends LogPrinter {
  static const Map<Level, String> _names = {
    Level.info: 'INFO',
    Level.warning: 'WARN',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };

  @override
  List<String> log(LogEvent event) {
    final level = _names[event.level] ?? event.level.name.toUpperCase();
    final head = StringBuffer(
      '${event.time.toIso8601String()} $level ${event.message}',
    );
    if (event.error != null) head.write(' :: ${event.error}');
    final lines = head.toString().split('\n');
    final result = [lines.first, for (final l in lines.skip(1)) '  $l'];
    final stack = event.stackTrace?.toString().trim();
    if (stack != null && stack.isNotEmpty) {
      result.addAll(
        stack.split('\n').take(RotatingFileLog._stackLines).map((l) => '  $l'),
      );
    }
    return result;
  }
}

class _RotatingFileOutput extends LogOutput {
  new(this._log);

  final RotatingFileLog _log;

  @override
  void output(OutputEvent event) => _log._append(event.lines);
}
