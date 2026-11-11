import 'package:ascend/app/app_config.dart';
import 'package:ascend/app/app_version.dart';
import 'package:ascend/app/providers.dart';
import 'package:ascend/app/router.dart';
import 'package:ascend/domain/common/units.dart';
import 'package:ascend/domain/settings/theme_preference.dart';
import 'package:ascend/features/settings/theme_controller.dart';
import 'package:ascend/features/settings/weight_unit_controller.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pestaña Perfil: ajustes de tema y unidades, y «Acerca de». Siete toques
/// sobre la versión abren Diagnóstico (§5.5.7).
class ProfileScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// Toques necesarios sobre la versión.
  static const tapsToDiagnostics = 7;

  /// Desde este toque se avisa de cuántos faltan.
  static const hintFromTap = 4;

  /// Pausa máxima entre toques antes de reiniciar la cuenta.
  static const tapWindow = Duration(seconds: 3);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _taps = 0;
  DateTime? _lastTap;

  void _onVersionTap() {
    final now = ref.read(clockProvider).now();
    final last = _lastTap;
    if (last == null || now.difference(last) > ProfileScreen.tapWindow) {
      _taps = 0;
    }
    _lastTap = now;
    _taps++;

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (_taps >= ProfileScreen.tapsToDiagnostics) {
      _taps = 0;
      _lastTap = null;
      context.go(AppRoutes.diagnostics);
    } else if (_taps >= ProfileScreen.hintFromTap) {
      final left = ProfileScreen.tapsToDiagnostics - _taps;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diagnosticsTapsLeft(left)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.ascendColors;
    final config = ref.watch(appConfigProvider);
    final themePreference = ref.watch(themePreferenceProvider);
    final unit = ref.watch(weightUnitProvider);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AscendSpacing.lg,
        AscendSpacing.xl,
        AscendSpacing.lg,
        AscendSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(text.toUpperCase(), style: theme.textTheme.headlineSmall),
      ),
    );

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AscendSpacing.lg),
      child: child,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AscendSpacing.xl),
        children: [
          header(l10n.themeSectionTitle),
          padded(
            SegmentedButton<ThemePreference>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemePreference.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(l10n.themeOptionSystem),
                ),
                ButtonSegment(
                  value: ThemePreference.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l10n.themeOptionLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l10n.themeOptionDark),
                ),
              ],
              selected: {themePreference},
              onSelectionChanged: (s) =>
                  ref.read(themePreferenceProvider.notifier).select(s.first),
            ),
          ),
          header(l10n.unitsSectionTitle),
          padded(
            SegmentedButton<WeightUnit>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: WeightUnit.kg,
                  label: Text(l10n.unitOptionKg),
                ),
                ButtonSegment(
                  value: WeightUnit.lb,
                  label: Text(l10n.unitOptionLb),
                ),
              ],
              selected: {unit},
              onSelectionChanged: (s) =>
                  ref.read(weightUnitProvider.notifier).select(s.first),
            ),
          ),
          padded(
            Padding(
              padding: const EdgeInsets.only(top: AscendSpacing.sm),
              child: Text(
                l10n.unitsStorageNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
          header(l10n.aboutSectionTitle),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.versionLabel),
            subtitle: Text(
              l10n.versionValue(appVersion, appBuildNumber, config.flavor.name),
            ),
            onTap: _onVersionTap,
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.licensesLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: config.appName,
              applicationVersion: appVersion,
            ),
          ),
        ],
      ),
    );
  }
}
