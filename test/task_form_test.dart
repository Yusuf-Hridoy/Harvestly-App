import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/data/task_models.dart';
import 'package:harvestly/features/tasks/task_form_screen.dart';
import 'package:harvestly/features/tasks/widgets/reminder_explainer_sheet.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';

import 'helpers/pump_harvestly_app.dart';

/// Today for every test here: Wednesday 25 November 2026, 8:00 in the
/// morning. An hour before the time a new task starts with, so a reminder
/// "at due time" is still to come.
final DateTime _today = DateTime(2026, 11, 25, 8);

/// Opens Tasks, then the Add task form.
Future<TestAppParts> openAddForm(
  WidgetTester tester, {
  DemoAccount? account,
  bool notificationsAllowed = true,
  bool grantOnRequest = true,
}) async {
  final TestAppParts parts = await pumpHarvestlyApp(
    tester,
    startAccount: account ?? DemoAccounts.farmer,
    notificationsAllowed: notificationsAllowed,
    grantOnRequest: grantOnRequest,
  );
  await tester.tap(byTestId(TestIds.tabTasksButton));
  await tester.pumpAndSettle();
  await tester.tap(byTestId(TestIds.tasksAddButton));
  await tester.pumpAndSettle();
  return parts;
}

/// Types into a field and lets a frame pass, the way a real user does.
Future<void> typeIn(WidgetTester tester, String id, String text) async {
  await tester.enterText(byTestId(id), text);
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(byTestId(TestIds.taskFormSaveButton));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  group('what the form starts with', () {
    testWidgets('an empty form says Add task and repeats nothing', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);

      expect(textOfTestId(tester, TestIds.taskFormTitleText), 'Add task');
      expect(byTestId(TestIds.taskFormReminderLineText), findsNothing);
      expect(textOfTestId(tester, TestIds.taskFormNoteCounterText), '0 / 200');
      // Today, at the 9:00 a new task starts with.
      expect(find.text('25 Nov'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
    });
  });

  group('the errors', () {
    testWidgets('an empty task name is refused', (WidgetTester tester) async {
      await openAddForm(tester);
      await save(tester);

      expect(
        textOfTestId(tester, TestIds.taskFormNameErrorText),
        TaskFormScreen.nameEmptyError,
      );
    });

    testWidgets('one character is too short', (WidgetTester tester) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'A');
      await save(tester);

      expect(
        textOfTestId(tester, TestIds.taskFormNameErrorText),
        TaskFormScreen.nameLengthError,
      );
    });

    testWidgets('the error clears as soon as the name is typed in', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);
      await save(tester);
      expect(byTestId(TestIds.taskFormNameErrorText), findsOneWidget);

      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      expect(byTestId(TestIds.taskFormNameErrorText), findsNothing);
    });

    testWidgets('a reminder already in the past is refused', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');

      // Due today at 9:00, reminded a day before, which was yesterday.
      await tester.tap(byTestId(TestIds.taskFormReminderDayBeforeChip));
      await tester.pumpAndSettle();
      await save(tester);

      expect(
        textOfTestId(tester, TestIds.taskFormReminderErrorText),
        TaskFormScreen.reminderPastError,
      );
      expect(byTestId(TestIds.taskFormScreen), findsOneWidget);
    });

    testWidgets('picking another reminder clears that error', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderDayBeforeChip));
      await tester.pumpAndSettle();
      await save(tester);
      expect(byTestId(TestIds.taskFormReminderErrorText), findsOneWidget);

      await tester.tap(byTestId(TestIds.taskFormReminderNoneChip));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.taskFormReminderErrorText), findsNothing);
    });
  });

  group('the note counter', () {
    testWidgets('it counts what was typed', (WidgetTester tester) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNoteInput, 'Bring the wire');

      expect(textOfTestId(tester, TestIds.taskFormNoteCounterText), '14 / 200');
    });
  });

  group('the reminder line', () {
    testWidgets('it shows when a reminder is picked and follows it', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');

      expect(byTestId(TestIds.taskFormReminderLineText), findsNothing);

      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.taskFormReminderLineText),
        'Reminder on Wed 25 Nov at 9:00 AM',
      );

      await tester.tap(byTestId(TestIds.taskFormReminderHourBeforeChip));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.taskFormReminderLineText),
        'Reminder on Wed 25 Nov at 8:00 AM',
      );

      await tester.tap(byTestId(TestIds.taskFormReminderNoneChip));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.taskFormReminderLineText), findsNothing);
    });
  });

  group('the link picker', () {
    testWidgets('it lists None, the fields and the groups', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);

      await tester.tap(byTestId(TestIds.taskFormLinkInput));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.linkPickerSheet), findsOneWidget);
      expect(byTestId(TestIds.linkPickerNoneOption), findsOneWidget);
      expect(
        byTestId(TestIds.linkPickerFieldOption('field-2')),
        findsOneWidget,
      );
      expect(
        byTestId(TestIds.linkPickerGroupOption('group-1')),
        findsOneWidget,
      );
      // The tab bar has these words too, so only the sheet is looked at.
      expect(
        find.descendant(
          of: byTestId(TestIds.linkPickerSheet),
          matching: find.text('Fields'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: byTestId(TestIds.linkPickerSheet),
          matching: find.text('Animals'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('picking a group puts its name on the form', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);

      await tester.tap(byTestId(TestIds.taskFormLinkInput));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.linkPickerGroupOption('group-2')));
      await tester.pumpAndSettle();

      expect(find.text('Duck pond'), findsOneWidget);
      // The small tag says which list it came from.
      expect(
        find.descendant(
          of: byTestId(TestIds.taskFormLinkInput),
          matching: find.text('Animals'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('picking None puts it back to General', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);

      await tester.tap(byTestId(TestIds.taskFormLinkInput));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.linkPickerFieldOption('field-1')));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.taskFormLinkInput));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.linkPickerNoneOption));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
    });
  });

  group('saving', () {
    testWidgets('a new task opens its detail and says so', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormRepeatWeeklyChip));
      await tester.pumpAndSettle();
      await save(tester);

      expect(byTestId(TestIds.taskDetailScreen), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.taskDetailTitleText),
        'Mend the gate',
      );
      expect(find.text('Task added.'), findsOneWidget);

      final FarmTask added = parts.farm.tasks.last;
      expect(added.title, 'Mend the gate');
      expect(added.repeat, Repeat.weekly);
      expect(added.dueAt, DateTime(2026, 11, 25, 9));
    });

    testWidgets('editing shows the task and updates it', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.farmer,
      );
      await tester.tap(byTestId(TestIds.tabTasksButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.tasksItemTitle('today', 3)));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.taskDetailEditButton));
      await tester.pumpAndSettle();

      expect(textOfTestId(tester, TestIds.taskFormTitleText), 'Edit task');
      expect(textOfTestId(tester, TestIds.taskFormNoteCounterText), '29 / 200');

      await typeIn(tester, TestIds.taskFormNameInput, 'Scrub the pots');
      await save(tester);

      expect(find.text('Task updated.'), findsOneWidget);
      expect(parts.farm.taskById('task-4')?.title, 'Scrub the pots');
    });
  });

  group('leaving the form', () {
    testWidgets('Cancel with no changes just leaves', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester);

      await tester.tap(byTestId(TestIds.taskFormCancelButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.tasksScreen), findsOneWidget);
      expect(byTestId(TestIds.discardDialog), findsNothing);
    });

    testWidgets('leaving with changes asks first', (WidgetTester tester) async {
      await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Half typed');

      await tester.tap(byTestId(TestIds.taskFormCancelButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.discardDialog), findsOneWidget);

      await tester.tap(byTestId(TestIds.discardDialogKeepButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.taskFormScreen), findsOneWidget);

      await tester.tap(byTestId(TestIds.taskFormCancelButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.discardDialogDiscardButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.tasksScreen), findsOneWidget);
    });
  });

  group('asking for notifications', () {
    testWidgets('with notifications already on, nothing is asked', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(tester);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      await save(tester);

      expect(byTestId(TestIds.reminderExplainerSheet), findsNothing);
      expect(parts.plugin.requests, 0);
      expect(find.text('Task added.'), findsOneWidget);
    });

    testWidgets('a first reminder shows the explainer', (
      WidgetTester tester,
    ) async {
      await openAddForm(tester, notificationsAllowed: false);
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      // Move the due time on, so the reminder is still to come.
      await save(tester);

      expect(byTestId(TestIds.reminderExplainerSheet), findsOneWidget);
      expect(find.text(ReminderExplainerSheet.title), findsOneWidget);
    });

    testWidgets('Not now keeps the task and says reminders are off', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(
        tester,
        notificationsAllowed: false,
      );
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      await save(tester);

      await tester.tap(byTestId(TestIds.reminderExplainerNotNowButton));
      await tester.pumpAndSettle();

      expect(parts.plugin.requests, 0);
      expect(parts.farm.tasks.last.title, 'Mend the gate');
      expect(find.text(TaskFormScreen.remindersOffMessage), findsOneWidget);
    });

    testWidgets('Continue then Don\'t allow keeps the task, books nothing', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(
        tester,
        notificationsAllowed: false,
        grantOnRequest: false,
      );
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      await save(tester);

      await tester.tap(byTestId(TestIds.reminderExplainerContinueButton));
      await tester.pumpAndSettle();

      expect(parts.plugin.requests, 1);
      expect(parts.plugin.scheduled, isEmpty);
      expect(parts.farm.tasks.last.title, 'Mend the gate');
      expect(find.text(TaskFormScreen.remindersOffMessage), findsOneWidget);
    });

    testWidgets('Continue then Allow books the reminder', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(
        tester,
        notificationsAllowed: false,
      );
      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      await save(tester);

      await tester.tap(byTestId(TestIds.reminderExplainerContinueButton));
      await tester.pumpAndSettle();

      expect(parts.plugin.requests, 1);
      final String id = parts.farm.tasks.last.id;
      expect(parts.plugin.forTask(id), isNotNull);
      expect(parts.plugin.forTask(id)!.at, DateTime(2026, 11, 25, 9));
      expect(find.text('Task added.'), findsOneWidget);
    });

    testWidgets('after a refusal the pop-up is never shown again', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await openAddForm(
        tester,
        notificationsAllowed: false,
        grantOnRequest: false,
      );
      await parts.notifications.requestPermission();

      await typeIn(tester, TestIds.taskFormNameInput, 'Mend the gate');
      await tester.tap(byTestId(TestIds.taskFormReminderAtDueChip));
      await tester.pumpAndSettle();
      await save(tester);

      expect(byTestId(TestIds.reminderExplainerSheet), findsNothing);
      // Still only the one request made by the test itself.
      expect(parts.plugin.requests, 1);
      expect(find.text(TaskFormScreen.remindersOffMessage), findsOneWidget);
    });
  });
}
