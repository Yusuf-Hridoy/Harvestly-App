import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/animals/animals_screen.dart';
import '../features/animals/group_detail_screen.dart';
import '../features/animals/group_form_screen.dart';
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
import '../features/tasks/task_detail_screen.dart';
import '../features/tasks/task_form_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../shared/widgets/app_snackbar.dart';
import 'app_routes.dart';
import 'deep_links.dart';

export 'app_routes.dart';

/// Builds the router.
///
/// Not logged in: every route goes to /login, remembering where the user was
/// headed so a deep link still works after they log in.
/// Logged in: /login goes there, or to /home when there is nowhere to go
/// back to.
GoRouter createAppRouter({
  required LoginController loginController,
  GlobalKey<ScaffoldMessengerState>? messengerKey,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.home,
    refreshListenable: loginController,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = loginController.isLoggedIn;
      final bool goingToLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn) {
        if (goingToLogin) return null;
        // A link opened while logged out waits at the login screen.
        final String? from = DeepLinks.safePath(state.uri.toString());
        return from == null ? AppRoutes.login : AppRoutes.loginFrom(from);
      }

      if (goingToLogin) {
        // Anything unsafe in "from" is ignored and Home opens instead.
        return DeepLinks.safePath(
              state.uri.queryParameters[AppRoutes.fromQuery],
            ) ??
            AppRoutes.home;
      }
      return null;
    },

    // A link to a path Harvestly does not have. Home opens instead, with
    // a line saying why. No error screen is built, because putting one
    // beside the tab shell would use the shell's key twice.
    onException: (BuildContext context, GoRouterState state, GoRouter router) {
      router.go(AppRoutes.home);
      _sayBadLink(messengerKey);
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
          StatefulShellBranch(routes: <RouteBase>[_animalsRoute()]),
          StatefulShellBranch(routes: <RouteBase>[_tasksRoute()]),
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

/// The Animals tab and everything inside it.
///
/// Like the Fields tab, these are child routes, so the tab bar stays visible
/// and the Animals tab keeps its place.
GoRoute _animalsRoute() {
  return GoRoute(
    path: AppRoutes.animals,
    builder: (BuildContext context, GoRouterState state) =>
        const AnimalsScreen(),
    routes: <RouteBase>[
      // "new" comes first, so it is never read as a group id.
      GoRoute(
        path: 'new',
        builder: (BuildContext context, GoRouterState state) =>
            const GroupFormScreen(),
      ),
      GoRoute(
        path: ':${AppRoutes.groupIdParam}',
        builder: (BuildContext context, GoRouterState state) =>
            GroupDetailScreen(
              groupId: _groupId(state),
              tab: state.uri.queryParameters[AppRoutes.tabQuery],
            ),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) =>
                GroupFormScreen(groupId: _groupId(state)),
          ),
        ],
      ),
    ],
  );
}

/// Says a link went nowhere, once there is a screen to say it on.
///
/// A link can arrive before the app has drawn anything, and then there is
/// no messenger to show a snackbar on yet, so this waits a few frames for
/// one instead of giving up on the first try.
void _sayBadLink(
  GlobalKey<ScaffoldMessengerState>? messengerKey, [
  int tries = 0,
]) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ScaffoldMessengerState? messenger = messengerKey?.currentState;
    if (messenger == null) {
      if (tries < 20) _sayBadLink(messengerKey, tries + 1);
      return;
    }
    AppSnackbar.showOn(messenger, DeepLinks.badLinkMessage);
  });
}

/// The Tasks tab and everything inside it.
///
/// Child routes again, so the tab bar stays visible and the Tasks tab keeps
/// its place.
GoRoute _tasksRoute() {
  return GoRoute(
    path: AppRoutes.tasks,
    builder: (BuildContext context, GoRouterState state) => const TasksScreen(),
    routes: <RouteBase>[
      // "new" comes first, so it is never read as a task id.
      GoRoute(
        path: 'new',
        builder: (BuildContext context, GoRouterState state) =>
            const TaskFormScreen(),
      ),
      GoRoute(
        path: ':${AppRoutes.taskIdParam}',
        builder: (BuildContext context, GoRouterState state) =>
            TaskDetailScreen(taskId: _taskId(state)),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) =>
                TaskFormScreen(taskId: _taskId(state)),
          ),
        ],
      ),
    ],
  );
}

String _taskId(GoRouterState state) =>
    state.pathParameters[AppRoutes.taskIdParam] ?? '';

String _fieldId(GoRouterState state) =>
    state.pathParameters[AppRoutes.fieldIdParam] ?? '';

String _groupId(GoRouterState state) =>
    state.pathParameters[AppRoutes.groupIdParam] ?? '';
