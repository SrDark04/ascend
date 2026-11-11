import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
import 'package:ascend/features/settings/theme_controller.dart';
import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/ascend_button.dart';
import 'package:ascend/ui/theme/ascend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de la app. El router llega en 0.6.
class AscendApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final themeMode = ref.watch(themePreferenceProvider).themeMode;
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      // Barras del sistema acordes al tema también en pantallas sin AppBar.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: child!,
      ),
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
            Text(
              config.appName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            // En dev, acceso directo a Diagnóstico mientras no exista Perfil.
            if (config.isDev) ...[
              const SizedBox(height: 16),
              AscendButton(
                variant: AscendButtonVariant.secondary,
                icon: Icons.bug_report_outlined,
                label: l10n.diagnosticsTitle,
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
