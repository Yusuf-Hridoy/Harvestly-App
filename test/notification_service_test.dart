import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/data/farm_storage.dart';
import 'package:harvestly/data/task_models.dart';
import 'package:harvestly/notifications/notification_actions.dart';
import 'package:harvestly/notifications/notification_service.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_notifications.dart';

/// Today for every test here: Wednesday 25 November 2026, 9:00.
final DateTime _today = DateTime(2026, 11, 25, 9);

const String _email = 'farmer@harvestly.app';

FarmTask _task({
  String id = 'task-1',
  String title = 'Clean water pots',
  required DateTime dueAt,
  Repeat repeat = Repeat.none,
  ReminderOffset reminder = ReminderOffset.atDue,
  DateTime? snoozedUntil,
  DateTime? doneAt,
}) => FarmTask(
  id: id,
  title: title,
  dueAt: dueAt,
  repeat: repeat,
  reminder: reminder,
  snoozedUntil: snoozedUntil,
  doneAt: doneAt,
);

/// A service with a fake plugin, a fake Android side and empty storage.
Future<
  ({
    NotificationService service,
    FakeNotificationPlugin plugin,
    FakeSettingsChannel settings,
    SharedPreferences prefs,
  })
>
_build({
  bool enabled = true,
  bool grant = true,
  int version = 33,
  Map<String, Object> saved = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(saved);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FakeNotificationPlugin plugin = FakeNotificationPlugin()
    ..enabled = enabled
    ..grantOnRequest = grant;
  final FakeSettingsChannel settings = FakeSettingsChannel(version: version);
  final NotificationService service = NotificationService(
    plugin: plugin,
    prefs: prefs,
    settings: settings,
  );
  await service.start();
  return (service: service, plugin: plugin, settings: settings, prefs: prefs);
}

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  group('the permission flow', () {
    test('notifications already on means allowed', () async {
      final parts = await _build(enabled: true);
      expect(await parts.service.permission(), NotificationPermission.allowed);
    });

    test(
      'Android 12 and on, with nothing blocked, counts as allowed',
      () async {
        final parts = await _build(enabled: true, version: 32);
        expect(
          await parts.service.permission(),
          NotificationPermission.allowed,
        );
      },
    );

    test('Android 12 with notifications turned off reads as off', () async {
      // Below Android 13 there is no pop-up, so off can only be the user.
      final parts = await _build(enabled: false, version: 32);
      expect(await parts.service.permission(), NotificationPermission.off);
    });

    test('Android 13, never asked, is not set up yet', () async {
      final parts = await _build(enabled: false, version: 33);
      expect(await parts.service.permission(), NotificationPermission.notAsked);
    });

    test('Android 13, asked before and refused, reads as off', () async {
      final parts = await _build(enabled: false, version: 33, grant: false);

      expect(await parts.service.requestPermission(), isFalse);
      expect(parts.service.askedBefore, isTrue);
      expect(await parts.service.permission(), NotificationPermission.off);
    });

    test('allowing the pop-up turns notifications on', () async {
      final parts = await _build(enabled: false, version: 33);

      expect(await parts.service.requestPermission(), isTrue);
      expect(parts.plugin.requests, 1);
      expect(await parts.service.permission(), NotificationPermission.allowed);
    });

    test('asking is remembered across a restart', () async {
      final parts = await _build(enabled: false, version: 33, grant: false);
      await parts.service.requestPermission();

      final NotificationService again = NotificationService(
        plugin: parts.plugin,
        prefs: parts.prefs,
        settings: parts.settings,
      );
      expect(again.askedBefore, isTrue);
      expect(await again.permission(), NotificationPermission.off);
    });
  });

  group('booking reminders', () {
    test('only times still to come are booked', () async {
      final parts = await _build();
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[
          _task(id: 'past', dueAt: DateTime(2026, 11, 25, 8)),
          _task(id: 'soon', dueAt: DateTime(2026, 11, 25, 17)),
          _task(
            id: 'none',
            dueAt: DateTime(2026, 11, 26, 9),
            reminder: ReminderOffset.none,
          ),
          _task(
            id: 'done',
            dueAt: DateTime(2026, 11, 26, 9),
            doneAt: DateTime(2026, 11, 25, 8),
          ),
        ],
      );

      expect(parts.plugin.scheduled, hasLength(1));
      expect(parts.plugin.forTask('soon'), isNotNull);
      expect(parts.plugin.forTask('past'), isNull);
    });

    test('a reminder carries the title, the line and the payload', () async {
      final parts = await _build();
      parts.service.setLinkNames(<String, String>{'task-1': 'Duck pond'});

      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 17))],
      );

      final PlannedReminder booked = parts.plugin.forTask('task-1')!;
      expect(booked.title, 'Clean water pots');
      expect(booked.body, 'Duck pond · due at 5:00 PM');
      expect(booked.at, DateTime(2026, 11, 25, 17));

      final Map<String, dynamic> payload =
          jsonDecode(booked.payload) as Map<String, dynamic>;
      expect(payload['email'], _email);
      expect(payload['taskId'], 'task-1');
    });

    test('a task with no link says General', () async {
      final parts = await _build();
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 17))],
      );
      expect(parts.plugin.forTask('task-1')!.body, 'General · due at 5:00 PM');
    });

    test('a snooze is booked instead of the reminder time', () async {
      final parts = await _build();
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[
          _task(
            dueAt: DateTime(2026, 11, 25, 8),
            snoozedUntil: DateTime(2026, 11, 25, 18),
          ),
        ],
      );

      expect(parts.plugin.forTask('task-1')!.at, DateTime(2026, 11, 25, 18));
    });

    test('booking again replaces what was there', () async {
      final parts = await _build();
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 17))],
      );
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 19))],
      );

      expect(parts.plugin.scheduled, hasLength(1));
      expect(parts.plugin.forTask('task-1')!.at, DateTime(2026, 11, 25, 19));
    });

    test('the same task always gets the same notification id', () {
      expect(
        NotificationService.notificationIdFor('task-4'),
        NotificationService.notificationIdFor('task-4'),
      );
      expect(
        NotificationService.notificationIdFor('task-4'),
        isNot(NotificationService.notificationIdFor('task-5')),
      );
      // Never 0, and never the test notification's id.
      expect(
        NotificationService.notificationIdFor('task-4'),
        greaterThan(NotificationService.testNotificationId),
      );
    });

    test('logging out cancels everything', () async {
      final parts = await _build();
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 17))],
      );
      expect(parts.plugin.scheduled, hasLength(1));

      await parts.service.rescheduleAll(email: null, tasks: <FarmTask>[]);

      expect(parts.plugin.scheduled, isEmpty);
      // Only the logout clears everything. Booking reminders again takes
      // out the waiting ones one by one and leaves the shade alone.
      expect(parts.plugin.cancelAllCount, 1);
    });

    test('nothing is booked while notifications are off', () async {
      final parts = await _build(enabled: false);
      await parts.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[_task(dueAt: DateTime(2026, 11, 25, 17))],
      );
      expect(parts.plugin.scheduled, isEmpty);
    });
  });

  group('reminders already in the shade', () {
    /// Books one reminder, then pretends it has fired.
    Future<
      ({
        NotificationService service,
        FakeNotificationPlugin plugin,
        FarmTask task,
      })
    >
    shownReminder() async {
      final parts = await _build();
      final FarmTask task = _task(dueAt: DateTime(2026, 11, 25, 10));
      await parts.service.rescheduleAll(email: _email, tasks: <FarmTask>[task]);
      parts.plugin.fire(task.id);
      expect(parts.plugin.isInShade(task.id), isTrue);
      return (service: parts.service, plugin: parts.plugin, task: task);
    }

    test('one for a task still open survives an app start', () async {
      final shown = await shownReminder();

      // The clock moves past the reminder time, as it would have by the
      // time the user opens the app.
      AppClock.useFixed(DateTime(2026, 11, 25, 10, 30));
      await shown.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[shown.task],
      );

      expect(shown.plugin.isInShade(shown.task.id), isTrue);
      expect(shown.plugin.cancelAllCount, 0);
    });

    test('one whose task was finished elsewhere is taken away', () async {
      final shown = await shownReminder();
      AppClock.useFixed(DateTime(2026, 11, 25, 10, 30));

      final FarmTask done = shown.task.copyWith(
        doneAt: DateTime(2026, 11, 25, 10, 20),
      );
      await shown.service.rescheduleAll(email: _email, tasks: <FarmTask>[done]);

      expect(shown.plugin.isInShade(shown.task.id), isFalse);
    });

    test('one whose task was deleted is taken away', () async {
      final shown = await shownReminder();
      AppClock.useFixed(DateTime(2026, 11, 25, 10, 30));

      await shown.service.rescheduleAll(email: _email, tasks: <FarmTask>[]);

      expect(shown.plugin.isInShade(shown.task.id), isFalse);
    });

    test('one whose task was moved to a later time is taken away', () async {
      final shown = await shownReminder();
      AppClock.useFixed(DateTime(2026, 11, 25, 10, 30));

      final FarmTask later = shown.task.copyWith(
        dueAt: DateTime(2026, 11, 25, 18),
      );
      await shown.service.rescheduleAll(
        email: _email,
        tasks: <FarmTask>[later],
      );

      expect(shown.plugin.isInShade(shown.task.id), isFalse);
      // And the new time is booked instead.
      expect(
        shown.plugin.forTask(shown.task.id)?.at,
        DateTime(2026, 11, 25, 18),
      );
    });

    test('one belonging to another account is taken away', () async {
      final shown = await shownReminder();
      AppClock.useFixed(DateTime(2026, 11, 25, 10, 30));

      // Another account's own tasks, which do not include this one.
      await shown.service.rescheduleAll(
        email: 'poultry@harvestly.app',
        tasks: <FarmTask>[_task(id: 'other', dueAt: DateTime(2026, 11, 26, 9))],
      );

      expect(shown.plugin.isInShade(shown.task.id), isFalse);
    });

    test('logging out takes every shown one away', () async {
      final shown = await shownReminder();

      await shown.service.rescheduleAll(email: null, tasks: <FarmTask>[]);

      expect(shown.plugin.shade, isEmpty);
      expect(shown.plugin.cancelAllCount, 1);
    });

    test('a reminder still waiting is replaced, not kept twice', () async {
      final parts = await _build();
      final FarmTask task = _task(dueAt: DateTime(2026, 11, 25, 17));
      await parts.service.rescheduleAll(email: _email, tasks: <FarmTask>[task]);
      await parts.service.rescheduleAll(email: _email, tasks: <FarmTask>[task]);

      expect(parts.plugin.scheduled, hasLength(1));
      expect(parts.plugin.cancelAllCount, 0);
    });

    test('the test notification is left alone', () async {
      final parts = await _build();
      await parts.service.sendTest();
      expect(parts.plugin.shade, hasLength(1));

      await parts.service.rescheduleAll(email: _email, tasks: <FarmTask>[]);

      expect(parts.plugin.shade, hasLength(1));
    });
  });

  group('the test notification', () {
    test('it waits, then shows with no buttons', () async {
      final parts = await _build();
      await parts.service.sendTest();
      expect(parts.plugin.shownTitles, <String>['Test reminder']);
    });
  });

  group('the buttons on a reminder', () {
    /// An account with its sample data already saved.
    Future<SharedPreferences> savedFarmer() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FarmRepository repository = FarmRepository(prefs);
      repository.openAccount(email: _email, accountId: 'farmer');
      await repository.lastWrite;
      return prefs;
    }

    List<dynamic> savedTasks(SharedPreferences prefs) =>
        (jsonDecode(prefs.getString(FarmStorage.keyFor(_email))!)
                as Map<String, dynamic>)['tasks']
            as List<dynamic>;

    test('Mark done writes the task as done', () async {
      final SharedPreferences prefs = await savedFarmer();
      final FakeNotificationPlugin plugin = FakeNotificationPlugin();

      final bool changed = await NotificationActions.run(
        actionId: NotificationService.markDoneActionId,
        payload: const NotificationPayload(email: _email, taskId: 'task-1'),
        prefs: prefs,
        plugin: plugin,
      );

      expect(changed, isTrue);
      final Map<String, dynamic> task = savedTasks(prefs).firstWhere(
        (dynamic t) => (t as Map<String, dynamic>)['id'] == 'task-1',
      ) as Map<String, dynamic>;
      expect(task['doneAt'], isNotNull);
      // The notification is taken away.
      expect(
        plugin.cancelled,
        contains(NotificationService.notificationIdFor('task-1')),
      );
    });

    test('Mark done on a repeating task writes the next one too', () async {
      final SharedPreferences prefs = await savedFarmer();

      await NotificationActions.run(
        // task-2 is Water tomato beds, daily, due today at 7:00.
        actionId: NotificationService.markDoneActionId,
        payload: const NotificationPayload(email: _email, taskId: 'task-2'),
        prefs: prefs,
        plugin: FakeNotificationPlugin(),
      );

      final List<dynamic> tasks = savedTasks(prefs);
      expect(tasks, hasLength(11));
      final Map<String, dynamic> added = tasks.last as Map<String, dynamic>;
      expect(added['title'], 'Water tomato beds');
      expect(added['dueAt'], DateTime(2026, 11, 26, 7).toIso8601String());
      expect(added['doneAt'], isNull);
    });

    test('Snooze writes the new time and books the reminder again', () async {
      final SharedPreferences prefs = await savedFarmer();
      final FakeNotificationPlugin plugin = FakeNotificationPlugin();

      await NotificationActions.run(
        actionId: NotificationService.snoozeActionId,
        payload: const NotificationPayload(email: _email, taskId: 'task-4'),
        prefs: prefs,
        plugin: plugin,
      );

      final Map<String, dynamic> task = savedTasks(prefs).firstWhere(
        (dynamic t) => (t as Map<String, dynamic>)['id'] == 'task-4',
      ) as Map<String, dynamic>;
      expect(task['snoozedUntil'], isNotNull);
      expect(plugin.forTask('task-4'), isNotNull);
    });

    test('a button Harvestly does not know changes nothing', () async {
      final SharedPreferences prefs = await savedFarmer();
      expect(
        await NotificationActions.run(
          actionId: 'something_else',
          payload: const NotificationPayload(email: _email, taskId: 'task-1'),
          prefs: prefs,
          plugin: FakeNotificationPlugin(),
        ),
        isFalse,
      );
    });

    test('a task that is already gone changes nothing', () async {
      final SharedPreferences prefs = await savedFarmer();
      expect(
        await NotificationActions.run(
          actionId: NotificationService.markDoneActionId,
          payload: const NotificationPayload(email: _email, taskId: 'gone'),
          prefs: prefs,
          plugin: FakeNotificationPlugin(),
        ),
        isFalse,
      );
    });
  });

  group('what a notification carries', () {
    test('a payload survives being written and read', () {
      const NotificationPayload payload = NotificationPayload(
        email: _email,
        taskId: 'task-4',
      );
      final NotificationPayload? back = NotificationPayload.decode(
        payload.encode(),
      );

      expect(back?.email, _email);
      expect(back?.taskId, 'task-4');
      expect(back?.route, '/tasks/task-4');
    });

    test('the test notification points at Home', () {
      const NotificationPayload home = NotificationPayload.home();
      expect(home.isHome, isTrue);
      expect(home.route, '/home');

      final NotificationPayload? back = NotificationPayload.decode(
        home.encode(),
      );
      expect(back?.isHome, isTrue);
      expect(back?.route, '/home');
    });

    test('rubbish gives nothing back', () {
      expect(NotificationPayload.decode(null), isNull);
      expect(NotificationPayload.decode(''), isNull);
      expect(NotificationPayload.decode('not json'), isNull);
      expect(NotificationPayload.decode('{"email":"a"}'), isNull);
    });
  });
}
