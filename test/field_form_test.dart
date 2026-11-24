import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/fields/field_form_screen.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer, opens Fields and taps the + button.
  Future<void> openAddField(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsAddButton));
    await tester.pumpAndSettle();
  }

  /// Logs in as the farmer and opens Edit field for Field 2.
  Future<void> openEditField(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Field 2 · South bed'));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldMenuEditOption));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(byTestId(TestIds.fieldFormSaveButton));
    await tester.pumpAndSettle();
  }

  Future<void> pickSoil(WidgetTester tester, String soilOptionId) async {
    await tester.tap(byTestId(TestIds.fieldFormSoilDropdown));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(soilOptionId));
    await tester.pumpAndSettle();
  }

  testWidgets('Add field opens an empty form with the right title', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);

    expect(byTestId(TestIds.fieldFormScreen), findsOneWidget);
    expect(find.text('Add field'), findsOneWidget);
    expect(find.text('Pick a soil type'), findsOneWidget);
    expect(textOfTestId(tester, TestIds.fieldFormNoteCounterText), '0/120');
  });

  testWidgets('Save with an empty form shows every error at once', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tapSave(tester);

    expect(find.text(FieldFormScreen.nameEmptyError), findsOneWidget);
    expect(find.text(FieldFormScreen.sizeEmptyError), findsOneWidget);
    expect(find.text(FieldFormScreen.soilEmptyError), findsOneWidget);
  });

  testWidgets('a one letter name shows the length error', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.enterText(byTestId(TestIds.fieldFormNameInput), 'A');
    await tapSave(tester);

    expect(find.text(FieldFormScreen.nameLengthError), findsOneWidget);
  });

  testWidgets('a name already used shows the taken error, ignoring case', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.enterText(
      byTestId(TestIds.fieldFormNameInput),
      'field 2 · SOUTH bed',
    );
    await tapSave(tester);

    expect(find.text(FieldFormScreen.nameTakenError), findsOneWidget);
  });

  testWidgets('editing a field may keep its own name', (
    WidgetTester tester,
  ) async {
    await openEditField(tester);

    expect(find.text('Edit field'), findsOneWidget);
    // The name is already in the box, so saving must not call it taken.
    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), '0.45');
    await tapSave(tester);

    expect(find.text(FieldFormScreen.nameTakenError), findsNothing);
    expect(find.text('Field updated.'), findsOneWidget);
  });

  testWidgets('every size error shows for the wrong input', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.enterText(byTestId(TestIds.fieldFormNameInput), 'West plot');

    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), '0');
    await tapSave(tester);
    expect(find.text(FieldFormScreen.sizeTooSmallError), findsOneWidget);

    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), '1000.01');
    await tapSave(tester);
    expect(find.text(FieldFormScreen.sizeTooBigError), findsOneWidget);
  });

  testWidgets('the size box refuses letters, so the format error is for an '
      'empty number', (WidgetTester tester) async {
    await openAddField(tester);
    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), 'abc');
    await tester.pumpAndSettle();

    // The input formatter throws the letters away before they are shown.
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '',
    );
    await tapSave(tester);
    expect(find.text(FieldFormScreen.sizeEmptyError), findsOneWidget);
  });

  testWidgets('an error clears as soon as that input changes', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tapSave(tester);
    expect(find.text(FieldFormScreen.nameEmptyError), findsOneWidget);

    await tester.enterText(byTestId(TestIds.fieldFormNameInput), 'W');
    await tester.pumpAndSettle();

    expect(find.text(FieldFormScreen.nameEmptyError), findsNothing);
    // The other errors stay until Save is tapped again.
    expect(find.text(FieldFormScreen.sizeEmptyError), findsOneWidget);
  });

  testWidgets('the note counter follows what is typed and stops at 120', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);

    await tester.enterText(
      byTestId(TestIds.fieldFormNoteInput),
      'Near the gate',
    );
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.fieldFormNoteCounterText), '13/120');

    await tester.enterText(byTestId(TestIds.fieldFormNoteInput), 'x' * 200);
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.fieldFormNoteCounterText), '120/120');
  });

  testWidgets('a full form adds the field and opens its detail screen', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.enterText(
      byTestId(TestIds.fieldFormNameInput),
      'Field 5 · West plot',
    );
    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), '0.25');
    await pickSoil(tester, TestIds.fieldFormSoilOptionSandy);
    await tapSave(tester);

    expect(byTestId(TestIds.fieldDetailScreen), findsOneWidget);
    expect(find.text('Field added.'), findsOneWidget);
    expect(find.text('0.25 acre · Sandy'), findsOneWidget);
  });

  testWidgets('Cancel with no changes leaves without asking', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.tap(byTestId(TestIds.fieldFormCancelButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsNothing);
    expect(byTestId(TestIds.fieldsScreen), findsOneWidget);
  });

  testWidgets('Cancel after a change asks before leaving', (
    WidgetTester tester,
  ) async {
    await openAddField(tester);
    await tester.enterText(byTestId(TestIds.fieldFormNameInput), 'West plot');
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldFormCancelButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsOneWidget);
    expect(find.text('Discard your changes?'), findsOneWidget);

    await tester.tap(byTestId(TestIds.discardDialogKeepButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.fieldFormScreen), findsOneWidget);

    await tester.tap(byTestId(TestIds.fieldFormCancelButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.discardDialogDiscardButton));
    await tester.pumpAndSettle();
    expect(byTestId(TestIds.fieldsScreen), findsOneWidget);
  });
}
