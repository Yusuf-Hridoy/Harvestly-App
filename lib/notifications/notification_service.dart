import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/task_models.dart';
import '../data/task_rules.dart';
import '../shared/logic/app_clock.dart';
import 'android_settings_channel.dart';

/// What Android says about notifications for Harvestly right now.
enum NotificationPermission {
  /// Notifications show.
  allowed,

  /// Refused, blocked, or turned off in Android's settings.
  off,

  /// Android 13 or newer, and the user has not been asked yet.
  notAsked,
}

/// One reminder waiting to be scheduled.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    required this.payload,
  });

  /// The notification id, stable for one task.
  final int id;
  final String title;

  /// "Duck pond · due at 5:00 PM".
  final String body;

  /// The local time the reminder should show.
  final DateTime at;

  /// The JSON a tap or a button gets back.
  final String payload;
}

/// What a notification carries, so a tap knows where to go and a button can
/// act without the app open.
class NotificationPayload {
  const NotificationPayload({required this.email, required this.taskId});

  /// The payload on the test notification, which belongs to no task.
  const NotificationPayload.home() : email = '', taskId = '';

  /// Reads a payload, or null when it is missing or not Harvestly's.
  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      if (json['route'] == homeRoute) return const NotificationPayload.home();
      final Object? email = json['email'];
      final Object? taskId = json['taskId'];
      if (email is! String || taskId is! String) return null;
      return NotificationPayload(email: email, taskId: taskId);
    } catch (_) {
      return null;
    }
  }

  /// Where a tap on the test notification goes.
  static const String homeRoute = '/home';

  /// Which account the task belongs to. The background handler needs this,
  /// because it has no logged-in user to ask. Empty on the test one.
  final String email;

  /// Empty on the test notification, which belongs to no task.
  final String taskId;

  /// True for the test notification.
  bool get isHome => taskId.isEmpty;

  /// The deep link path a tap should open.
  String get route => isHome ? homeRoute : '/tasks/$taskId';

  String encode() => jsonEncode(
    isHome
        ? <String, String>{'route': homeRoute}
        : <String, String>{'email': email, 'taskId': taskId},
  );
}

/// A reminder Android is holding: either still waiting, or already in
/// the shade.
class LiveNotification {
  const LiveNotification({required this.id, this.title, this.body});

  final int id;

  /// What the notification reads now, which is how a stale one is spotted.
  final String? title;
  final String? body;
}

/// The small part of the notification plugin Harvestly uses.
///
/// Having an interface here means the tests can hand the service a fake and
/// check what it asked for, with no Android in the way.
abstract class NotificationPlugin {
  /// Sets up the plugin and the one Android channel.
  Future<void> start({
    required void Function(NotificationPayload payload, String? actionId)
    onResponse,
  });

  /// Whether Android shows notifications for Harvestly.
  Future<bool> areEnabled();

  /// Shows Android's own permission pop-up and returns what the user chose.
  Future<bool> requestPermission();

  /// Books one reminder. Replaces any reminder with the same id.
  Future<void> schedule(PlannedReminder reminder);

  /// Shows a notification straight away, with no buttons.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Removes one notification, shown or still waiting.
  Future<void> cancel(int id);

  /// Removes every Harvestly notification, shown ones included.
  Future<void> cancelAll();

  /// The ids of reminders that are booked but have not shown yet.
  Future<List<int>> pendingIds();

  /// The reminders that are in the notification shade right now.
  Future<List<LiveNotification>> shownNotifications();

  /// The payload of the notification that started the app, if one did.
  Future<NotificationPayload?> launchPayload();
}

/// Reminders, the permission flow and the test notification, in one place.
///
/// Every screen talks to this and never to the plugin, so a test can swap in
/// a fake plugin and still walk the whole flow.
class NotificationService {
  NotificationService({
    required this.plugin,
    required SharedPreferences prefs,
    this.settings = const AndroidSettingsChannel(),
    // ignore: prefer_initializing_formals
  }) : _prefs = prefs;

