import 'dart:io';

import 'package:ascend/domain/common/clock.dart';
import 'package:ascend/infrastructure/logging/rotating_file_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late FixedClock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ascend_log_');
    clock = FixedClock(DateTime(2026, 11, 10, 20, 15, 3, 120));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  RotatingFileLog make({int maxBytes = 512 * 1024}) =>
      RotatingFileLog(directory: dir, clock: clock, maxBytes: maxBytes);

  test('escribe una línea por entrada con la hora del Clock', () {
    make()
      ..info('Arranque dev')
      ..error('Falló algo', StateError('boom'), StackTrace.current);
    final lines = File('${dir.path}/ascend.log').readAsLinesSync();
    expect(lines.first, '2026-11-10T20:15:03.120 INFO Arranque dev');
    expect(
      lines[1],
      '2026-11-10T20:15:03.120 ERROR Falló algo :: Bad state: boom',
    );
    expect(lines[2], startsWith('  '), reason: 'traza sangrada');
  });

  test('rota al superar el tamaño y conserva solo maxFiles archivos', () {
    final log = make(maxBytes: 200);
    for (var i = 0; i < 40; i++) {
      log.info('entrada número $i con algo de texto de relleno');
    }
    final names = dir.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {'ascend.log', 'ascend.1.log', 'ascend.2.log'});
    expect(File('${dir.path}/ascend.log').readAsStringSync(), contains('39'));
  });

  test('recentErrors devuelve solo errores, los más recientes', () async {
    final log = make();
    for (var i = 0; i < 5; i++) {
      log
        ..info('info $i')
        ..error('error $i', Exception('e$i'), StackTrace.current);
    }
    final errors = await log.recentErrors(limit: 3);
    expect(errors, hasLength(3));
    expect(errors.first, contains('error 2'));
    expect(errors.last, contains('error 4'));
    expect(errors.every((e) => e.contains(' ERROR ')), isTrue);
  });

  test('exportToFile une archivos con cabecera y fecha del Clock', () async {
    final log = make(maxBytes: 200);
    for (var i = 0; i < 10; i++) {
      log.info('línea $i ocupando espacio para forzar la rotación');
    }
    final path = await log.exportToFile(header: 'Ascend Dev 0.1.0+1 (dev)');
    expect(path, endsWith('ascend-log-2026-11-10.txt'));
    final content = File(path).readAsStringSync();
    expect(content, startsWith('Ascend Dev 0.1.0+1 (dev)\n\n'));
    // Orden cronológico: la primera línea que sobrevive va antes que la última.
    expect(content.indexOf('línea 9'), greaterThan(content.indexOf('línea 8')));
  });
}
