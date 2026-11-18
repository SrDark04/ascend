import 'package:ascend/domain/streak/ascend_levels.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';

/// Traduce la [AscendLevel.nameKey] del dominio al texto del ARB.
extension AscendLevelL10n on AppLocalizations {
  String ascendLevelName(AscendLevel level) => switch (level.nameKey) {
    'ascendLevel1' => ascendLevel1,
    'ascendLevel2' => ascendLevel2,
    'ascendLevel3' => ascendLevel3,
    'ascendLevel4' => ascendLevel4,
    'ascendLevel5' => ascendLevel5,
    'ascendLevel6' => ascendLevel6,
    final key => throw ArgumentError.value(key, 'nameKey', 'sin traducción'),
  };
}
