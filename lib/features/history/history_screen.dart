import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/empty_state.dart';
import 'package:flutter/material.dart';

/// Pestaña Historial. Por ahora, estado vacío.
class HistoryScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHistory)),
      body: EmptyState(
        icon: Icons.calendar_month_outlined,
        title: l10n.historyEmptyTitle,
        message: l10n.historyEmptyMessage,
      ),
    );
  }
}
