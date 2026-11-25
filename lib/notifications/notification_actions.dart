import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/animal_models.dart';
import '../data/demo_accounts.dart';
import '../data/farm_models.dart';
import '../data/farm_storage.dart';
import '../data/task_models.dart';
import '../data/task_rules.dart';
import '../shared/logic/app_clock.dart';
import 'notification_service.dart';

/// Runs the Mark done and Snooze buttons on a reminder.
///
/// A button must work with the app closed, so this never touches the
/// repository or anything on screen. It reads the account's saved data
/// straight from shared_preferences, changes it and saves it again. When the
/// app next comes to the front it reads the store again and the screens show
/// the change.
class NotificationActions {
  const NotificationActions._();

  /// Does what the pressed button says, on the saved data.
  ///
  /// Returns true when something changed. Unknown buttons and tasks that are
  /// already gone are ignored.
  static Future<bool> run({
    required String? actionId,
    required NotificationPayload payload,
    required SharedPreferences prefs,
    NotificationPlugin? plugin,
  }) async {
    if (actionId != NotificationService.markDoneActionId &&
        actionId != NotificationService.snoozeActionId) {
      return false;
    }
    // The test notification belongs to no task and has no buttons.
    if (payload.isHome) return false;

    // Another isolate may have written since this one started.
    await prefs.reload();

    final FarmStorage storage = FarmStorage(prefs);
    final String accountId =
        DemoAccounts.findByEmail(payload.email)?.id ?? 'new';
    final FarmLoad load = storage.load(
      email: payload.email,
      accountId: accountId,
    );

    final List<FarmTask> tasks = List<FarmTask>.of(load.snapshot.tasks);
    final int at = tasks.indexWhere((FarmTask t) => t.id == payload.taskId);
    if (at < 0) return false;
    final FarmTask task = tasks[at];

    DateTime? scheduleAgainAt;
    if (actionId == NotificationService.markDoneActionId) {
      if (task.isDone) return false;
      tasks[at] = task.copyWith(doneAt: AppClock.now(), clearSnooze: true);
      if (task.repeats) {
        tasks.add(_nextAfter(task, tasks));
      }
    } else {
      final DateTime until = AppClock.now().add(NotificationService.snoozeFor);
      tasks[at] = task.copyWith(snoozedUntil: until);
      scheduleAgainAt = until;
    }

    await storage.save(
      email: payload.email,
      snapshot: FarmSnapshot(
        fields: load.snapshot.fields,
        animals: load.snapshot.animals,
        tasks: tasks,
      ),
    );

    await _afterSave(
      plugin: plugin,
      payload: payload,
      task: tasks[at],
      linkName: linkNameIn(load.snapshot, tasks[at]),
      scheduleAgainAt: scheduleAgainAt,
    );
    return true;
  }

  /// The task a finished repeating task starts next.
  static FarmTask _nextAfter(FarmTask task, List<FarmTask> existing) =>
      FarmTask(
        id: _newTaskId(existing),
        title: task.title,
        note: task.note,
        dueAt: TaskRules.nextDueAt(task.dueAt, task.repeat),
        repeat: task.repeat,
        link: task.link,
        reminder: task.reminder,
      );

  /// A task id nothing else uses.
  ///
  /// The repository makes ids the same way. This isolate has no repository,
  /// so it checks the list it just loaded instead.
  static String _newTaskId(List<FarmTask> existing) {
    final Set<String> taken = <String>{
      for (final FarmTask task in existing) task.id,
    };
    int extra = 1;
    String id = 'task-${DateTime.now().millisecondsSinceEpoch}-$extra';
    while (taken.contains(id)) {
      extra++;
      id = 'task-${DateTime.now().millisecondsSinceEpoch}-$extra';
    }
    return id;
  }

  /// The field or group name for a task, or "General".
  static String linkNameIn(FarmSnapshot snapshot, FarmTask task) {
    final TaskLink? link = task.link;
    if (link == null) return TaskRules.generalName;
    switch (link.kind) {
      case TaskLinkKind.field:
        for (final Field field in snapshot.fields) {
          if (field.id == link.id) return field.name;
        }
      case TaskLinkKind.group:
        for (final AnimalGroup group in snapshot.animals) {
          if (group.id == link.id) return group.name;
        }
    }
    return TaskRules.generalName;
  }

  /// Takes the notification away, and books the snoozed one again.
  static Future<void> _afterSave({
    required NotificationPlugin? plugin,
    required NotificationPayload payload,
    required FarmTask task,
    required String linkName,
    required DateTime? scheduleAgainAt,
  }) async {
    if (plugin == null) return;
    final int id = NotificationService.notificationIdFor(task.id);
    await plugin.cancel(id);
    if (scheduleAgainAt == null) return;
    await plugin.schedule(
      PlannedReminder(
        id: id,
        title: task.title,
        body: NotificationService.bodyFor(task, linkName),
        at: scheduleAgainAt,
        payload: payload.encode(),
      ),
    );
  }
}

/// Runs a notification button while Harvestly is closed.
///
/// The Dart compiler would otherwise drop this, because nothing in the app
/// calls it: Android does, on its own isolate.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  // A background isolate starts with no plugins registered.
  DartPluginRegistrant.ensureInitialized();

  final NotificationPayload? payload = NotificationPayload.decode(
    response.payload,
  );
  if (payload == null) return;

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final LocalNotificationPlugin plugin = LocalNotificationPlugin();
    await plugin.start(onResponse: (NotificationPayload _, String? _) {});
    await NotificationActions.run(
      actionId: response.actionId,
      payload: payload,
      prefs: prefs,
      plugin: plugin,
    );
  } catch (error) {
    debugPrint('Harvestly notifications: button failed ($error)');
  }
}
