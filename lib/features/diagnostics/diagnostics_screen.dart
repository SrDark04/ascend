import 'dart:async';

import 'package:ascend/app/app_config.dart';
import 'package:ascend/app/app_version.dart';
import 'package:ascend/app/providers.dart';
import 'package:ascend/app/router.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/ascend_button.dart';
import 'package:ascend/ui/theme/ascend_colors.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:ascend/ui/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla oculta de diagnóstico (§5.5.7): versión, BD, últimos errores
/// y «Exportar log». Solo en dev: catálogo de diseño y galería de niveles.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  late Future<List<String>> _errors = ref
      .read(logStoreProvider)
      .recentErrors(limit: 10);
  bool _exporting = false;

  Future<void> _exportLog() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final config = ref.read(appConfigProvider);
    setState(() => _exporting = true);
    try {
      final path = await ref
          .read(logStoreProvider)
          .exportToFile(
            header:
                '${config.appName} $appVersion+$appBuildNumber '
                '(${config.flavor.name})',
          );
      await ref
          .read(fileSharerProvider)
          .shareFile(path, subject: l10n.exportLogSubject);
    } on Exception catch (e, s) {
      ref.read(appLogProvider).error('Exportar log falló', e, s);
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportLogFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _errors = ref.read(logStoreProvider).recentErrors(limit: 10);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.ascendColors;

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AscendSpacing.xl),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.versionLabel),
            subtitle: Text(
              l10n.versionValue(appVersion, appBuildNumber, config.flavor.name),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: Text(l10n.diagnosticsFlavor(config.flavor.name)),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.diagnosticsDatabase(config.databaseName)),
            subtitle: Text(l10n.diagnosticsSchemaPending),
          ),
          header(l10n.diagnosticsRecentErrors),
          FutureBuilder<List<String>>(
            future: _errors,
            builder: (context, snapshot) {
              final errors = snapshot.data;
              if (errors == null) {
                return const Padding(
                  padding: EdgeInsets.all(AscendSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (errors.isEmpty) {
                return ListTile(
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: colors.success,
                  ),
                  title: Text(l10n.diagnosticsNoErrors),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AscendSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final e in errors.reversed)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AscendSpacing.sm,
                        ),
                        child: Text(
                          e,
                          style: ascendMonoStyle(context, size: 13),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AscendSpacing.lg),
            child: AscendButton(
              label: l10n.exportLogAction,
              icon: Icons.ios_share,
              variant: AscendButtonVariant.secondary,
              expanded: true,
              onPressed: _exporting ? null : () => unawaited(_exportLog()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AscendSpacing.lg),
            child: Text(
              l10n.exportLogPrivacy,
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (config.isDev) ...[
            header(l10n.diagnosticsDevTools),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.designSystemTitle),
              subtitle: Text(l10n.designSystemSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRoutes.designSystem),
            ),
            ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: Text(l10n.levelGalleryTitle),
              subtitle: Text(l10n.levelGallerySubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRoutes.levelGallery),
            ),
          ],
        ],
      ),
    );
  }
}
