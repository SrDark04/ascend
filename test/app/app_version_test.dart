import 'dart:io';

import 'package:ascend/app/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_version.dart coincide con pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\S+)\+(\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!;
    expect(appVersion, match[1], reason: 'actualiza lib/app/app_version.dart');
    expect(appBuildNumber, int.parse(match[2]!));
  });
}
