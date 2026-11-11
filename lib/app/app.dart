import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de la app. El tema propio llega en 0.5 y el router en 0.6.
class AscendApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Provisional hasta 0.5: respeta el modo claro/oscuro del sistema.
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const _PlaceholderHome(),
    );
  }
}

/// Pantalla provisional hasta el esqueleto de 5 pestañas (0.6).
class _PlaceholderHome extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(config.appName),
            // En dev, acceso directo a Diagnóstico mientras no exista Perfil.
            if (config.isDev) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(l10n.diagnosticsTitle),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DiagnosticsScreen(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
