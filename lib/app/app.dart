import 'package:ascend/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de la app. El tema, el router y la l10n llegan en 0.5–0.6.
class AscendApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text(config.appName))),
    );
  }
}
