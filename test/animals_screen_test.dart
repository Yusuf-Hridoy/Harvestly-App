import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens the Animals tab.
  Future<void> openAnimals(
    WidgetTester tester, {
    DemoAccount account = DemoAccounts.farmer,
  }) async {
    await pumpHarvestlyApp(tester, startAccount: account);
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
  }

  testWidgets('the farmer sees four groups with the right chip counts', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    expect(byTestId(TestIds.animalsScreen), findsOneWidget);
    expect(find.text('All 4'), findsOneWidget);
    expect(find.text('Birds 2'), findsOneWidget);
    expect(find.text('Goats 1'), findsOneWidget);
    expect(find.text('Cows 1'), findsOneWidget);

    expect(textOfTestId(tester, TestIds.animalsListItemName(1)), 'Flock A');
    expect(textOfTestId(tester, TestIds.animalsListItemName(4)), 'Cow shed');
  });

  testWidgets('each card shows today\'s eggs or milk', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    expect(
      textOfTestId(tester, TestIds.animalsListItemToday(1)),
      '18 eggs today',
    );
    expect(
      textOfTestId(tester, TestIds.animalsListItemToday(2)),
      '4 eggs today',
    );
    expect(
      textOfTestId(tester, TestIds.animalsListItemToday(3)),
      '3.5 L milk today',
    );
    expect(
      textOfTestId(tester, TestIds.animalsListItemToday(4)),
      '14.0 L milk today',
    );
  });

  testWidgets('the warning line shows late first, then due today', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    // Flock A has a task due today.
    expect(
      textOfTestId(tester, TestIds.animalsListItemWarning(1)),
      'Newcastle booster due today',
    );
    // Duck pond has no tasks at all.
    expect(byTestId(TestIds.animalsListItemWarning(2)), findsNothing);
    // Both herds have a late task, which beats one due today.
    expect(
      textOfTestId(tester, TestIds.animalsListItemWarning(3)),
      'Late: Deworming',
    );
    expect(
      textOfTestId(tester, TestIds.animalsListItemWarning(4)),
      'Late: Foot-and-mouth vaccine',
    );
  });

  testWidgets('a filter chip narrows the list', (WidgetTester tester) async {
    await openAnimals(tester);

    await tester.tap(byTestId(TestIds.animalsFilterBirdsChip));
    await tester.pumpAndSettle();

    expect(textOfTestId(tester, TestIds.animalsListItemName(1)), 'Flock A');
    expect(textOfTestId(tester, TestIds.animalsListItemName(2)), 'Duck pond');
    expect(byTestId(TestIds.animalsListItem(3)), findsNothing);
  });

  testWidgets('the chip counts follow the search', (WidgetTester tester) async {
    await openAnimals(tester);

    await tester.enterText(byTestId(TestIds.animalsSearchInput), 'd');
    await tester.pumpAndSettle();

    // "Duck pond", "Goat herd" and "Cow shed" hold a "d"; "Flock A" does not.
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Birds 1'), findsOneWidget);
    expect(find.text('Goats 1'), findsOneWidget);
    expect(find.text('Cows 1'), findsOneWidget);
  });

  testWidgets('search ignores capitals and the clear button empties it', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    await tester.enterText(byTestId(TestIds.animalsSearchInput), 'FLOCK');
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.animalsListItemName(1)), 'Flock A');
    expect(byTestId(TestIds.animalsListItem(2)), findsNothing);

    await tester.tap(byTestId(TestIds.animalsSearchClearButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.animalsListItem(4)), findsOneWidget);
  });

  testWidgets('a search with no match shows the no-results state', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    await tester.enterText(byTestId(TestIds.animalsSearchInput), 'zebra');
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.animalsNoResultsText),
      'No groups match.',
    );

    await tester.tap(byTestId(TestIds.animalsNoResultsClearButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.animalsNoResultsText), findsNothing);
    expect(byTestId(TestIds.animalsListItem(4)), findsOneWidget);
  });

  testWidgets('a filter and a search together can empty the list', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    await tester.tap(byTestId(TestIds.animalsFilterCowsChip));
    await tester.pumpAndSettle();
    await tester.enterText(byTestId(TestIds.animalsSearchInput), 'Flock');
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.animalsNoResultsText), findsOneWidget);

    // Clear puts back both the search and the chip.
    await tester.tap(byTestId(TestIds.animalsNoResultsClearButton));
    await tester.pumpAndSettle();
    expect(find.text('All 4'), findsOneWidget);
    expect(byTestId(TestIds.animalsListItem(4)), findsOneWidget);
  });

  testWidgets('an account with no groups shows the empty state', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester, account: DemoAccounts.newFarm);

    expect(byTestId(TestIds.animalsEmptyState), findsOneWidget);
    expect(find.text('No animals yet'), findsOneWidget);
    expect(find.text('Add a flock or herd to start tracking.'), findsOneWidget);

    await tester.tap(byTestId(TestIds.animalsEmptyAddButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.groupFormScreen), findsOneWidget);
  });

  testWidgets('long press opens the menu, and Edit opens the form', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    await tester.longPress(byTestId(TestIds.animalsListItem(1)));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupMenuSheet), findsOneWidget);
    expect(find.text('Edit group'), findsOneWidget);
    expect(find.text('Delete group'), findsOneWidget);

    await tester.tap(byTestId(TestIds.groupMenuEditOption));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupFormScreen), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.groupFormTitleText),
      'Edit animal group',
    );
  });

  testWidgets('long press Delete asks first, then removes the group', (
    WidgetTester tester,
  ) async {
    await openAnimals(tester);

    await tester.longPress(byTestId(TestIds.animalsListItem(1)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupMenuDeleteOption));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.deleteGroupDialog), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.deleteGroupDialogMessageText),
      "Flock A and all its records will be removed. You can't undo this.",
    );

    await tester.tap(byTestId(TestIds.deleteGroupDialogCancelButton));
    await tester.pumpAndSettle();
    expect(find.text('All 4'), findsOneWidget);

    await tester.longPress(byTestId(TestIds.animalsListItem(1)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupMenuDeleteOption));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.deleteGroupDialogConfirmButton));
    await tester.pumpAndSettle();

    expect(find.text('Group deleted.'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(textOfTestId(tester, TestIds.animalsListItemName(1)), 'Duck pond');
  });

  testWidgets('tapping a card opens that group', (WidgetTester tester) async {
    await openAnimals(tester);

    await tester.tap(byTestId(TestIds.animalsListItem(3)));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupDetailScreen), findsOneWidget);
    expect(textOfTestId(tester, TestIds.groupDetailTitleText), 'Goat herd');
  });
}
