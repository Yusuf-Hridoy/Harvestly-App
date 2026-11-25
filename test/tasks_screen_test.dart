import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/tasks/tasks_screen.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Today for every test here: Wednesday 25 November 2026, 9:00.
final DateTime _today = DateTime(2026, 11, 25, 9);

/// Opens the Tasks tab for an account.
Future<TestAppParts> openTasks(
  WidgetTester tester, {
  DemoAccount? account,
}) async {
  final TestAppParts parts = await pumpHarvestlyApp(
    tester,
    startAccount: account ?? DemoAccounts.farmer,
  );
  await tester.tap(byTestId(TestIds.tabTasksButton));
  await tester.pumpAndSettle();
  return parts;
}

void main() {
  setUp(() {
    AppClock.useFixed(_today);
    // The fold state lives on the class, so each test starts folded.
    TasksScreen.doneOpen = false;
  });
  tearDown(AppClock.useRealClock);

  group('the list', () {
    testWidgets('the four groups show with their counts', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      expect(byTestId(TestIds.tasksScreen), findsOneWidget);
      expect(textOfTestId(tester, TestIds.tasksOverdueHeader), 'Overdue · 1');
      expect(textOfTestId(tester, TestIds.tasksTodayHeader), 'Today · 3');
      expect(textOfTestId(tester, TestIds.tasksUpcomingHeader), 'Upcoming · 2');
      expect(textOfTestId(tester, TestIds.tasksDoneToggle), 'Done · 4');
    });

    testWidgets('Today is in time order with the right lines', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      expect(
        textOfTestId(tester, TestIds.tasksItemTitle('today', 1)),
        'Water tomato beds',
      );
      expect(
        textOfTestId(tester, TestIds.tasksItemLine('today', 1)),
        'Field 2 · South bed · 7:00 AM',
      );
      expect(
        textOfTestId(tester, TestIds.tasksItemTitle('today', 3)),
        'Clean water pots',
      );
    });

    testWidgets('an overdue task says how late it is', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      expect(
        textOfTestId(tester, TestIds.tasksItemTitle('overdue', 1)),
        'Spray beans',
      );
      expect(
        textOfTestId(tester, TestIds.tasksItemLine('overdue', 1)),
        'Field 3 · Bean rows · Mon 23 Nov · Late by 2 days',
      );
    });

    testWidgets('an upcoming task shows its day', (WidgetTester tester) async {
      await openTasks(tester);

      expect(
        textOfTestId(tester, TestIds.tasksItemLine('upcoming', 1)),
        'General · Fri 27 Nov',
      );
    });

    testWidgets('the repeat and bell icons only show when they apply', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      // Water tomato beds repeats daily and has no reminder.
      expect(byTestId(TestIds.tasksItemRepeatIcon('today', 1)), findsOneWidget);
      expect(byTestId(TestIds.tasksItemReminderIcon('today', 1)), findsNothing);
      // Clean water pots repeats weekly and reminds an hour before.
      expect(byTestId(TestIds.tasksItemRepeatIcon('today', 3)), findsOneWidget);
      expect(
        byTestId(TestIds.tasksItemReminderIcon('today', 3)),
        findsOneWidget,
      );
      // Spray beans does neither.
      expect(byTestId(TestIds.tasksItemRepeatIcon('overdue', 1)), findsNothing);
    });

    testWidgets('tapping a row opens that task', (WidgetTester tester) async {
      await openTasks(tester);

      await tester.tap(byTestId(TestIds.tasksItemTitle('today', 1)));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.taskDetailScreen), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.taskDetailTitleText),
        'Water tomato beds',
      );
    });
  });

  group('the Done fold', () {
    testWidgets('Done starts folded and opens when tapped', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      expect(byTestId(TestIds.tasksItem('done', 1)), findsNothing);

      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.tasksItem('done', 1)), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.tasksItemTitle('done', 1)),
        'Vitamin water for hens',
      );
      expect(
        textOfTestId(tester, TestIds.tasksItemLine('done', 1)),
        'Done Wed 25 Nov',
      );
    });

    testWidgets('a done title is struck through', (WidgetTester tester) async {
      await openTasks(tester);
      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();

      final Text title = tester.widget<Text>(
        find.descendant(
          of: byTestId(TestIds.tasksItemTitle('done', 1)),
          matching: find.byType(Text),
        ),
      );
      expect(title.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('tapping again folds it away', (WidgetTester tester) async {
      await openTasks(tester);
      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.tasksItem('done', 1)), findsNothing);
    });
  });

  group('the filter chips', () {
    testWidgets('the counts match the sample', (WidgetTester tester) async {
      await openTasks(tester);

      expect(_chipText(tester, TestIds.tasksFilterAllChip), 'All 6');
      expect(_chipText(tester, TestIds.tasksFilterFieldsChip), 'Fields 3');
      expect(_chipText(tester, TestIds.tasksFilterAnimalsChip), 'Animals 2');
      expect(_chipText(tester, TestIds.tasksFilterGeneralChip), 'General 1');
    });

    testWidgets('a chip narrows the list', (WidgetTester tester) async {
      await openTasks(tester);

      await tester.tap(byTestId(TestIds.tasksFilterGeneralChip));
      await tester.pumpAndSettle();

      // Only Buy chicken feed is general and open.
      expect(byTestId(TestIds.tasksOverdueHeader), findsNothing);
      expect(byTestId(TestIds.tasksTodayHeader), findsNothing);
      expect(textOfTestId(tester, TestIds.tasksUpcomingHeader), 'Upcoming · 1');
      expect(
        textOfTestId(tester, TestIds.tasksItemTitle('upcoming', 1)),
        'Buy chicken feed',
      );
    });

    testWidgets('a chip with nothing in it says so', (
      WidgetTester tester,
    ) async {
      // Every poultry task belongs to an animal group.
      await openTasks(tester, account: DemoAccounts.poultry);

      await tester.tap(byTestId(TestIds.tasksFilterFieldsChip));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.tasksFilterEmptyText), findsOneWidget);
      expect(find.text(TasksScreen.filterEmptyText), findsOneWidget);
    });
  });

  group('completing a task', () {
    testWidgets('the checkbox moves it to Done and offers Undo', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openTasks(tester);

      await tester.tap(byTestId(TestIds.tasksItemCheckbox('overdue', 1)));
      await tester.pumpAndSettle();

      expect(parts.farm.taskById('task-1')?.isDone, isTrue);
      expect(byTestId(TestIds.tasksOverdueHeader), findsNothing);
      expect(textOfTestId(tester, TestIds.tasksDoneToggle), 'Done · 5');
      expect(find.text(TasksScreen.doneMessage), findsOneWidget);
      expect(byTestId(TestIds.tasksUndoButton), findsOneWidget);
    });

    testWidgets('a swipe to the right completes it too', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openTasks(tester);

      await tester.drag(
        byTestId(TestIds.tasksItemTitle('overdue', 1)),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      expect(parts.farm.taskById('task-1')?.isDone, isTrue);
      expect(find.text(TasksScreen.doneMessage), findsOneWidget);
    });

    testWidgets('Undo puts the task back', (WidgetTester tester) async {
      final TestAppParts parts = await openTasks(tester);

      await tester.tap(byTestId(TestIds.tasksItemCheckbox('overdue', 1)));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.tasksUndoButton));
      await tester.pumpAndSettle();

      expect(parts.farm.taskById('task-1')?.isDone, isFalse);
      expect(textOfTestId(tester, TestIds.tasksOverdueHeader), 'Overdue · 1');
    });

    testWidgets('Undo on a repeating task also removes the new one', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openTasks(tester);
      final int before = parts.farm.tasks.length;

      // Water tomato beds repeats daily.
      await tester.tap(byTestId(TestIds.tasksItemCheckbox('today', 1)));
      await tester.pumpAndSettle();
      expect(parts.farm.tasks, hasLength(before + 1));

      await tester.tap(byTestId(TestIds.tasksUndoButton));
      await tester.pumpAndSettle();

      expect(parts.farm.tasks, hasLength(before));
      expect(parts.farm.taskById('task-2')?.isOpen, isTrue);
    });

    testWidgets('a done repeating task has its checkbox turned off', (
      WidgetTester tester,
    ) async {
      await openTasks(tester);

      // Collect eggs repeats daily. Finish it, then look in Done.
      await tester.tap(byTestId(TestIds.tasksItemCheckbox('today', 2)));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();

      final Checkbox box = tester.widget<Checkbox>(
        find.descendant(
          of: byTestId(TestIds.tasksItemCheckbox('done', 1)),
          matching: find.byType(Checkbox),
        ),
      );
      expect(box.onChanged, isNull);
    });

    testWidgets('unticking a plain done task opens it again', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openTasks(tester);
      await tester.tap(byTestId(TestIds.tasksDoneToggle));
      await tester.pumpAndSettle();

      // Vitamin water for hens does not repeat.
      await tester.tap(byTestId(TestIds.tasksItemCheckbox('done', 1)));
      await tester.pumpAndSettle();

      expect(parts.farm.taskById('task-7')?.isOpen, isTrue);
      expect(textOfTestId(tester, TestIds.tasksTodayHeader), 'Today · 4');
    });
  });

  group('empty states', () {
    testWidgets('a new account is told to add a task', (
      WidgetTester tester,
    ) async {
      await openTasks(tester, account: DemoAccounts.newFarm);

      expect(byTestId(TestIds.tasksEmptyState), findsOneWidget);
      expect(find.text(TasksScreen.emptyTitle), findsOneWidget);
      expect(find.text(TasksScreen.emptyMessage), findsOneWidget);
    });

    testWidgets('the empty state opens the form', (WidgetTester tester) async {
      await openTasks(tester, account: DemoAccounts.newFarm);

      await tester.tap(byTestId(TestIds.tasksEmptyAddButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.taskFormScreen), findsOneWidget);
    });
  });

  testWidgets('the add button opens the form', (WidgetTester tester) async {
    await openTasks(tester);

    await tester.tap(byTestId(TestIds.tasksAddButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.taskFormScreen), findsOneWidget);
    expect(textOfTestId(tester, TestIds.taskFormTitleText), 'Add task');
  });

  group('reminders after login', () {
    testWidgets('only the two sample tasks with a reminder are booked', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.farmer,
      );
      await tester.pumpAndSettle();

      // Clean water pots reminds an hour before 5:00 PM today, and Buy
      // chicken feed a day before 10:00 AM on T+2.
      expect(parts.plugin.scheduled, hasLength(2));
      expect(parts.plugin.forTask('task-4')?.at, DateTime(2026, 11, 25, 16));
      expect(parts.plugin.forTask('task-5')?.at, DateTime(2026, 11, 26, 10));
      expect(
        parts.plugin.forTask('task-4')?.body,
        'Duck pond · due at 5:00 PM',
      );
    });

    testWidgets('logging out cancels them', (WidgetTester tester) async {
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.farmer,
      );
      expect(parts.plugin.scheduled, hasLength(2));

      await parts.login.logOut();
      await tester.pumpAndSettle();

      expect(parts.plugin.scheduled, isEmpty);
    });

    testWidgets('deleting a task cancels its reminder', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openTasks(tester);

      await parts.farm.deleteTask('task-4');
      await tester.pumpAndSettle();

      expect(parts.plugin.forTask('task-4'), isNull);
      expect(parts.plugin.scheduled, hasLength(1));
    });
  });

  testWidgets('a change on the list shows on Home at once', (
    WidgetTester tester,
  ) async {
    await openTasks(tester);

    await tester.tap(byTestId(TestIds.tasksItemCheckbox('overdue', 1)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.tabHomeButton));
    await tester.pumpAndSettle();

    // The only overdue task is done, so the warning line is gone.
    expect(byTestId(TestIds.homeTasksOverdueText), findsNothing);
  });
}

/// The text on a filter chip, such as "Fields 3".
String _chipText(WidgetTester tester, String id) => tester
    .widget<Text>(
      find.descendant(of: byTestId(id), matching: find.byType(Text)),
    )
    .data!;
