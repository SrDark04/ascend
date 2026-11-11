import 'package:ascend/l10n/gen/app_localizations.dart';
import 'package:ascend/ui/components/empty_state.dart';
import 'package:flutter/material.dart';

/// Pestaña Entrenar. Por ahora, estado vacío.
class TrainScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabTrain)),
      body: EmptyState(
        icon: Icons.fitness_center_outlined,
        title: l10n.trainEmptyTitle,
        message: l10n.trainEmptyMessage,
      ),
    );
  }
}
