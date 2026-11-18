import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/empty_state.dart';
import 'package:flutter/material.dart';

/// Pestaña Hoy. Por ahora, estado vacío.
class TodayScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabToday)),
      body: EmptyState(
        icon: Icons.local_fire_department_outlined,
        title: l10n.todayEmptyTitle,
        message: l10n.todayEmptyMessage,
      ),
    );
  }
}
