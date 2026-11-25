import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/demo_accounts.dart';
import '../data/farm_repository.dart';
import '../data/task_models.dart';
import '../features/login/login_controller.dart';
import '../features/settings/theme_controller.dart';
import '../notifications/notification_service.dart';
import '../shared/logic/app_clock.dart';
import '../shared/app_info/app_version_reader.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'deep_links.dart';

/// The root widget: themes, providers and the router.
class HarvestlyApp extends StatefulWidget {
  const HarvestlyApp({
    super.key,
    required this.loginController,
    required this.themeController,
    required this.farmRepository,
    required this.notifications,
    required this.appVersion,
  });

  final LoginController loginController;
  final ThemeController themeController;
  final FarmRepository farmRepository;
  final NotificationService notifications;
  final AppVersion appVersion;

  @override
  State<HarvestlyApp> createState() => _HarvestlyAppState();
}

class _HarvestlyAppState extends State<HarvestlyApp>
    with WidgetsBindingObserver {
  /// Lets the router show a snackbar when a link points at nothing.
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final GoRouter _router = createAppRouter(
    loginController: widget.loginController,
    messengerKey: _messengerKey,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The data layer knows nothing about notifications, so the app is what
    // joins them: every task change here books the reminders again.
    widget.farmRepository.onRemindersChanged = _syncReminders;
    widget.notifications.onOpenTask = _openTask;
    widget.notifications.onForegroundAction = _runAction;

    _syncFarmData();
    widget.loginController.addListener(_syncFarmData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A notification that started the app opens its task.
      unawaited(widget.notifications.handleLaunch());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.loginController.removeListener(_syncFarmData);
    widget.farmRepository.onRemindersChanged = null;
    widget.notifications.onOpenTask = null;
    widget.notifications.onForegroundAction = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // A notification button may have changed the saved data from another
    // isolate while Harvestly was closed, so the data is read again.
    unawaited(widget.farmRepository.reloadFromDisk());
  }

  /// Books the reminders for the tasks the account has now.
  void _syncReminders(String? email, List<FarmTask> tasks) {
    widget.notifications.setLinkNames(<String, String>{
      for (final FarmTask task in tasks)
        task.id: widget.farmRepository.linkNameFor(task),
    });
    unawaited(widget.notifications.rescheduleAll(email: email, tasks: tasks));
  }

  /// Opens the task a notification points at, through the deep link rules.
  void _openTask(NotificationPayload payload) {
    final String? path = DeepLinks.safePath(payload.route);
    if (path == null) return;
    // The router sends the user to login first when they are logged out,
    // and comes back here once they are in.
    _router.go(path);
  }

  /// Runs a notification button pressed while Harvestly is open.
  Future<void> _runAction(String actionId, NotificationPayload payload) async {
    final FarmRepository repository = widget.farmRepository;
    if (repository.accountEmail != payload.email) return;

    if (actionId == NotificationService.markDoneActionId) {
      await repository.completeTask(payload.taskId);
    } else if (actionId == NotificationService.snoozeActionId) {
      await repository.snoozeTask(
        taskId: payload.taskId,
        until: AppClock.now().add(NotificationService.snoozeFor),
      );
    }
  }

  /// Keeps the loaded farm data on the account that is logged in.
  void _syncFarmData() {
    final DemoAccount? account = widget.loginController.account;
    if (account == null) {
      widget.farmRepository.closeAccount();
    } else {
      widget.farmRepository.openAccount(
        email: account.email,
        accountId: account.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginController>.value(
          value: widget.loginController,
        ),
        ChangeNotifierProvider<ThemeController>.value(
          value: widget.themeController,
        ),
        ChangeNotifierProvider<FarmRepository>.value(
          value: widget.farmRepository,
        ),
        Provider<NotificationService>.value(value: widget.notifications),
        Provider<AppVersion>.value(value: widget.appVersion),
      ],
      child: Consumer<ThemeController>(
        builder: (BuildContext context, ThemeController theme, Widget? _) {
          return MaterialApp.router(
            title: 'Harvestly',
            scaffoldMessengerKey: _messengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            routerConfig: _router,
            builder: (BuildContext context, Widget? child) {
              // Keeps the status bar icons readable in both themes.
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.overlayStyle(Theme.of(context).brightness),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
