import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/animals/group_form_screen.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens Add animal group.
  Future<void> openAddForm(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.animalsAddButton));
    await tester.pumpAndSettle();
  }

  /// Opens Edit animal group for the first group, Flock A.
  Future<void> openEditForm(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabAnimalsButton));
    await tester.pumpAndSettle();
    await tester.longPress(byTestId(TestIds.animalsListItem(1)));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupMenuEditOption));
    await tester.pumpAndSettle();
  }

  testWidgets('the add form opens empty, with no type picked', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    expect(
      textOfTestId(tester, TestIds.groupFormTitleText),
      'Add animal group',
    );
    expect(byTestId(TestIds.groupFormTypeHelpText), findsNothing);
    expect(byTestId(TestIds.groupFormTypeLockedText), findsNothing);
    expect(byTestId(TestIds.groupFormDeleteButton), findsNothing);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('24 Nov 2026'), findsOneWidget);
  });

  testWidgets('saving an empty form shows every error at once', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormCountInput), '');
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.groupFormNameErrorText),
      GroupFormScreen.nameEmptyError,
    );
    expect(
      textOfTestId(tester, TestIds.groupFormTypeErrorText),
      GroupFormScreen.typeEmptyError,
    );
    expect(
      textOfTestId(tester, TestIds.groupFormCountErrorText),
      GroupFormScreen.countEmptyError,
    );
  });

  testWidgets('a one-letter name is too short', (WidgetTester tester) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'A');
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.groupFormNameErrorText),
      GroupFormScreen.nameLengthError,
    );
  });

  testWidgets('a name another group already uses is refused', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'flock a');
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.groupFormNameErrorText),
      GroupFormScreen.nameTakenError,
    );
  });

  testWidgets('an error clears as soon as that input changes', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.groupFormNameErrorText), findsOneWidget);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Flock B');
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.groupFormNameErrorText), findsNothing);
    // The other errors stay until their own input changes.
    expect(byTestId(TestIds.groupFormTypeErrorText), findsOneWidget);

    await tester.tap(byTestId(TestIds.groupFormTypeQuailChip));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.groupFormTypeErrorText), findsNothing);
  });

  testWidgets('the help line follows the kind that is picked', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.tap(byTestId(TestIds.groupFormTypeDucksChip));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.groupFormTypeHelpText),
      'Birds track eggs, hatching and health.',
    );

    await tester.tap(byTestId(TestIds.groupFormTypeGoatsChip));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.groupFormTypeHelpText),
      'Goats and cows track milk, breeding and health.',
    );
  });

  testWidgets('the count steps between 1 and 9,999', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.tap(byTestId(TestIds.groupFormCountPlusButton));
    await tester.pumpAndSettle();
    expect(find.text('11'), findsOneWidget);

    await tester.enterText(byTestId(TestIds.groupFormCountInput), '1');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: byTestId(TestIds.groupFormCountMinusButton),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(byTestId(TestIds.groupFormCountInput), '9999');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: byTestId(TestIds.groupFormCountPlusButton),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('a count of 0 is refused', (WidgetTester tester) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Flock B');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupFormTypeHensChip));
    await tester.pumpAndSettle();
    await tester.enterText(byTestId(TestIds.groupFormCountInput), '0');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.groupFormCountErrorText),
      GroupFormScreen.countRangeError,
    );
  });

  testWidgets('a full form adds the group and opens its detail', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Quail pen');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupFormTypeQuailChip));
    await tester.pumpAndSettle();
    await tester.enterText(byTestId(TestIds.groupFormCountInput), '40');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupDetailScreen), findsOneWidget);
    expect(textOfTestId(tester, TestIds.groupDetailTitleText), 'Quail pen');
    expect(
      textOfTestId(tester, TestIds.groupDetailInfoText),
      'Quail · 40 birds · since 24 Nov 2026',
    );
    expect(find.text('Group added.'), findsOneWidget);
    // A new flock gets the flock tabs.
    expect(byTestId(TestIds.groupTabEggs), findsOneWidget);
    expect(byTestId(TestIds.groupTabHatching), findsOneWidget);
  });

  testWidgets('the edit form starts filled in and locks the type', (
    WidgetTester tester,
  ) async {
    await openEditForm(tester);

    expect(
      textOfTestId(tester, TestIds.groupFormTitleText),
      'Edit animal group',
    );
    expect(find.text('Flock A'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.groupFormTypeLockedText),
      GroupFormScreen.lockedTypeText,
    );

    // Tapping another chip changes nothing.
    await tester.tap(byTestId(TestIds.groupFormTypeCowsChip));
    await tester.pumpAndSettle();
    expect(
      textOfTestId(tester, TestIds.groupFormTypeHelpText),
      'Birds track eggs, hatching and health.',
    );
  });

  testWidgets('editing saves the new name and count', (
    WidgetTester tester,
  ) async {
    await openEditForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Flock One');
    await tester.pumpAndSettle();
    await tester.enterText(byTestId(TestIds.groupFormCountInput), '30');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupDetailScreen), findsOneWidget);
    expect(textOfTestId(tester, TestIds.groupDetailTitleText), 'Flock One');
    expect(
      textOfTestId(tester, TestIds.groupDetailInfoText),
      'Hens · 30 birds · since 1 Feb 2026',
    );
    expect(find.text('Group updated.'), findsOneWidget);
  });

  testWidgets('a group keeps its own name when it is edited', (
    WidgetTester tester,
  ) async {
    await openEditForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Flock A');
    await tester.tap(byTestId(TestIds.groupFormSaveButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.groupFormNameErrorText), findsNothing);
    expect(byTestId(TestIds.groupDetailScreen), findsOneWidget);
  });

  testWidgets('leaving with changes asks first', (WidgetTester tester) async {
    await openAddForm(tester);

    await tester.enterText(byTestId(TestIds.groupFormNameInput), 'Flock B');
    await tester.tap(byTestId(TestIds.groupFormCancelButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsOneWidget);

    await tester.tap(byTestId(TestIds.discardDialogKeepButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.groupFormScreen), findsOneWidget);

    await tester.tap(byTestId(TestIds.groupFormCancelButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.discardDialogDiscardButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.animalsScreen), findsOneWidget);
  });

  testWidgets('leaving an untouched form asks nothing', (
    WidgetTester tester,
  ) async {
    await openAddForm(tester);

    await tester.tap(byTestId(TestIds.groupFormCancelButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsNothing);
    expect(byTestId(TestIds.animalsScreen), findsOneWidget);
  });

  testWidgets('Delete group on the edit form asks, then goes to the list', (
    WidgetTester tester,
  ) async {
    await openEditForm(tester);

    await tester.tap(byTestId(TestIds.groupFormDeleteButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.deleteGroupDialog), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.deleteGroupDialogMessageText),
      "Flock A and all its records will be removed. You can't undo this.",
    );

    await tester.tap(byTestId(TestIds.deleteGroupDialogConfirmButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.animalsScreen), findsOneWidget);
    expect(find.text('Group deleted.'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
  });
}
