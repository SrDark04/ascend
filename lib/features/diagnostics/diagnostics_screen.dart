import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/design_system_screen.dart';
import 'package:ascend/features/levels/level_gallery_screen.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla oculta de diagnóstico (§5.5.7). Por ahora muestra el flavor y,
/// solo en dev, la galería de niveles. En 0.6 se le añaden versión, esquema
/// de BD, errores y «Exportar log», y se abre con 7 toques en la versión.
class DiagnosticsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: Text(l10n.diagnosticsFlavor(config.flavor.name)),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.diagnosticsDatabase(config.databaseName)),
          ),
          if (config.isDev) ...[
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.designSystemTitle),
              subtitle: Text(l10n.designSystemSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DesignSystemScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: Text(l10n.levelGalleryTitle),
              subtitle: Text(l10n.levelGallerySubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LevelGalleryScreen(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
