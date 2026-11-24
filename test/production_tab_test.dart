import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/animals/widgets/amount_dialog.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens one group on its first tab.
  Future<void> openGroup(WidgetTester tester, int cardNumber) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.animalsListItem(cardNumber)));
    await tester.pumpAndSettle();
  }

  /// Flock A, the hens.
  Future<void> openEggs(WidgetTester tester) => openGroup(tester, 1);

  /// Cow shed, the cows.
  Future<void> openMilk(WidgetTester tester) => openGroup(tester, 4);

  group('eggs', () {
    testWidgets('the card shows today\'s eggs and the egg hint', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      expect(byTestId(TestIds.productionTab), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.productionTodayTitleText),
        'Eggs today',
      );
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '18');
      expect(
        textOfTestId(tester, TestIds.productionHintText),
        'Long press + to add 10',
      );
    });

    testWidgets('plus and minus move the number by one', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionPlusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '19');

      await tester.tap(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '17');
    });

    testWidgets('a long press moves the number by ten', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.longPress(byTestId(TestIds.productionPlusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '28');

      await tester.longPress(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '18');
    });

    testWidgets('minus stops at zero and never goes below', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      // 18 eggs, so two long presses would reach -2 without the limit.
      await tester.longPress(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      await tester.longPress(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '0');

      // At zero the button is off.
      await tester.tap(
        byTestId(TestIds.productionMinusButton),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '0');
    });

    testWidgets('tapping the number opens the dialog and types an amount', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionTodayValueText));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.amountDialog), findsOneWidget);

      await tester.enterText(byTestId(TestIds.amountDialogInput), '');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.amountDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.amountDialogErrorText),
        AmountRules.emptyError,
      );

      await tester.enterText(byTestId(TestIds.amountDialogInput), '23');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.amountDialogSaveButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.amountDialog), findsNothing);
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '23');
    });

    testWidgets('an amount over the range is refused', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionTodayValueText));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.amountDialogInput), '99999');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.amountDialogSaveButton));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.amountDialogErrorText),
        AmountRules.rangeError,
      );
    });

    testWidgets('the average and the laying rate match the sample', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      expect(textOfTestId(tester, TestIds.productionAverageText), '16.7 eggs');
      expect(textOfTestId(tester, TestIds.productionRateText), '75%');
    });

    testWidgets('the duck pond has its own average and rate', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 2);

      expect(textOfTestId(tester, TestIds.productionAverageText), '3.9 eggs');
      expect(textOfTestId(tester, TestIds.productionRateText), '66%');
    });

    testWidgets('the chart starts on 7 days with today picked', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      expect(find.text('Last 7 days'), findsOneWidget);
      expect(byTestId(TestIds.productionChartBar(7)), findsOneWidget);
      expect(byTestId(TestIds.productionChartBar(8)), findsNothing);
      expect(
        textOfTestId(tester, TestIds.productionSelectedText),
        'Tue 24 Nov · 18 eggs',
      );
    });

    testWidgets('tapping a bar changes the line under the chart', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      // Bar 1 is the oldest of the seven, which is 18 Nov with 16 eggs.
      await tester.tap(byTestId(TestIds.productionChartBar(1)));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.productionSelectedText),
        'Wed 18 Nov · 16 eggs',
      );
    });

    testWidgets('30 days shows thirty bars and goes back to today', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionRange30Option));
      await tester.pumpAndSettle();

      expect(find.text('Last 30 days'), findsOneWidget);
      expect(byTestId(TestIds.productionChartBar(30)), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.productionSelectedText),
        'Tue 24 Nov · 18 eggs',
      );

      await tester.tap(byTestId(TestIds.productionRange7Option));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.productionChartBar(8)), findsNothing);
    });

    testWidgets('Edit a past day saves that day and says so', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionEditPastButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.pastDayDialog), findsOneWidget);
      // It opens on yesterday.
      expect(find.text('23 Nov 2026'), findsOneWidget);

      await tester.enterText(byTestId(TestIds.pastDayDialogAmountInput), '2');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.pastDayDialogSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Saved 2 eggs for 23 Nov.'), findsOneWidget);

      // Bar 6 of seven is yesterday.
      await tester.tap(byTestId(TestIds.productionChartBar(6)));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.productionSelectedText),
        'Mon 23 Nov · 2 eggs',
      );
    });

    testWidgets('a past day with a bad amount is refused', (
      WidgetTester tester,
    ) async {
      await openEggs(tester);

      await tester.tap(byTestId(TestIds.productionEditPastButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.pastDayDialogSaveButton));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.pastDayDialogErrorText),
        AmountRules.emptyError,
      );
    });
  });

  group('milk', () {
    testWidgets('the card shows litres with one decimal and the milk hint', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      expect(
        textOfTestId(tester, TestIds.productionTodayTitleText),
        'Milk today',
      );
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '14.0');
      expect(
        textOfTestId(tester, TestIds.productionHintText),
        'Long press + to add 5',
      );
    });

    testWidgets('plus and minus move the litres by a half', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      await tester.tap(byTestId(TestIds.productionPlusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '14.5');

      await tester.tap(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '13.5');
    });

    testWidgets('a long press moves the litres by five', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      await tester.longPress(byTestId(TestIds.productionPlusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '19.0');

      await tester.longPress(byTestId(TestIds.productionMinusButton));
      await tester.pumpAndSettle();
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '14.0');
    });

    testWidgets('the average and the per animal stat match the sample', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      expect(textOfTestId(tester, TestIds.productionAverageText), '13.6 L');
      expect(textOfTestId(tester, TestIds.productionRateText), '7.0 L');
    });

    testWidgets('the goat herd has its own average and per animal stat', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 3);

      expect(textOfTestId(tester, TestIds.productionAverageText), '3.3 L');
      expect(textOfTestId(tester, TestIds.productionRateText), '0.7 L');
    });

    testWidgets('the picked line reads litres', (WidgetTester tester) async {
      await openMilk(tester);

      expect(
        textOfTestId(tester, TestIds.productionSelectedText),
        'Tue 24 Nov · 14.0 L',
      );
    });

    testWidgets('a milk amount with two decimals cannot be typed', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      await tester.tap(byTestId(TestIds.productionTodayValueText));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.amountDialogInput), '12.55');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.amountDialogSaveButton));
      await tester.pumpAndSettle();

      // The input itself stops the second decimal, so 12.5 is saved.
      expect(textOfTestId(tester, TestIds.productionTodayValueText), '12.5');
    });

    testWidgets('Edit a past day says litres in the snackbar', (
      WidgetTester tester,
    ) async {
      await openMilk(tester);

      await tester.tap(byTestId(TestIds.productionEditPastButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        byTestId(TestIds.pastDayDialogAmountInput),
        '13.5',
      );
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.pastDayDialogSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Saved 13.5 L for 23 Nov.'), findsOneWidget);
    });
  });

  testWidgets('the Animals list and Home follow a change at once', (
    WidgetTester tester,
  ) async {
    await openEggs(tester);

    await tester.longPress(byTestId(TestIds.productionPlusButton));
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.productionTodayValueText), '28');

    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.animalsListItemToday(1)),
      '28 eggs today',
    );

    await tester.tap(byTestId(TestIds.tabHomeButton));
    await tester.pumpAndSettle();
    // 28 from Flock A plus 4 from the duck pond.
    expect(
      find.descendant(
        of: byTestId(TestIds.homeStatEggsCard),
        matching: find.text('32'),
      ),
      findsOneWidget,
    );
  });
}
