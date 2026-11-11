import 'package:ascend/app/app_config.dart';
import 'package:ascend/features/diagnostics/design_system_screen.dart';
import 'package:ascend/features/diagnostics/diagnostics_screen.dart';
import 'package:ascend/features/history/history_screen.dart';
import 'package:ascend/features/levels/level_gallery_screen.dart';
import 'package:ascend/features/profile/profile_screen.dart';
import 'package:ascend/features/progress/progress_screen.dart';
import 'package:ascend/features/shell/app_shell.dart';
import 'package:ascend/features/today/today_screen.dart';
import 'package:ascend/features/workout/train_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Rutas de la app (§7.4).
abstract final class AppRoutes {
  static const today = '/today';
  static const train = '/train';
  static const history = '/history';
  static const progress = '/progress';
  static const profile = '/profile';
  static const diagnostics = '/profile/diagnostics';
  static const designSystem = '/profile/diagnostics/design-system';
  static const levelGallery = '/profile/diagnostics/levels';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(ref.watch(appConfigProvider));
  ref.onDispose(router.dispose);
  return router;
});

/// go_router con `StatefulShellRoute`: 5 pestañas que conservan su estado.
GoRouter buildRouter(AppConfig config, {String? initialLocation}) {
  // Las herramientas de desarrollo no existen en prod aunque se escriba
  // la ruta a mano.
  String? devOnly(GoRouterState state) =>
      config.isDev ? null : AppRoutes.diagnostics;

  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.train,
                builder: (_, _) => const TrainScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (_, _) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'diagnostics',
                    builder: (_, _) => const DiagnosticsScreen(),
                    routes: [
                      GoRoute(
                        path: 'design-system',
                        redirect: (_, state) => devOnly(state),
                        builder: (_, _) => const DesignSystemScreen(),
                      ),
                      GoRoute(
                        path: 'levels',
                        redirect: (_, state) => devOnly(state),
                        builder: (_, _) => const LevelGalleryScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
