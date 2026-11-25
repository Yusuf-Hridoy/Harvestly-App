import 'package:harvestly/notifications/android_settings_channel.dart';
import 'package:harvestly/notifications/notification_service.dart';

/// A notification plugin that records what it was asked to do.
///
/// Nothing reaches Android, so the whole reminder and permission flow can be
/// checked in a widget test.
class FakeNotificationPlugin implements NotificationPlugin {
  /// Whether Android would say notifications are on.
  bool enabled = false;

  /// What the permission pop-up would answer.
  bool grantOnRequest = true;

  /// How many times the pop-up was shown.
  int requests = 0;

  /// Whether [start] has run.
  bool started = false;

  /// Every reminder booked since the last [cancelAll], newest last.
  final List<PlannedReminder> scheduled = <PlannedReminder>[];

  /// Notification ids cancelled one by one.
  final List<int> cancelled = <int>[];

  /// How many times everything was cancelled.
  int cancelAllCount = 0;

  /// Notifications shown straight away, such as the test one.
  final List<String> shownTitles = <String>[];

  /// What is in the notification shade right now.
  final List<LiveNotification> shade = <LiveNotification>[];

  /// Pretends a booked reminder has fired: it leaves the waiting list and
  /// turns up in the shade, the way Android does it.
  void fire(String taskId) {
    final PlannedReminder? booked = forTask(taskId);
    if (booked == null) {
      throw StateError('no reminder is booked for $taskId');
    }
    scheduled.remove(booked);
    shade.add(
      LiveNotification(id: booked.id, title: booked.title, body: booked.body),
    );
  }

  /// Whether a reminder for this task is in the shade.
  bool isInShade(String taskId) {
    final int id = NotificationService.notificationIdFor(taskId);
    return shade.any((LiveNotification one) => one.id == id);
  }

  /// What a tap on the notification that started the app would give.
  NotificationPayload? launch;

  /// The callback the service gave, so a test can pretend a tap happened.
  void Function(NotificationPayload payload, String? actionId)? respond;

  /// The reminder booked for a task id, or null when there is none.
  PlannedReminder? forTask(String taskId) {
    final int id = NotificationService.notificationIdFor(taskId);
    for (final PlannedReminder reminder in scheduled.reversed) {
      if (reminder.id == id) return reminder;
    }
    return null;
  }

  @override
  Future<void> start({
    required void Function(NotificationPayload payload, String? actionId)
    onResponse,
  }) async {
    started = true;
    respond = onResponse;
  }

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    requests++;
    enabled = grantOnRequest;
    return grantOnRequest;
  }

  @override
  Future<void> schedule(PlannedReminder reminder) async {
    scheduled
      ..removeWhere((PlannedReminder old) => old.id == reminder.id)
      ..add(reminder);
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    shownTitles.add(title);
    shade
      ..removeWhere((LiveNotification one) => one.id == id)
      ..add(LiveNotification(id: id, title: title, body: body));
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.removeWhere((PlannedReminder r) => r.id == id);
    shade.removeWhere((LiveNotification one) => one.id == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduled.clear();
    shade.clear();
  }

  @override
  Future<List<int>> pendingIds() async => <int>[
    for (final PlannedReminder r in scheduled) r.id,
  ];

  @override
  Future<List<LiveNotification>> shownNotifications() async =>
      List<LiveNotification>.of(shade);

  @override
  Future<NotificationPayload?> launchPayload() async => launch;
}

/// An Android side that answers without a real phone.
class FakeSettingsChannel extends AndroidSettingsChannel {
  FakeSettingsChannel({this.version = AndroidSettingsChannel.android13});

  /// The Android API level to pretend to be.
  final int version;

  /// How many times the settings page was asked for.
  int opened = 0;

  @override
  Future<int> sdkInt() async => version;

  @override
  Future<bool> openNotificationSettings() async {
    opened++;
    return true;
  }
}
