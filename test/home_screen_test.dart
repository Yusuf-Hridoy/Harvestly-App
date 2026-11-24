import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/animal_models.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/home/widgets/empty_farm_card.dart';
import 'package:harvestly/features/home/widgets/harvest_soon_card.dart';
import 'package:harvestly/features/home/widgets/stat_card.dart';
import 'package:harvestly/features/home/widgets/weather_card.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Reads the style of the first Text widget that shows [text].
TextStyle? _styleOf(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text).first).style;
}

void main() {
  testWidgets('the farmer account shows 4 stat cards and the harvest card', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    expect(find.byType(StatCard), findsNWidgets(4));
    expect(find.byType(HarvestSoonCard), findsOneWidget);
    expect(find.byType(WeatherCard), findsOneWidget);
    expect(find.text('Tk 12,400'), findsOneWidget);
    expect(find.text('12 days left'), findsOneWidget);
  });

  testWidgets('the poultry account hides the harvest card', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.poultry);

    expect(find.byType(StatCard), findsNWidgets(4));
    expect(find.byType(HarvestSoonCard), findsNothing);
    expect(find.text('Tk 5,800'), findsOneWidget);
  });

  testWidgets('the new account shows the empty farm card and no stat cards', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.newFarm);

    expect(find.byType(EmptyFarmCard), findsOneWidget);
    expect(find.byType(StatCard), findsNothing);
    expect(find.byType(WeatherCard), findsNothing);
    expect(find.byType(HarvestSoonCard), findsNothing);
    expect(find.text('Welcome to Harvestly'), findsOneWidget);
  });

  testWidgets('the greeting uses the first name only', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    expect(find.textContaining('Rahim'), findsOneWidget);
    expect(find.textContaining('Rahim Uddin'), findsNothing);
  });

  testWidgets('ticking a task strikes it through', (WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    const String title = 'Water tomato beds';
    expect(
      _styleOf(tester, title)?.decoration,
      isNot(TextDecoration.lineThrough),
    );

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(_styleOf(tester, title)?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('a task that starts ticked is struck through at once', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    expect(
      _styleOf(tester, 'Vitamin water for hens')?.decoration,
      TextDecoration.lineThrough,
    );
  });

  testWidgets('the bell shows the later phase message', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Notifications come in a later phase.'), findsOneWidget);
  });

  testWidgets('See all opens the Tasks tab', (WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('This part comes in a later phase.'), findsOneWidget);
  });

  testWidgets('Add your first field opens the Fields tab', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.newFarm);

    await tester.tap(find.text('Add your first field'));
    await tester.pumpAndSettle();

    // Phase 2 replaced the Fields placeholder with the real, empty list.
    expect(find.text('No fields yet'), findsOneWidget);
  });
  group('animals on Home', () {
    setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
    tearDown(AppClock.useRealClock);

    testWidgets('Eggs today adds up every flock\'s log for today', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      // Flock A logged 18 and the duck pond 4.
      expect(
        find.descendant(
          of: byTestId(TestIds.homeStatEggsCard),
          matching: find.text('22'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the poultry account has its own eggs count', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.poultry);

      expect(
        find.descendant(
          of: byTestId(TestIds.homeStatEggsCard),
          matching: find.text('26'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the animal health card shows the most late task', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      expect(byTestId(TestIds.homeAnimalHealthCard), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.homeAnimalHealthTitleText),
        'Foot-and-mouth vaccine · Cow shed',
      );
      expect(
        textOfTestId(tester, TestIds.homeAnimalHealthStateText),
        'Late by 4 days',
      );
    });

    testWidgets('with nothing late it shows the next task inside a week', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.poultry);

      expect(
        textOfTestId(tester, TestIds.homeAnimalHealthTitleText),
        'Fowl pox vaccine · Backyard flock',
      );
      expect(
        textOfTestId(tester, TestIds.homeAnimalHealthStateText),
        'Coming up · 27 Nov 2026',
      );
    });

    testWidgets('tapping the card opens that group on its Health tab', (
      WidgetTester tester,
    ) async {
      await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

      await tester.tap(byTestId(TestIds.homeAnimalHealthCard));
      await tester.pumpAndSettle();

      expect(textOfTestId(tester, TestIds.groupDetailTitleText), 'Cow shed');
      expect(byTestId(TestIds.healthTab), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.healthTaskItemTitle(1)),
        'Foot-and-mouth vaccine',
      );
    });

    testWidgets('the card hides when nothing needs attention soon', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.poultry,
      );

      await parts.farm.markTaskDone(groupId: 'group-1', taskId: 'task-1');
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.homeAnimalHealthCard), findsNothing);
    });

    testWidgets('the welcome card needs no fields, no groups and no tasks', (
      WidgetTester tester,
    ) async {
      final TestAppParts parts = await pumpHarvestlyApp(
        tester,
        startAccount: DemoAccounts.newFarm,
      );

      expect(find.byType(EmptyFarmCard), findsOneWidget);

      await parts.farm.addGroup(
        name: 'First flock',
        type: AnimalType.hens,
        count: 6,
        startedOn: AppClock.today(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyFarmCard), findsNothing);
      expect(find.byType(WeatherCard), findsOneWidget);
    });
  });
}
