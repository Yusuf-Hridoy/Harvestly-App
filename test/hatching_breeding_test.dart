import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/animals/widgets/birth_dialog.dart';
import 'package:harvestly/features/animals/widgets/hatch_batch_form.dart';
import 'package:harvestly/features/animals/widgets/hatch_result_dialog.dart';
import 'package:harvestly/features/animals/widgets/pregnancy_form.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  Future<void> openGroup(WidgetTester tester, int cardNumber) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.animalsListItem(cardNumber)));
    await tester.pumpAndSettle();
  }

  /// Flock A on its Hatching tab.
  Future<void> openHatching(WidgetTester tester) async {
    await openGroup(tester, 1);
    await tester.tap(byTestId(TestIds.groupTabHatching));
    await tester.pumpAndSettle();
  }

  /// Cow shed on its Breeding tab.
  Future<void> openBreeding(WidgetTester tester) async {
    await openGroup(tester, 4);
    await tester.tap(byTestId(TestIds.groupTabBreeding));
    await tester.pumpAndSettle();
  }

  group('tabs', () {
    testWidgets('a flock gets Eggs, Hatching and Health', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 1);

      expect(byTestId(TestIds.groupTabEggs), findsOneWidget);
      expect(byTestId(TestIds.groupTabHatching), findsOneWidget);
      expect(byTestId(TestIds.groupTabHealth), findsOneWidget);
      expect(byTestId(TestIds.groupTabMilk), findsNothing);
      expect(byTestId(TestIds.groupTabBreeding), findsNothing);
    });

    testWidgets('a herd gets Milk, Breeding and Health', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 4);

      expect(byTestId(TestIds.groupTabMilk), findsOneWidget);
      expect(byTestId(TestIds.groupTabBreeding), findsOneWidget);
      expect(byTestId(TestIds.groupTabHealth), findsOneWidget);
      expect(byTestId(TestIds.groupTabEggs), findsNothing);
      expect(byTestId(TestIds.groupTabHatching), findsNothing);
    });

    testWidgets('a swipe on the tab body changes the tab', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 1);
      expect(byTestId(TestIds.productionTab), findsOneWidget);

      await tester.drag(
        byTestId(TestIds.productionTodayTitleText),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.hatchingTab), findsOneWidget);
      expect(byTestId(TestIds.productionTab), findsNothing);
    });

    testWidgets('a sideways drag on the 30-day chart never changes the tab', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 1);
      await tester.tap(byTestId(TestIds.productionRange30Option));
      await tester.pumpAndSettle();

      final ScrollableState chart = tester.state<ScrollableState>(
        find.descendant(
          of: byTestId(TestIds.productionChart),
          matching: find.byType(Scrollable),
        ),
      );
      final double before = chart.position.pixels;

      await tester.drag(
        byTestId(TestIds.productionChart),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      // The chart scrolled, and the tab stayed where it was.
      expect(chart.position.pixels, lessThan(before));
      expect(byTestId(TestIds.productionTab), findsOneWidget);
      expect(byTestId(TestIds.hatchingTab), findsNothing);
    });

    testWidgets('a sideways drag on the timeline never changes the tab', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);

      final String cardId = TestIds.hatchingBatchItem(1);
      final ScrollableState timeline = tester.state<ScrollableState>(
        find.descendant(
          of: byTestId(TestIds.timeline(cardId)),
          matching: find.byType(Scrollable),
        ),
      );
      final double before = timeline.position.pixels;

      await tester.drag(
        byTestId(TestIds.timeline(cardId)),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(timeline.position.pixels, greaterThan(before));
      expect(byTestId(TestIds.hatchingTab), findsOneWidget);
      expect(byTestId(TestIds.healthTab), findsNothing);
    });

    testWidgets('a tab name in the URL opens that tab', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
      await tester.tap(byTestId(TestIds.tabHomeButton));
      await tester.pumpAndSettle();

      // Home's animal health card links to a group's Health tab.
      await tester.tap(byTestId(TestIds.homeAnimalHealthCard));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.groupDetailScreen), findsOneWidget);
      expect(textOfTestId(tester, TestIds.groupDetailTitleText), 'Cow shed');
      expect(byTestId(TestIds.healthTab), findsOneWidget);
    });
  });

  group('hatching', () {
    testWidgets('the active batch shows its day chip and line', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);

      expect(
        textOfTestId(tester, TestIds.hatchingBatchItemTitle(1)),
        'Batch 3',
      );
      expect(
        textOfTestId(tester, TestIds.hatchingBatchItemDayChip(1)),
        'Day 14 of 21',
      );
      expect(
        find.text('10 hen eggs · Started 11 Nov 2026 · Hatch around 1 Dec'),
        findsOneWidget,
      );
    });

    testWidgets('past batches show the result and the rate, newest first', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);

      expect(textOfTestId(tester, TestIds.hatchingPastItemRate(1)), '80%');
      expect(textOfTestId(tester, TestIds.hatchingPastItemRate(2)), '66%');
      expect(find.text('8 of 10 hatched · 21 Oct 2026'), findsOneWidget);
    });

    testWidgets('the timeline is in date order with a Today dot', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);
      final String cardId = TestIds.hatchingBatchItem(1);

      // Four milestones: set eggs, candle, stop turning, hatch day.
      expect(byTestId(TestIds.timelineStep(cardId, 1)), findsOneWidget);
      expect(byTestId(TestIds.timelineStep(cardId, 4)), findsOneWidget);
      expect(byTestId(TestIds.timelineStep(cardId, 5)), findsNothing);
      expect(find.text('Set eggs'), findsOneWidget);
      expect(find.text('Hatch day'), findsOneWidget);
      expect(find.text('Day 18'), findsOneWidget);

      // Today is day 14, which is not a milestone, so a Today dot is added
      // between Candle (day 7) and Stop turning (day 18).
      final Finder today = byTestId(TestIds.timelineTodayMarker(cardId));
      expect(today, findsOneWidget);
      expect(
        tester.getCenter(today).dx,
        greaterThan(
          tester.getCenter(byTestId(TestIds.timelineStep(cardId, 2))).dx,
        ),
      );
      expect(
        tester.getCenter(today).dx,
        lessThan(
          tester.getCenter(byTestId(TestIds.timelineStep(cardId, 3))).dx,
        ),
      );
    });

    testWidgets('a batch started today has no extra Today dot', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 2);
      await tester.tap(byTestId(TestIds.groupTabHatching));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.hatchingEmptyText),
        'No hatching batches yet.',
      );

      await tester.tap(byTestId(TestIds.hatchingNewBatchButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.batchFormSaveButton));
      await tester.pumpAndSettle();

      final String cardId = TestIds.hatchingBatchItem(1);
      // Day 1 is today, so that milestone becomes the Today dot itself.
      expect(byTestId(TestIds.timelineTodayMarker(cardId)), findsNothing);
      expect(byTestId(TestIds.timelineStep(cardId, 1)), findsOneWidget);
    });

    testWidgets('a batch past its hatch day says so', (
      WidgetTester tester,
    ) async {
      // Ducks take 28 days, so a batch set 60 days ago is well past. The
      // date picker only reaches 60 days back, so the batch is made through
      // the repository and the card is what this test checks.
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.farmer,
      );
      await parts.farm.addBatch(
        groupId: 'group-2',
        startedOn: AppClock.today().subtract(const Duration(days: 60)),
        eggs: 6,
      );
      await tester.tap(byTestId(TestIds.tabAnimalsButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.animalsListItem(2)));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.groupTabHatching));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.hatchingBatchItemDayChip(1)),
        'Hatch day passed',
      );
    });

    testWidgets('New batch checks the egg count and starts the next number', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);

      await tester.tap(byTestId(TestIds.hatchingNewBatchButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.batchFormScreen), findsOneWidget);

      await tester.enterText(byTestId(TestIds.batchFormEggsInput), '');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.batchFormSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.batchFormEggsErrorText),
        HatchBatchForm.eggsEmptyError,
      );

      await tester.enterText(byTestId(TestIds.batchFormEggsInput), '501');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.batchFormSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.batchFormEggsErrorText),
        HatchBatchForm.eggsRangeError,
      );

      await tester.enterText(byTestId(TestIds.batchFormEggsInput), '12');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.batchFormSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Batch 4 started.'), findsOneWidget);
      // The newest batch is first.
      expect(
        textOfTestId(tester, TestIds.hatchingBatchItemTitle(1)),
        'Batch 4',
      );
      expect(
        textOfTestId(tester, TestIds.hatchingBatchItemTitle(2)),
        'Batch 3',
      );
    });

    testWidgets('Record result checks the number, then moves the batch', (
      WidgetTester tester,
    ) async {
      await openHatching(tester);

      await tester.tap(byTestId(TestIds.hatchingBatchItemRecordButton(1)));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.hatchResultDialog), findsOneWidget);

      await tester.tap(byTestId(TestIds.hatchResultDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.hatchResultDialogErrorText),
        HatchResultDialog.emptyError,
      );

      await tester.enterText(byTestId(TestIds.hatchResultDialogInput), '11');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.hatchResultDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.hatchResultDialogErrorText),
        'Use a whole number from 0 to 10.',
      );

      await tester.enterText(byTestId(TestIds.hatchResultDialogInput), '8');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.hatchResultDialogSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Batch 3 saved: 8 of 10 hatched.'), findsOneWidget);
      expect(byTestId(TestIds.hatchingBatchItem(1)), findsNothing);
      expect(textOfTestId(tester, TestIds.hatchingPastItemRate(1)), '80%');
      expect(find.text('8 of 10 hatched · 24 Nov 2026'), findsOneWidget);
    });
  });

  group('breeding', () {
    testWidgets('the active pregnancy shows its days chip and line', (
      WidgetTester tester,
    ) async {
      await openBreeding(tester);

      expect(
        textOfTestId(tester, TestIds.breedingItemTitle(1)),
        'Lali · pregnant',
      );
      expect(
        textOfTestId(tester, TestIds.breedingItemDaysChip(1)),
        '47 days left',
      );
      expect(
        find.text('Cow · Mated 2 Apr 2026 · Due around 10 Jan 2027'),
        findsOneWidget,
      );
    });

    testWidgets('past births use the right word for the young', (
      WidgetTester tester,
    ) async {
      await openBreeding(tester);

      expect(textOfTestId(tester, TestIds.breedingPastItemYoung(1)), '1 calf');
      expect(find.text('Shyamoli'), findsOneWidget);
    });

    testWidgets('the goat herd starts with the empty state', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 3);
      await tester.tap(byTestId(TestIds.groupTabBreeding));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.breedingEmptyText),
        'No pregnancies yet.',
      );
      expect(byTestId(TestIds.breedingItem(1)), findsNothing);
    });

    testWidgets('the pregnancy timeline shows dates and a Today dot', (
      WidgetTester tester,
    ) async {
      await openBreeding(tester);
      final String cardId = TestIds.breedingItem(1);

      expect(byTestId(TestIds.timelineStep(cardId, 1)), findsOneWidget);
      expect(byTestId(TestIds.timelineStep(cardId, 4)), findsOneWidget);
      expect(byTestId(TestIds.timelineTodayMarker(cardId)), findsOneWidget);
      expect(find.text('Mated'), findsOneWidget);
      expect(find.text('Dry off'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      // Dates, not day numbers.
      expect(find.text('2 Apr'), findsOneWidget);
      expect(find.text('10 Jan'), findsOneWidget);
    });

    testWidgets('New pregnancy checks the name and saves', (
      WidgetTester tester,
    ) async {
      await openGroup(tester, 3);
      await tester.tap(byTestId(TestIds.groupTabBreeding));
      await tester.pumpAndSettle();

      await tester.tap(byTestId(TestIds.breedingNewButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.pregnancyFormScreen), findsOneWidget);

      await tester.tap(byTestId(TestIds.pregnancyFormSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.pregnancyFormNameErrorText),
        PregnancyForm.nameEmptyError,
      );

      await tester.enterText(byTestId(TestIds.pregnancyFormNameInput), 'Moti');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.pregnancyFormSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Pregnancy added for Moti.'), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.breedingItemTitle(1)),
        'Moti · pregnant',
      );
      // Goats carry for 150 days, so a mating today leaves 150.
      expect(
        textOfTestId(tester, TestIds.breedingItemDaysChip(1)),
        '150 days left',
      );
    });

    testWidgets('Record birth checks the number, then moves the pregnancy', (
      WidgetTester tester,
    ) async {
      await openBreeding(tester);

      await tester.tap(byTestId(TestIds.breedingItemRecordButton(1)));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.birthDialog), findsOneWidget);

      await tester.tap(byTestId(TestIds.birthDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.birthDialogYoungErrorText),
        BirthDialog.emptyError,
      );

      await tester.enterText(byTestId(TestIds.birthDialogYoungInput), '9');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.birthDialogSaveButton));
      await tester.pumpAndSettle();
      expect(
        textOfTestId(tester, TestIds.birthDialogYoungErrorText),
        BirthDialog.rangeError,
      );

      await tester.enterText(byTestId(TestIds.birthDialogYoungInput), '2');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.birthDialogSaveButton));
      await tester.pumpAndSettle();

      expect(find.text('Birth saved for Lali.'), findsOneWidget);
      expect(byTestId(TestIds.breedingItem(1)), findsNothing);
      expect(
        textOfTestId(tester, TestIds.breedingPastItemYoung(1)),
        '2 calves',
      );
      expect(find.text('Born 24 Nov 2026'), findsOneWidget);
    });

    testWidgets('a birth of none survived is allowed', (
      WidgetTester tester,
    ) async {
      await openBreeding(tester);

      await tester.tap(byTestId(TestIds.breedingItemRecordButton(1)));
      await tester.pumpAndSettle();
      await tester.enterText(byTestId(TestIds.birthDialogYoungInput), '0');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.birthDialogSaveButton));
      await tester.pumpAndSettle();

      expect(
        textOfTestId(tester, TestIds.breedingPastItemYoung(1)),
        'None survived',
      );
    });
  });
}
