import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/coming_soon/coming_soon_screen.dart';
import '../features/crops/crop_detail_screen.dart';
import '../features/crops/crop_form_screen.dart';
import '../features/fields/field_detail_screen.dart';
import '../features/fields/field_form_screen.dart';
import '../features/fields/fields_screen.dart';
import '../features/home/home_screen.dart';
import '../features/login/login_controller.dart';
import '../features/login/login_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_tabs_shell.dart';
import '../shared/testing/test_ids.dart';
import 'app_routes.dart';

export 'app_routes.dart';

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
          StatefulShellBranch(routes: <RouteBase>[_fieldsRoute()]),
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

/// The Fields tab and everything inside it.
///
/// These are child routes, so the tab bar stays visible and the Fields tab
/// keeps its place when the user moves between tabs.
GoRoute _fieldsRoute() {
  return GoRoute(
    path: AppRoutes.fields,
    builder: (BuildContext context, GoRouterState state) =>
        const FieldsScreen(),
    routes: <RouteBase>[
      // "new" comes first, so it is never read as a field id.
      GoRoute(
        path: 'new',
        builder: (BuildContext context, GoRouterState state) =>
            const FieldFormScreen(),
      ),
      GoRoute(
        path: ':${AppRoutes.fieldIdParam}',
        builder: (BuildContext context, GoRouterState state) =>
            FieldDetailScreen(fieldId: _fieldId(state)),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) =>
                FieldFormScreen(fieldId: _fieldId(state)),
          ),
          GoRoute(
            path: 'crops/new',
            builder: (BuildContext context, GoRouterState state) =>
                CropFormScreen(fieldId: _fieldId(state)),
          ),
          GoRoute(
            path: 'crops/:${AppRoutes.cropIdParam}',
            builder: (BuildContext context, GoRouterState state) =>
                CropDetailScreen(
                  fieldId: _fieldId(state),
                  cropId: state.pathParameters[AppRoutes.cropIdParam] ?? '',
                ),
          ),
        ],
      ),
    ],
  );
}

String _fieldId(GoRouterState state) =>
    state.pathParameters[AppRoutes.fieldIdParam] ?? '';
