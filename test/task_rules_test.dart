import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/task_models.dart';
import 'package:harvestly/data/task_rules.dart';
import 'package:harvestly/shared/logic/app_clock.dart';

/// Today for every test here: Wednesday 25 November 2026, 9:00 in the
/// morning.
final DateTime _today = DateTime(2026, 11, 25, 9);

FarmTask _task({
  required DateTime dueAt,
  Repeat repeat = Repeat.none,
  ReminderOffset reminder = ReminderOffset.none,
  DateTime? snoozedUntil,
  DateTime? doneAt,
}) => FarmTask(
  id: 'task-1',
  title: 'Water tomato beds',
  dueAt: dueAt,
  repeat: repeat,
  reminder: reminder,
  snoozedUntil: snoozedUntil,
  doneAt: doneAt,
);

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  group('which group a task falls in', () {
    test('a task due before today is overdue', () {
      expect(
        TaskRules.groupOf(_task(dueAt: DateTime(2026, 11, 23, 7))),
        TaskGroup.overdue,
      );
    });

    test('a task due today is in Today, whatever the time', () {
      // 7:00 is already past, and it still counts as today.
      expect(
        TaskRules.groupOf(_task(dueAt: DateTime(2026, 11, 25, 7))),
        TaskGroup.today,
      );
      expect(
        TaskRules.groupOf(_task(dueAt: DateTime(2026, 11, 25, 17))),
        TaskGroup.today,
      );
    });

    test('a task due after today is upcoming', () {
      expect(
        TaskRules.groupOf(_task(dueAt: DateTime(2026, 11, 27, 10))),
        TaskGroup.upcoming,
      );
    });

    test('a done task is in Done, however late it was', () {
      expect(
        TaskRules.groupOf(
          _task(
            dueAt: DateTime(2026, 11, 20, 9),
            doneAt: DateTime(2026, 11, 24, 9),
          ),
        ),
        TaskGroup.done,
      );
    });

    test('Done only holds the last 30 days', () {
      expect(
        TaskRules.showsUnderDone(
          _task(
            dueAt: DateTime(2026, 10, 26, 9),
            doneAt: DateTime(2026, 10, 26, 9),
          ),
        ),
        isTrue,
      );
      expect(
        TaskRules.showsUnderDone(
          _task(
            dueAt: DateTime(2026, 10, 25, 9),
            doneAt: DateTime(2026, 10, 25, 9),
          ),
        ),
        isFalse,
      );
    });
  });

  group('the line under a task', () {
    test('overdue says how late it is, with the day', () {
      expect(
        TaskRules.lineFor(_task(dueAt: DateTime(2026, 11, 23, 7)), 'Field 3'),
        'Field 3 · Mon 23 Nov · Late by 2 days',
      );
    });

    test('one day late reads "Late by 1 day"', () {
      expect(
        TaskRules.lateText(_task(dueAt: DateTime(2026, 11, 24, 9))),
        'Late by 1 day',
      );
    });

    test('today shows the time', () {
      expect(
        TaskRules.lineFor(_task(dueAt: DateTime(2026, 11, 25, 7)), 'Field 2'),
        'Field 2 · 7:00 AM',
      );
    });

    test('upcoming shows the day', () {
      expect(
        TaskRules.lineFor(_task(dueAt: DateTime(2026, 11, 27, 10)), 'General'),
        'General · Fri 27 Nov',
      );
    });

    test('done shows when it was done', () {
      expect(
        TaskRules.lineFor(
          _task(
            dueAt: DateTime(2026, 11, 24, 9),
            doneAt: DateTime(2026, 11, 25, 8),
          ),
          'Flock A',
        ),
        'Done Wed 25 Nov',
      );
    });
  });

  group('the chip on Task detail', () {
    test('today, upcoming, late and done each read their own way', () {
      expect(
        TaskRules.dueChipText(_task(dueAt: DateTime(2026, 11, 25, 17))),
        'Today · 5:00 PM',
      );
      expect(
        TaskRules.dueChipText(_task(dueAt: DateTime(2026, 11, 27, 10))),
        'Fri 27 Nov · 10:00 AM',
      );
      expect(
        TaskRules.dueChipText(_task(dueAt: DateTime(2026, 11, 23, 7))),
        'Late by 2 days',
      );
      expect(
        TaskRules.dueChipText(
          _task(
            dueAt: DateTime(2026, 11, 24, 9),
            doneAt: DateTime(2026, 11, 25, 8),
          ),
        ),
        'Done Wed 25 Nov',
      );
    });
  });

  group('the repeat line', () {
    test('each repeat says when it comes back', () {
      expect(
        TaskRules.repeatText(_task(dueAt: DateTime(2026, 11, 25, 9))),
        'Does not repeat',
      );
      expect(
        TaskRules.repeatText(
          _task(dueAt: DateTime(2026, 11, 25, 9), repeat: Repeat.daily),
        ),
        'Every day',
      );
      expect(
        TaskRules.repeatText(
          _task(dueAt: DateTime(2026, 11, 25, 9), repeat: Repeat.weekly),
        ),
        'Every week, on Wed',
      );
      expect(
        TaskRules.repeatText(
          _task(dueAt: DateTime(2026, 11, 25, 9), repeat: Repeat.monthly),
        ),
        'Every month, on the 25th',
      );
    });
  });

  group('the next date of a repeating task', () {
    test('daily moves on one day', () {
      expect(
        TaskRules.nextDueAt(DateTime(2026, 11, 25, 7), Repeat.daily),
        DateTime(2026, 11, 26, 7),
      );
    });

    test('weekly moves on seven days', () {
      expect(
        TaskRules.nextDueAt(DateTime(2026, 11, 25, 17), Repeat.weekly),
        DateTime(2026, 12, 2, 17),
      );
    });

    test('monthly keeps the day of the month', () {
      expect(
        TaskRules.nextDueAt(DateTime(2026, 11, 25, 9), Repeat.monthly),
        DateTime(2026, 12, 25, 9),
      );
    });

    test('monthly from 31 January lands on the last day of February', () {
      expect(
        TaskRules.stepOnce(DateTime(2027, 1, 31, 9), Repeat.monthly),
        DateTime(2027, 2, 28, 9),
      );
      // 2028 is a leap year, so February has one more day.
      expect(
        TaskRules.stepOnce(DateTime(2028, 1, 31, 9), Repeat.monthly),
        DateTime(2028, 2, 29, 9),
      );
    });

    test('monthly crosses into the next year', () {
      expect(
        TaskRules.stepOnce(DateTime(2026, 12, 25, 9), Repeat.monthly),
        DateTime(2027, 1, 25, 9),
      );
    });

    test('a task finished weeks late skips forward to today or later', () {
      // Due every day since 10 November. The next one must be today, not
      // 11 November.
      expect(
        TaskRules.nextDueAt(DateTime(2026, 11, 10, 7), Repeat.daily),
        DateTime(2026, 11, 25, 7),
      );
      // Weekly from 28 October: 4, 11, 18, 25 November.
      expect(
        TaskRules.nextDueAt(DateTime(2026, 10, 28, 7), Repeat.weekly),
        DateTime(2026, 11, 25, 7),
      );
      // Monthly from 25 August: September, October, November.
      expect(
        TaskRules.nextDueAt(DateTime(2026, 8, 25, 9), Repeat.monthly),
        DateTime(2026, 11, 25, 9),
      );
    });

    test('a task with no repeat keeps its date', () {
      expect(
        TaskRules.nextDueAt(DateTime(2026, 11, 20, 9), Repeat.none),
        DateTime(2026, 11, 20, 9),
      );
    });
  });

  group('when the reminder shows', () {
    test('no reminder has no time', () {
      expect(
        TaskRules.reminderTime(_task(dueAt: DateTime(2026, 11, 25, 17))),
        isNull,
      );
    });

    test('at due time is the due time', () {
      expect(
        TaskRules.reminderTime(
          _task(
            dueAt: DateTime(2026, 11, 25, 17),
            reminder: ReminderOffset.atDue,
          ),
        ),
        DateTime(2026, 11, 25, 17),
      );
    });

    test('one hour before and one day before count back', () {
      expect(
        TaskRules.reminderTime(
          _task(
            dueAt: DateTime(2026, 11, 25, 17),
            reminder: ReminderOffset.hourBefore,
          ),
        ),
        DateTime(2026, 11, 25, 16),
      );
      expect(
        TaskRules.reminderTime(
          _task(
            dueAt: DateTime(2026, 11, 27, 10),
            reminder: ReminderOffset.dayBefore,
          ),
        ),
        DateTime(2026, 11, 26, 10),
      );
    });

    test('a snooze replaces the reminder time', () {
      final FarmTask task = _task(
        dueAt: DateTime(2026, 11, 25, 17),
        reminder: ReminderOffset.hourBefore,
        snoozedUntil: DateTime(2026, 11, 25, 18),
      );
      expect(TaskRules.reminderTime(task), DateTime(2026, 11, 25, 18));
      expect(TaskRules.reminderText(task), 'Snoozed until 6:00 PM');
    });

    test('a done task has no reminder left', () {
      expect(
        TaskRules.reminderTime(
          _task(
            dueAt: DateTime(2026, 11, 25, 17),
            reminder: ReminderOffset.atDue,
            doneAt: DateTime(2026, 11, 25, 16),
          ),
        ),
        isNull,
      );
    });

    test('the reminder line says the time and the offset', () {
      expect(
        TaskRules.reminderText(
          _task(
            dueAt: DateTime(2026, 11, 25, 17),
            reminder: ReminderOffset.hourBefore,
          ),
        ),
        '4:00 PM, 1 hour before',
      );
      expect(
        TaskRules.reminderText(_task(dueAt: DateTime(2026, 11, 25, 17))),
        'None',
      );
    });
  });

  group('the order inside a group', () {
    test('open tasks go by due date and time', () {
      final List<FarmTask> sorted = TaskRules.sorted(<FarmTask>[
        _task(dueAt: DateTime(2026, 11, 25, 17)),
        _task(dueAt: DateTime(2026, 11, 25, 7)),
        _task(dueAt: DateTime(2026, 11, 25, 8)),
      ], TaskGroup.today);
      expect(sorted.map((FarmTask t) => t.dueAt.hour).toList(), <int>[
        7,
        8,
        17,
      ]);
    });

    test('done tasks go newest first', () {
      final List<FarmTask> sorted = TaskRules.sorted(<FarmTask>[
        _task(
          dueAt: DateTime(2026, 11, 20, 9),
          doneAt: DateTime(2026, 11, 20, 9),
        ),
        _task(
          dueAt: DateTime(2026, 11, 25, 7),
          doneAt: DateTime(2026, 11, 25, 7),
        ),
      ], TaskGroup.done);
      expect(sorted.first.doneAt, DateTime(2026, 11, 25, 7));
    });
  });
}
