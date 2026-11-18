import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/empty_state.dart';
import 'package:flutter/material.dart';

/// Pestaña Progreso. Por ahora, estado vacío.
class ProgressScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProgress)),
      body: EmptyState(
        icon: Icons.trending_up,
        title: l10n.progressEmptyTitle,
        message: l10n.progressEmptyMessage,
      ),
    );
  }
}
