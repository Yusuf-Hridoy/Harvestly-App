import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens the Fields tab.
  Future<void> openFields(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();
  }

  /// The names of the field cards, in the order they are on screen.
  List<String> shownFieldNames(WidgetTester tester) {
    final List<String> names = <String>[];
    for (int i = 1; i <= 10; i++) {
      final Finder finder = byTestId(TestIds.fieldsListItemName(i));
      if (finder.evaluate().isEmpty) break;
      names.add(
        tester
            .widget<Text>(
              find.descendant(of: finder, matching: find.byType(Text)),
            )
            .data!,
      );
    }
    return names;
  }

  testWidgets('the farmer sees all four fields', (WidgetTester tester) async {
    await openFields(tester);

    expect(byTestId(TestIds.fieldsScreen), findsOneWidget);
    expect(shownFieldNames(tester), <String>[
      'Field 1 · North plot',
      'Field 2 · South bed',
      'Field 3 · Bean rows',
      'Field 4 · Pond side',
    ]);
    expect(find.text('4 fields'), findsOneWidget);
  });

  testWidgets('the chips show the right counts', (WidgetTester tester) async {
    await openFields(tester);

    expect(find.text('All 4'), findsOneWidget);
    expect(find.text('Growing 3'), findsOneWidget);
    expect(find.text('Empty 1'), findsOneWidget);
    expect(find.text('Harvest soon 1'), findsOneWidget);
  });

  testWidgets('each filter shows only its own fields', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    await tester.tap(byTestId(TestIds.fieldsFilterGrowingChip));
    await tester.pumpAndSettle();
    expect(shownFieldNames(tester).length, 3);
    expect(find.text('3 fields'), findsOneWidget);

    await tester.tap(byTestId(TestIds.fieldsFilterEmptyChip));
    await tester.pumpAndSettle();
    expect(shownFieldNames(tester), <String>['Field 4 · Pond side']);
    expect(find.text('1 field'), findsOneWidget);

    await tester.tap(byTestId(TestIds.fieldsFilterHarvestSoonChip));
    await tester.pumpAndSettle();
    expect(shownFieldNames(tester), <String>['Field 2 · South bed']);
  });

  testWidgets('search matches part of a name, ignoring case', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    await tester.enterText(byTestId(TestIds.fieldsSearchInput), 'BEAN');
    await tester.pumpAndSettle();

    expect(shownFieldNames(tester), <String>['Field 3 · Bean rows']);
    expect(find.text('1 field'), findsOneWidget);
    // The chip counts follow the search text.
    expect(find.text('All 1'), findsOneWidget);
    expect(find.text('Empty 0'), findsOneWidget);
  });

  testWidgets('search and filter work together', (WidgetTester tester) async {
    await openFields(tester);

    await tester.enterText(byTestId(TestIds.fieldsSearchInput), 'field');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsFilterEmptyChip));
    await tester.pumpAndSettle();

    expect(shownFieldNames(tester), <String>['Field 4 · Pond side']);
  });

  testWidgets('no match shows the message, and Clear brings everything back', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    await tester.enterText(byTestId(TestIds.fieldsSearchInput), 'orchard');
    await tester.pumpAndSettle();

    expect(find.text('No fields match.'), findsOneWidget);
    expect(find.text('0 fields'), findsOneWidget);

    await tester.tap(byTestId(TestIds.fieldsNoResultsClearButton));
    await tester.pumpAndSettle();

    expect(shownFieldNames(tester).length, 4);
    expect(find.text('All 4'), findsOneWidget);
  });

  testWidgets('the search clear button empties the box', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    await tester.enterText(byTestId(TestIds.fieldsSearchInput), 'bean');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsSearchClearButton));
    await tester.pumpAndSettle();

    expect(shownFieldNames(tester).length, 4);
  });

  testWidgets('all three sort orders put the fields in the right order', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    expect(find.text('Sort: Name'), findsOneWidget);
    expect(shownFieldNames(tester), <String>[
      'Field 1 · North plot',
      'Field 2 · South bed',
      'Field 3 · Bean rows',
      'Field 4 · Pond side',
    ]);

    await tester.tap(byTestId(TestIds.fieldsSortButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsSortSizeOption));
    await tester.pumpAndSettle();

    expect(find.text('Sort: Size'), findsOneWidget);
    expect(shownFieldNames(tester), <String>[
      'Field 1 · North plot',
      'Field 4 · Pond side',
      'Field 2 · South bed',
      'Field 3 · Bean rows',
    ]);

    await tester.tap(byTestId(TestIds.fieldsSortButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsSortHarvestOption));
    await tester.pumpAndSettle();

    expect(find.text('Sort: Harvest date'), findsOneWidget);
    // Fields with no crops go to the end.
    expect(shownFieldNames(tester), <String>[
      'Field 2 · South bed',
      'Field 1 · North plot',
      'Field 3 · Bean rows',
      'Field 4 · Pond side',
    ]);
  });

  testWidgets('long press opens the field menu', (WidgetTester tester) async {
    await openFields(tester);

    await tester.longPress(find.text('Field 1 · North plot'));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.fieldMenuSheet), findsOneWidget);
    expect(find.text('Edit field'), findsOneWidget);
    expect(find.text('Delete field'), findsOneWidget);
  });

  testWidgets('Delete in the long-press menu asks first, then deletes', (
    WidgetTester tester,
  ) async {
    await openFields(tester);

    await tester.longPress(find.text('Field 4 · Pond side'));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldMenuDeleteOption));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.deleteFieldDialog), findsOneWidget);
    expect(
      find.text('Field 4 · Pond side will be removed. You can\'t undo this.'),
      findsOneWidget,
    );

    await tester.tap(byTestId(TestIds.deleteFieldDialogConfirmButton));
    await tester.pumpAndSettle();

    expect(shownFieldNames(tester).length, 3);
    expect(find.text('Field deleted.'), findsOneWidget);
  });

  testWidgets('an account with no fields shows the empty state', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.newFarm);
    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.fieldsEmptyState), findsOneWidget);
    expect(find.text('No fields yet'), findsOneWidget);
    expect(
      find.text('Add your first field to start tracking crops.'),
      findsOneWidget,
    );
    expect(byTestId(TestIds.fieldsEmptyAddButton), findsOneWidget);
  });
}