  /// The one Android channel every reminder goes through.
  static const String channelId = 'task_reminders';
  static const String channelName = 'Task reminders';

  /// The two buttons on a reminder.
  static const String markDoneActionId = 'mark_done';
  static const String snoozeActionId = 'snooze_1_hour';
  static const String markDoneLabel = 'Mark done';
  static const String snoozeLabel = 'Snooze 1 hour';

  /// How far Snooze pushes a reminder back.
  static const Duration snoozeFor = Duration(hours: 1);

  /// The test notification from Settings.
  static const Duration testWait = Duration(seconds: 10);
  static const int testNotificationId = 1;
  static const String testTitle = 'Test reminder';
  static const String testBody = 'Notifications are working.';

  /// Where "we already asked for the permission" is remembered.
  static const String askedKey = 'notifications_asked';

  /// The plugin this service drives. Tests pass a fake.
  final NotificationPlugin plugin;

  /// The bridge to Android's own notification page and version.
  final AndroidSettingsChannel settings;

  final SharedPreferences _prefs;

  /// Called when a notification or one of its buttons opens the app.
  void Function(NotificationPayload payload)? onOpenTask;

  /// Called when a button was pressed while the app was open, so the screens
  /// can show the change at once.
  Future<void> Function(String actionId, NotificationPayload payload)?
  onForegroundAction;

  /// The notification id for a task. The same task always gets the same
  /// number, so editing replaces its reminder and deleting cancels it.
  ///
  /// Test notification id 1 is kept out of the way by starting at 2.
  static int notificationIdFor(String taskId) {
    int hash = 7;
    for (final int unit in taskId.codeUnits) {
      hash = (hash * 31 + unit) & 0x3FFFFFFF;
    }
    return 2 + (hash % 0x3FFFFFFD);
  }

  /// "Duck pond · due at 5:00 PM", the line under the task title.
  static String bodyFor(FarmTask task, String linkName) =>
      '$linkName · due at ${_time(task.dueAt)}';

