import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/data/task_models.dart';
import 'package:harvestly/data/task_rules.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Today for every test here: Wednesday 25 November 2026, 9:00.
final DateTime _today = DateTime(2026, 11, 25, 9);

Future<FarmRepository> _farmer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FarmRepository repository = FarmRepository(prefs);
  repository.openAccount(email: 'farmer@harvestly.app', accountId: 'farmer');
  await repository.lastWrite;
  return repository;
}

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  group('the farmer sample', () {
    test('has the groups and counts the brief asks for', () async {
      final FarmRepository repository = await _farmer();

      expect(repository.tasksIn(TaskGroup.overdue), hasLength(1));
      expect(repository.tasksIn(TaskGroup.today), hasLength(3));
      expect(repository.tasksIn(TaskGroup.upcoming), hasLength(2));
      expect(repository.tasksIn(TaskGroup.done), hasLength(4));
    });

    test('Today is in time order', () async {
      final FarmRepository repository = await _farmer();
      expect(
        repository
            .tasksIn(TaskGroup.today)
            .map((FarmTask t) => t.title)
            .toList(),
        <String>['Water tomato beds', 'Collect eggs', 'Clean water pots'],
      );
    });

    test('Done is newest first', () async {
      final FarmRepository repository = await _farmer();
      expect(
        repository
            .tasksIn(TaskGroup.done)
            .map((FarmTask t) => t.title)
            .toList(),
        <String>[
          'Vitamin water for hens',
          'Weed Field 1',
          'Fix coop door',
          'Order seeds',
        ],
      );
    });

    test(
      'Home shows the overdue count and the three tasks due today',
      () async {
        final FarmRepository repository = await _farmer();
        expect(repository.overdueCount, 1);
        expect(
          repository.todayTasks().map((FarmTask t) => t.title).toList(),
          <String>['Water tomato beds', 'Collect eggs', 'Clean water pots'],
        );
      },
    );

    test('a task reads the name of what it is linked to', () async {
      final FarmRepository repository = await _farmer();
      final FarmTask sprayBeans = repository.taskById('task-1')!;
      final FarmTask buyFeed = repository.taskById('task-5')!;

      expect(repository.linkNameFor(sprayBeans), 'Field 3 · Bean rows');
      expect(repository.linkNameFor(buyFeed), 'General');
    });
  });

  group('add, edit and delete', () {
    test('a new task is added at the end and saved', () async {
      final FarmRepository repository = await _farmer();
      final FarmTask added = await repository.addTask(
        title: 'Mend the gate',
        note: 'Bring wire',
        dueAt: DateTime(2026, 11, 26, 8),
        repeat: Repeat.none,
        link: null,
        reminder: ReminderOffset.atDue,
      );

      expect(repository.tasks.last.id, added.id);
      expect(repository.taskById(added.id)?.title, 'Mend the gate');
      expect(repository.tasksIn(TaskGroup.upcoming), hasLength(3));
    });

    test('editing changes the task and clears a snooze', () async {
      final FarmRepository repository = await _farmer();
      await repository.snoozeTask(
        taskId: 'task-4',
        until: DateTime(2026, 11, 25, 18),
      );
      expect(repository.taskById('task-4')?.snoozedUntil, isNotNull);

      await repository.editTask(
        taskId: 'task-4',
        title: 'Clean the pots',
        note: '',
        dueAt: DateTime(2026, 11, 26, 17),
        repeat: Repeat.weekly,
        link: null,
        reminder: ReminderOffset.none,
      );

      final FarmTask task = repository.taskById('task-4')!;
      expect(task.title, 'Clean the pots');
      expect(task.snoozedUntil, isNull);
      expect(task.link, isNull);
      expect(task.reminder, ReminderOffset.none);
    });

    test('deleting takes the task away', () async {
      final FarmRepository repository = await _farmer();
      await repository.deleteTask('task-1');

      expect(repository.taskById('task-1'), isNull);
      expect(repository.tasks, hasLength(9));
    });
  });

  group('completing and undoing', () {
    test('a plain task is marked done and can be undone', () async {
      final FarmRepository repository = await _farmer();
      final TaskCompletion done = await repository.completeTask('task-1');

      expect(done.happened, isTrue);
      expect(done.createdTaskId, isNull);
      expect(repository.taskById('task-1')?.isDone, isTrue);
      expect(repository.tasksIn(TaskGroup.overdue), isEmpty);

      await repository.undoComplete(done);
      expect(repository.taskById('task-1')?.isDone, isFalse);
      expect(repository.tasksIn(TaskGroup.overdue), hasLength(1));
    });

    test('a repeating task starts the next one', () async {
      final FarmRepository repository = await _farmer();
      // Water tomato beds: daily, due today at 7:00.
      final TaskCompletion done = await repository.completeTask('task-2');

      expect(done.createdTaskId, isNotNull);
      final FarmTask next = repository.taskById(done.createdTaskId!)!;
      expect(next.title, 'Water tomato beds');
      expect(next.dueAt, DateTime(2026, 11, 26, 7));
      expect(next.repeat, Repeat.daily);
      expect(next.link?.id, 'field-2');
      expect(next.isOpen, isTrue);
    });

    test('undoing a repeat removes the task it started', () async {
      final FarmRepository repository = await _farmer();
      final int before = repository.tasks.length;
      final TaskCompletion done = await repository.completeTask('task-2');
      expect(repository.tasks, hasLength(before + 1));

      await repository.undoComplete(done);
      expect(repository.tasks, hasLength(before));
      expect(repository.taskById('task-2')?.isOpen, isTrue);
      expect(repository.taskById(done.createdTaskId!), isNull);
    });

    test('completing a task that is already done does nothing', () async {
      final FarmRepository repository = await _farmer();
      final TaskCompletion done = await repository.completeTask('task-7');
      expect(done.happened, isFalse);
    });

    test('a repeating task finished late lands on today or later', () async {
      final FarmRepository repository = await _farmer();
      await repository.editTask(
        taskId: 'task-2',
        title: 'Water tomato beds',
        note: '',
        dueAt: DateTime(2026, 11, 10, 7),
        repeat: Repeat.daily,
        link: null,
        reminder: ReminderOffset.none,
      );

      final TaskCompletion done = await repository.completeTask('task-2');
      expect(
        repository.taskById(done.createdTaskId!)?.dueAt,
        DateTime(2026, 11, 25, 7),
      );
    });
  });

  group('reopening', () {
    test('a plain done task opens again', () async {
      final FarmRepository repository = await _farmer();
      await repository.reopenTask('task-7');

      expect(repository.taskById('task-7')?.isOpen, isTrue);
      expect(repository.tasksIn(TaskGroup.today), hasLength(4));
    });

    test('a done repeating task cannot be reopened', () async {
      final FarmRepository repository = await _farmer();
      final TaskCompletion done = await repository.completeTask('task-3');
      expect(done.createdTaskId, isNotNull);

      await repository.reopenTask('task-3');
      expect(repository.taskById('task-3')?.isDone, isTrue);
    });

    test('an open task is left alone', () async {
      final FarmRepository repository = await _farmer();
      await repository.reopenTask('task-1');
      expect(repository.taskById('task-1')?.isOpen, isTrue);
    });
  });

  group('links to things that go away', () {
    test('deleting a field makes its tasks general', () async {
      final FarmRepository repository = await _farmer();
      expect(repository.taskById('task-1')?.link?.id, 'field-3');

      await repository.deleteField('field-3');

      expect(repository.taskById('task-1')?.link, isNull);
      expect(
        repository.linkNameFor(repository.taskById('task-1')!),
        TaskRules.generalName,
      );
      // Only that field's tasks change.
      expect(repository.taskById('task-2')?.link?.id, 'field-2');
    });

    test('deleting an animal group makes its tasks general', () async {
      final FarmRepository repository = await _farmer();
      expect(repository.taskById('task-3')?.link?.id, 'group-1');

      await repository.deleteGroup('group-1');

      expect(repository.taskById('task-3')?.link, isNull);
      expect(repository.taskById('task-4')?.link?.id, 'group-2');
    });
  });

  group('reminders are announced', () {
    test('every task change tells whoever is listening', () async {
      final FarmRepository repository = await _farmer();
      int calls = 0;
      List<FarmTask> last = <FarmTask>[];
      repository.onRemindersChanged = (String? email, List<FarmTask> tasks) {
        calls++;
        last = tasks;
      };

      await repository.addTask(
        title: 'Mend the gate',
        note: '',
        dueAt: DateTime(2026, 11, 26, 8),
        repeat: Repeat.none,
        link: null,
        reminder: ReminderOffset.atDue,
      );
      expect(calls, 1);
      expect(last, hasLength(11));

      await repository.completeTask('task-1');
      await repository.deleteTask('task-5');
      expect(calls, 3);
    });

    test('logging out asks for everything to be cancelled', () async {
      final FarmRepository repository = await _farmer();
      bool called = false;
      String? seenEmail;
      List<FarmTask> seenTasks = <FarmTask>[];
      repository.onRemindersChanged = (String? email, List<FarmTask> tasks) {
        called = true;
        seenEmail = email;
        seenTasks = tasks;
      };

      repository.closeAccount();

      expect(called, isTrue);
      expect(seenEmail, 'farmer@harvestly.app');
      expect(seenTasks, isEmpty);
    });
  });
}
