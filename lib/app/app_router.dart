import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/coming_soon/coming_soon_screen.dart';
import '../features/home/home_screen.dart';
import '../features/login/login_controller.dart';
import '../features/login/login_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_tabs_shell.dart';
import '../shared/testing/test_ids.dart';

/// Every route in Harvestly, plus the login guard.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String fields = '/fields';
  static const String animals = '/animals';
  static const String tasks = '/tasks';
  static const String more = '/more';
}

/// Builds the router.
///
/// Not logged in: every route goes to /login.
/// Logged in: /login goes to /home.
GoRouter createAppRouter({
  required LoginController loginController,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.home,
    refreshListenable: loginController,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = loginController.isLoggedIn;
      final bool goingToLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn) return goingToLogin ? null : AppRoutes.login;
      if (goingToLogin) return AppRoutes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) => MainTabsShell(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.fields,
                builder: (BuildContext context, GoRouterState state) =>
                    const ComingSoonScreen(
                      testId: TestIds.fieldsComingSoonScreen,
                      title: 'Fields',
                      icon: Icons.grid_view_rounded,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.animals,
                builder: (BuildContext context, GoRouterState state) =>
                    const ComingSoonScreen(
                      testId: TestIds.animalsComingSoonScreen,
                      title: 'Animals',
                      icon: Icons.egg_rounded,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.tasks,
                builder: (BuildContext context, GoRouterState state) =>
                    const ComingSoonScreen(
                      testId: TestIds.tasksComingSoonScreen,
                      title: 'Tasks',
                      icon: Icons.task_alt_rounded,
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.more,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