  static String _time(DateTime when) {
    final int hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
    final String minute = when.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${when.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Starts the plugin. Call it once, before anything else here.
  Future<void> start() async {
    await plugin.start(onResponse: _onResponse);
  }

  /// Opens the task a notification was tapped for, if the app was started
  /// that way.
  Future<void> handleLaunch() async {
    final NotificationPayload? payload = await plugin.launchPayload();
    if (payload != null) onOpenTask?.call(payload);
  }

  void _onResponse(NotificationPayload payload, String? actionId) {
    if (actionId == null) {
      onOpenTask?.call(payload);
      return;
    }
    // A button pressed while the app is open. The same work happens in the
    // background handler when the app is closed.
    unawaited(onForegroundAction?.call(actionId, payload));
  }

  /// What Android says about notifications right now.
  Future<NotificationPermission> permission() async {
    if (await plugin.areEnabled()) return NotificationPermission.allowed;
    // Below Android 13 there is no pop-up to show, so "not allowed" can only
    // mean the user turned notifications off themselves.
    final bool canAsk =
        await settings.sdkInt() >= AndroidSettingsChannel.android13;
    if (canAsk && !askedBefore) return NotificationPermission.notAsked;
    return NotificationPermission.off;
  }

  /// Whether Harvestly has ever shown Android's permission pop-up.
  bool get askedBefore => _prefs.getBool(askedKey) ?? false;

  /// Shows Android's permission pop-up and returns whether it was allowed.
  ///
  /// Asking is remembered, so the pop-up is never shown twice.
  Future<bool> requestPermission() async {
    await _prefs.setBool(askedKey, true);
    return plugin.requestPermission();
  }

  /// Opens Android's notification page for Harvestly.
  Future<bool> openAndroidSettings() => settings.openNotificationSettings();

  /// Books every reminder this account still needs, and drops the rest.
  ///
  /// Called after login, at app start, after Reset demo data and after any
  /// task change. Logging out passes no email, which clears the lot.
  ///
  /// A reminder the user has not read yet is left alone. Only the ones that
  /// no longer match a task are taken out of the shade, so opening the app
  /// for some other reason never wipes a reminder off the screen.
  Future<void> rescheduleAll({
    required String? email,
    required List<FarmTask> tasks,
  }) {
    // Two changes in quick succession would otherwise overlap: the second
    // cancelAll could wipe bookings the first had just made. Each run waits
    // for the one before it, so the last one always wins.
    _booking = _booking
        .then((_) => _rescheduleAll(email: email, tasks: tasks))
        // One failed run must not poison every run after it.
        .catchError(
          (Object error) => debugPrint(
            'Harvestly notifications: could not book the reminders ($error)',
          ),
        );
    return _booking;
  }

  Future<void> _booking = Future<void>.value();

  Future<void> _rescheduleAll({
    required String? email,
    required List<FarmTask> tasks,
  }) async {
    // Logging out takes everything away, read or not.
    if (email == null) {
      await plugin.cancelAll();
      return;
    }

    // Everything still waiting goes, and the ones that still apply are
    // booked again below.
    for (final int id in await plugin.pendingIds()) {
      await plugin.cancel(id);
    }

    final Map<int, FarmTask> byId = <int, FarmTask>{
      for (final FarmTask task in tasks) notificationIdFor(task.id): task,
    };
    for (final LiveNotification shown in await plugin.shownNotifications()) {
      // The test notification belongs to no task, so it is left alone.
      if (shown.id == testNotificationId) continue;
      if (_hasMovedOn(byId[shown.id], shown)) await plugin.cancel(shown.id);
    }

    if (!await plugin.areEnabled()) return;

    final DateTime now = AppClock.now();
    for (final FarmTask task in tasks) {
      final DateTime? at = TaskRules.reminderTime(task);
      // Only times still to come can be booked, and a done task has none.
      if (at == null || !at.isAfter(now)) continue;
      await plugin.schedule(
        PlannedReminder(
          id: notificationIdFor(task.id),
          title: task.title,
          body: bodyFor(task, _linkNames[task.id] ?? TaskRules.generalName),
          at: at,
          payload: NotificationPayload(email: email, taskId: task.id).encode(),
        ),
      );
    }
  }

  /// Whether a reminder already in the shade is out of date.
  ///
  /// It stays unless its task is gone, finished, had its reminder taken
  /// off, was moved to a later time, or now reads differently.
  bool _hasMovedOn(FarmTask? task, LiveNotification shown) {
    // No task with that id in this account: deleted, or another account's.
    if (task == null) return true;
    if (task.isDone) return true;

    final DateTime? at = TaskRules.reminderTime(task);
    if (at == null) return true;
    // A later time means this one is for a moment that no longer counts.
    if (at.isAfter(AppClock.now())) return true;

    if (shown.title != null && shown.title != task.title) return true;
    final String body = bodyFor(
      task,
      _linkNames[task.id] ?? TaskRules.generalName,
    );
    if (shown.body != null && shown.body != body) return true;
    return false;
  }

  /// The field or group name to show on each task's reminder, by task id.
  ///
  /// The service does not know about fields and groups, so the app fills
  /// this in just before rescheduling.
  Map<String, String> get linkNames => _linkNames;
  final Map<String, String> _linkNames = <String, String>{};

  /// Replaces the link names used on reminder lines.
  void setLinkNames(Map<String, String> names) {
    _linkNames
      ..clear()
      ..addAll(names);
  }

  /// Sends the test notification after a 10 second wait.
  ///
  /// The wait happens inside the app, so nothing is sent if the app is
  /// closed first. That is on purpose: it gives a tester a notification
  /// that only arrives while the app runs.
  Future<void> sendTest() async {
    await Future<void>.delayed(testWait);
    await plugin.showNow(
      id: testNotificationId,
      title: testTitle,
      body: testBody,
      // Tapping it opens Home, through the same deep link rules a
      // reminder's tap goes through.
      payload: const NotificationPayload.home().encode(),
    );
  }

  /// Removes every notification. Used when logging out.
  Future<void> cancelAll() => plugin.cancelAll();
}

/// The real plugin, wrapped so the rest of the app never imports it.
class LocalNotificationPlugin implements NotificationPlugin {
  LocalNotificationPlugin({
    FlutterLocalNotificationsPlugin? plugin,
    this.backgroundHandler,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// The top level function that runs a button press when the app is closed.
  final DidReceiveBackgroundNotificationResponseCallback? backgroundHandler;

  /// The small white icon on every Harvestly notification.
  static const String smallIcon = 'ic_stat_harvestly';

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> start({
    required void Function(NotificationPayload payload, String? actionId)
    onResponse,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(smallIcon),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final NotificationPayload? payload = NotificationPayload.decode(
          response.payload,
        );
        if (payload != null) onResponse(payload, response.actionId);
      },
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationService.channelId,
        NotificationService.channelName,
        description: 'Reminders for the tasks on your farm.',
        importance: Importance.high,
      ),
    );
  }

  @override
  Future<bool> areEnabled() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> schedule(PlannedReminder reminder) => _plugin.zonedSchedule(
    id: reminder.id,
    title: reminder.title,
    body: reminder.body,
    payload: reminder.payload,
    // A single moment, so it is sent as UTC and the phone's time zone name
    // is never needed.
    scheduledDate: tz.TZDateTime.from(reminder.at, tz.UTC),
    // Harvestly asks for no exact alarm permission, so a reminder may be a
    // few minutes late. That is written up for testers in test_ids.md.
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    notificationDetails: NotificationDetails(android: reminderDetails()),
  );

  /// The look of a task reminder, with its two buttons.
  static AndroidNotificationDetails reminderDetails() =>
      const AndroidNotificationDetails(
        NotificationService.channelId,
        NotificationService.channelName,
        channelDescription: 'Reminders for the tasks on your farm.',
        importance: Importance.high,
        priority: Priority.high,
        icon: smallIcon,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            NotificationService.markDoneActionId,
            NotificationService.markDoneLabel,
          ),
          AndroidNotificationAction(
            NotificationService.snoozeActionId,
            NotificationService.snoozeLabel,
          ),
        ],
      );

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    payload: payload,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channelId,
        NotificationService.channelName,
        channelDescription: 'Reminders for the tasks on your farm.',
        importance: Importance.high,
        priority: Priority.high,
        icon: smallIcon,
      ),
    ),
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<List<int>> pendingIds() async {
    try {
      final List<PendingNotificationRequest> waiting = await _plugin
          .pendingNotificationRequests();
      return <int>[for (final PendingNotificationRequest r in waiting) r.id];
    } catch (error) {
      debugPrint('Harvestly notifications: no pending list ($error)');
      return <int>[];
    }
  }

  @override
  Future<List<LiveNotification>> shownNotifications() async {
    try {
      final List<ActiveNotification> live = await _plugin
          .getActiveNotifications();
      return <LiveNotification>[
        for (final ActiveNotification one in live)
          if (one.id != null)
            LiveNotification(id: one.id!, title: one.title, body: one.body),
      ];
    } catch (error) {
      // Not every Android version answers this. Keeping the shade as it is
      // beats clearing it by mistake.
      debugPrint('Harvestly notifications: no shown list ($error)');
      return <LiveNotification>[];
    }
  }

  @override
  Future<NotificationPayload?> launchPayload() async {
    try {
      final NotificationAppLaunchDetails? details = await _plugin
          .getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return NotificationPayload.decode(details.notificationResponse?.payload);
    } catch (error) {
      debugPrint('Harvestly notifications: could not read the launch ($error)');
      return null;
    }
  }
}
