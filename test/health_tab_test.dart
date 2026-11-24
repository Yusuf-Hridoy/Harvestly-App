import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/animals/widgets/health_task_form.dart';
import 'package:harvestly/features/animals/widgets/loss_dialog.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens one group on its Health tab.
  Future<TestAppParts> openHealth(
    WidgetTester tester, {
    int cardNumber = 1,
  }) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
    );
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.animalsListItem(cardNumber)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupTabHealth));
    await tester.pumpAndSettle();
    return parts;
  }

  testWidgets('a flock counts birds', (WidgetTester tester) async {
    await openHealth(tester);

    expect(textOfTestId(tester, TestIds.healthCountTitleText), 'Birds now');
    expect(textOfTestId(tester, TestIds.healthCountValueText), '24');
  });

  testWidgets('a herd counts animals', (WidgetTester tester) async {
    await openHealth(tester, cardNumber: 4);

    expect(textOfTestId(tester, TestIds.healthCountTitleText), 'Animals now');
    expect(textOfTestId(tester, TestIds.healthCountValueText), '2');
  });

  testWidgets('open tasks show their state line', (WidgetTester tester) async {
    await openHealth(tester);

    expect(
      textOfTestId(tester, TestIds.healthTaskItemTitle(1)),
      'Newcastle booster',
    );
    expect(textOfTestId(tester, TestIds.healthTaskItemState(1)), 'Due today');
    expect(textOfTestId(tester, TestIds.healthTaskItemTitle(2)), 'Deworming');
    expect(
      textOfTestId(tester, TestIds.healthTaskItemState(2)),
      'Coming up · 12 Dec 2026',
    );
  });

  testWidgets('late tasks come first, most late at the top', (
    WidgetTester tester,
  ) async {
    await openHealth(tester, cardNumber: 4);

    expect(
      textOfTestId(tester, TestIds.healthTaskItemTitle(1)),
      'Foot-and-mouth vaccine',
    );
    expect(
      textOfTestId(tester, TestIds.healthTaskItemState(1)),
      'Late by 4 days',
    );
    expect(textOfTestId(tester, TestIds.healthTaskItemTitle(2)), 'Hoof check');
  });

  testWidgets('Done moves the task into the history', (
    WidgetTester tester,
  ) async {
    await openHealth(tester);

    await tester.tap(byTestId(TestIds.healthTaskItemDoneButton(1)));
    await tester.pumpAndSettle();

    expect(find.text('Marked as done.'), findsOneWidget);
    expect(textOfTestId(tester, TestIds.healthTaskItemTitle(1)), 'Deworming');
    expect(byTestId(TestIds.healthTaskItem(2)), findsNothing);
    expect(
      textOfTestId(tester, TestIds.healthHistoryItem(1)),
      'Newcastle booster · done 24 Nov 2026',
    );
  });

  testWidgets('clearing every task shows the caught-up line', (
    WidgetTester tester,
  ) async {
    await openHealth(tester);

    await tester.tap(byTestId(TestIds.healthTaskItemDoneButton(1)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.healthTaskItemDoneButton(1)));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.healthTasksEmptyText),
      "No health tasks. You're all caught up.",
    );
  });

  testWidgets('a group with no records shows both empty lines', (
    WidgetTester tester,
  ) async {
    await openHealth(tester, cardNumber: 2);

    expect(byTestId(TestIds.healthTasksEmptyText), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.healthHistoryEmptyText),
      'Nothing here yet.',
    );
  });

  testWidgets('the history is newest first and mixes tasks with losses', (
    WidgetTester tester,
  ) async {
    await openHealth(tester);

    // Fowl pox was done 23 days ago, the loss was 37 days ago.
    expect(
      textOfTestId(tester, TestIds.healthHistoryItem(1)),
      'Fowl pox vaccine · done 1 Nov 2026',
    );
    expect(
      textOfTestId(tester, TestIds.healthHistoryItem(2)),
      'Lost 2 birds · Sickness · 18 Oct 2026',
    );
  });

  testWidgets('Add task checks the name and can make a late task', (
    WidgetTester tester,
  ) async {
    final TestAppParts parts = await openHealth(tester, cardNumber: 2);

    await tester.tap(byTestId(TestIds.healthAddTaskButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.taskFormScreen), findsOneWidget);

    await tester.tap(byTestId(TestIds.taskFormSaveButton));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.taskFormTitleErrorText),
      HealthTaskForm.titleEmptyError,
    );

    await tester.enterText(byTestId(TestIds.taskFormTitleInput), 'A');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.taskFormSaveButton));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.taskFormTitleErrorText),
      HealthTaskForm.titleLengthError,
    );

    await tester.enterText(
      byTestId(TestIds.taskFormTitleInput),
      'Clean the pond',
    );
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.taskFormSaveButton));
    await tester.pumpAndSettle();

    expect(find.text('Health task added.'), findsOneWidget);
    expect(textOfTestId(tester, TestIds.healthTaskItemState(1)), 'Due today');

    // A past due date is allowed, and it reads as late.
    await parts.farm.addHealthTask(
      groupId: 'group-2',
      title: 'Old job',
      dueOn: AppClock.today().subtract(const Duration(days: 3)),
    );
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.healthTaskItemTitle(1)), 'Old job');
    expect(
      textOfTestId(tester, TestIds.healthTaskItemState(1)),
      'Late by 3 days',
    );
  });

  testWidgets('leaving the task form with text asks first', (
    WidgetTester tester,
  ) async {
    await openHealth(tester);

    await tester.tap(byTestId(TestIds.healthAddTaskButton));
    await tester.pumpAndSettle();
    await tester.enterText(byTestId(TestIds.taskFormTitleInput), 'Half typed');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.taskFormCancelButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsOneWidget);
    await tester.tap(byTestId(TestIds.discardDialogDiscardButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.healthTab), findsOneWidget);
  });

  group('record loss', () {
    testWidgets('it checks the number and the reason', (
      WidgetTester tester,
    ) async {
      await openHealth(tester);

      await tester.tap(byTestId(TestIds.healthRecordLossButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.lossDialog), findsOneWidget);

      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.lossDialogAmountErrorText),
        LossDialog.amountEmptyError,
      );
      expect(
        textOfTestId(tester, TestIds.lossDialogReasonErrorText),
        LossDialog.reasonEmptyError,
      );

      // More than the group holds.
      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '25');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.lossDialogAmountErrorText),
        'You only have 24 birds.',
      );

      // Zero is not a loss.
      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '0');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.lossDialogAmountErrorText),
        LossDialog.amountWholeError,
      );
    });

    testWidgets('a saved loss lowers the count everywhere', (
      WidgetTester tester,
    ) async {
      await openHealth(tester);

      await tester.tap(byTestId(TestIds.healthRecordLossButton));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '4');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonPicker));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonOptionPredator));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Loss saved.'), findsOneWidget);
      expect(textOfTestId(tester, TestIds.healthCountValueText), '20');
      expect(
        textOfTestId(tester, TestIds.healthHistoryItem(1)),
        'Lost 4 birds · Predator · 24 Nov 2026',
      );

      // The detail header and the list follow at once.
      expect(
        textOfTestId(tester, TestIds.groupDetailInfoText),
        'Hens · 20 birds · since 1 Feb 2026',
      );
      await tester.tap(byTestId(TestIds.tabAnimalsButton));
      await tester.pumpAndSettle();
      expect(find.text('Hens · 20 birds'), findsOneWidget);
    });

    testWidgets('the count can be taken all the way to zero', (
      WidgetTester tester,
    ) async {
      await openHealth(tester, cardNumber: 4);

      await tester.tap(byTestId(TestIds.healthRecordLossButton));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '2');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonPicker));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonOptionSold));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();

      expect(textOfTestId(tester, TestIds.healthCountValueText), '0');

      // With no animals left, the per animal stat has nothing to divide.
      await tester.tap(byTestId(TestIds.groupTabMilk));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionRateText), '–');
    });

    testWidgets('a loss of one uses the singular word', (
      WidgetTester tester,
    ) async {
      await openHealth(tester, cardNumber: 4);

      await tester.tap(byTestId(TestIds.healthRecordLossButton));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '3');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.lossDialogAmountErrorText),
        'You only have 2 animals.',
      );

      await tester.enterText(byTestId(TestIds.lossDialogAmountInput), '1');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonPicker));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogReasonOptionAccident));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.lossDialogSaveButton));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.healthHistoryItem(1)),
        'Lost 1 animal · Accident · 24 Nov 2026',
      );
    });
  });
}
