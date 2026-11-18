import 'package:ascend/app/app_config.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Monta [child] con l10n en español y el [config] indicado.
  Future<void> pumpApp(
    Widget child, {
    AppConfig config = AppConfig.dev,
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(config)],
        child: MaterialApp(
          theme: buildTheme(brightness),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: child,
        ),
      ),
    );
  }
}
