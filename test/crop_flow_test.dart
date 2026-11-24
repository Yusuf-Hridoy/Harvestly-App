import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/crops/crop_form_screen.dart';
import 'package:harvestly/features/crops/widgets/harvest_dialog.dart';
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

  /// Opens one field's detail screen by its name.
  Future<void> openField(WidgetTester tester, String name) async {
    await openFields(tester);
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  /// Opens Add crop inside Field 4, which starts with no crops.
  Future<void> openAddCrop(WidgetTester tester) async {
    await openField(tester, 'Field 4 · Pond side');
    await tester.tap(byTestId(TestIds.fieldDetailAddCropButton));
    await tester.pumpAndSettle();
  }

  /// Searches for a crop, then taps it.
  ///
  /// The catalog list is long and lazy, so a crop near the bottom is not
  /// built until the search narrows the list, which is what a real test on a
  /// phone has to do too.
  Future<void> pickCrop(
    WidgetTester tester,
    String typeId,
    String search,
  ) async {
    await tester.enterText(byTestId(TestIds.cropFormSearchInput), search);
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.cropFormCropOption(typeId)));
    await tester.pumpAndSettle();
  }

  group('add crop', () {
    testWidgets('the whole catalog shows, and search narrows it', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);

      expect(byTestId(TestIds.cropFormScreen), findsOneWidget);
      expect(find.text('Add crop to Field 4 · Pond side'), findsOneWidget);
      expect(textOfTestId(tester, TestIds.cropFormResultCountText), '40 crops');

      await tester.enterText(byTestId(TestIds.cropFormSearchInput), 'bean');
      await tester.pumpAndSettle();

      // Bush beans and Long beans.
      expect(textOfTestId(tester, TestIds.cropFormResultCountText), '2 of 40');
      expect(
        byTestId(TestIds.cropFormCropOption('bush_beans')),
        findsOneWidget,
      );
      expect(byTestId(TestIds.cropFormCropOption('tomato')), findsNothing);
    });

    testWidgets('a search with no match shows the message', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);
      await tester.enterText(byTestId(TestIds.cropFormSearchInput), 'banana');
      await tester.pumpAndSettle();

      expect(find.text('No crops match.'), findsOneWidget);
      expect(textOfTestId(tester, TestIds.cropFormResultCountText), '0 of 40');
    });

    testWidgets('searching does not clear the chosen crop', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);
      await tester.enterText(byTestId(TestIds.cropFormSearchInput), 'tomato');
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.cropFormCropOption('tomato')));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.cropFormHarvestEstimateText), findsOneWidget);

      await tester.enterText(byTestId(TestIds.cropFormSearchInput), 'kale');
      await tester.pumpAndSettle();

      // The estimate is still there, so the choice survived the search.
      expect(byTestId(TestIds.cropFormHarvestEstimateText), findsOneWidget);
    });

    testWidgets('Save with no crop picked shows the error', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);
      await tester.tap(byTestId(TestIds.cropFormSaveButton));
      await tester.pumpAndSettle();

      expect(find.text(CropFormScreen.noCropError), findsOneWidget);
    });

    testWidgets('the plant buttons stop at 1 and at 9,999', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);

      await tester.enterText(byTestId(TestIds.cropFormPlantsInput), '1');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.descendant(
                of: byTestId(TestIds.cropFormPlantsMinusButton),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.enterText(byTestId(TestIds.cropFormPlantsInput), '9999');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.descendant(
                of: byTestId(TestIds.cropFormPlantsPlusButton),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('an empty plants box shows its own error', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);
      await pickCrop(tester, 'kale', 'kale');
      await tester.enterText(byTestId(TestIds.cropFormPlantsInput), '');
      await tester.tap(byTestId(TestIds.cropFormSaveButton));
      await tester.pumpAndSettle();

      expect(find.text(CropFormScreen.plantsEmptyError), findsOneWidget);
    });

    testWidgets('the harvest estimate follows the crop that is picked', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);

      await pickCrop(tester, 'radish', 'radish');
      // Radish takes 30 days from 24 Nov 2026.
      expect(
        textOfTestId(tester, TestIds.cropFormHarvestEstimateText),
        'Harvest around 24 Dec 2026',
      );

      await pickCrop(tester, 'tomato', 'tomato');
      // Tomato takes 65 days.
      expect(
        textOfTestId(tester, TestIds.cropFormHarvestEstimateText),
        'Harvest around 28 Jan 2027',
      );
    });

    testWidgets('adding a crop updates Field detail and Home', (
      WidgetTester tester,
    ) async {
      await openAddCrop(tester);
      await pickCrop(tester, 'kale', 'kale');
      await tester.enterText(byTestId(TestIds.cropFormPlantsInput), '40');
      await tester.tap(byTestId(TestIds.cropFormSaveButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.fieldDetailScreen), findsOneWidget);
      expect(find.text('Kale added to Field 4 · Pond side.'), findsOneWidget);
      expect(textOfTestId(tester, TestIds.fieldDetailCropItemName(1)), 'Kale');

      await tester.tap(byTestId(TestIds.tabHomeButton));
      await tester.pumpAndSettle();

      // 7 sample crops plus the new one.
      expect(
        find.descendant(
          of: byTestId(TestIds.homeStatCropsCard),
          matching: find.text('8'),
        ),
        findsOneWidget,
      );
    });
  });

  group('crop detail', () {
    /// Opens the Tomato crop in Field 2.
    Future<void> openTomato(WidgetTester tester) async {
      await openField(tester, 'Field 2 · South bed');
      await tester.tap(byTestId(TestIds.fieldDetailCropItemName(1)));
      await tester.pumpAndSettle();
    }

    testWidgets('it shows the stage, the days left and the key dates', (
      WidgetTester tester,
    ) async {
      await openTomato(tester);

      expect(byTestId(TestIds.cropDetailScreen), findsOneWidget);
      expect(
        textOfTestId(tester, TestIds.cropDetailDaysLeftText),
        '12 days left',
      );
      expect(textOfTestId(tester, TestIds.cropDetailPlantsText), '40');
      expect(textOfTestId(tester, TestIds.cropDetailDaysToGrowText), '65');
      expect(
        textOfTestId(tester, TestIds.cropDetailHarvestDateText),
        '6 Dec 2026',
      );
      expect(find.text('Flowering'), findsWidgets);
    });

    testWidgets('mark as harvested checks the amount, then moves the crop', (
      WidgetTester tester,
    ) async {
      await openTomato(tester);
      await tester.tap(byTestId(TestIds.cropDetailHarvestButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.harvestDialog), findsOneWidget);

      await tester.tap(byTestId(TestIds.harvestDialogSaveButton));
      await tester.pumpAndSettle();
      expect(find.text(HarvestDialog.emptyError), findsOneWidget);

      await tester.enterText(byTestId(TestIds.harvestDialogAmountInput), '0');
      await tester.tap(byTestId(TestIds.harvestDialogSaveButton));
      await tester.pumpAndSettle();
      expect(find.text(HarvestDialog.tooSmallError), findsOneWidget);

      await tester.enterText(
        byTestId(TestIds.harvestDialogAmountInput),
        '18.5',
      );
      await tester.tap(byTestId(TestIds.harvestDialogSaveButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.fieldDetailScreen), findsOneWidget);
      expect(find.text('Tomato marked as harvested.'), findsOneWidget);
      expect(byTestId(TestIds.fieldDetailPastHarvestsSection), findsOneWidget);
      expect(find.text('Tomato · 24 Nov 2026 · 18.50 kg'), findsOneWidget);
      // Only the Green chili is left in the field.
      expect(
        textOfTestId(tester, TestIds.fieldDetailCropItemName(1)),
        'Green chili',
      );
    });

    testWidgets('delete crop asks first and adds nothing to past harvests', (
      WidgetTester tester,
    ) async {
      await openTomato(tester);
      await tester.tap(byTestId(TestIds.cropDetailDeleteButton));
      await tester.pumpAndSettle();

      expect(byTestId(TestIds.deleteCropDialog), findsOneWidget);
      expect(
        find.text(
          'Tomato in Field 2 · South bed will be removed. '
          'You can\'t undo this.',
        ),
        findsOneWidget,
      );

      await tester.tap(byTestId(TestIds.deleteCropDialogCancelButton));
      await tester.pumpAndSettle();
      expect(byTestId(TestIds.cropDetailScreen), findsOneWidget);

      await tester.tap(byTestId(TestIds.cropDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(byTestId(TestIds.deleteCropDialogConfirmButton));
      await tester.pumpAndSettle();

      expect(find.text('Crop deleted.'), findsOneWidget);
      expect(byTestId(TestIds.fieldDetailPastHarvestsSection), findsNothing);
      expect(
        textOfTestId(tester, TestIds.fieldDetailCropItemName(1)),
        'Green chili',
      );
    });
  });

  testWidgets('delete field warns when the field has crops', (
    WidgetTester tester,
  ) async {
    await openField(tester, 'Field 2 · South bed');
    await tester.tap(byTestId(TestIds.fieldDetailDeleteButton));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This field has 2 crops. Deleting it removes them too. '
        'You can\'t undo this.',
      ),
      findsOneWidget,
    );

    await tester.tap(byTestId(TestIds.deleteFieldDialogConfirmButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.fieldsScreen), findsOneWidget);
    expect(find.text('Field deleted.'), findsOneWidget);
    expect(find.text('3 fields'), findsOneWidget);
  });

  testWidgets('the Harvest soon card on Home opens that crop', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    expect(byTestId(TestIds.homeHarvestCard), findsOneWidget);
    expect(find.text('Tomato · Field 2 · South bed'), findsOneWidget);

    await tester.tap(find.text('Tomato · Field 2 · South bed'));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.cropDetailScreen), findsOneWidget);
    expect(
      textOfTestId(tester, TestIds.cropDetailDaysLeftText),
      '12 days left',
    );
  });

  testWidgets('Reset demo data puts the farmer sample back', (
    WidgetTester tester,
  ) async {
    await openField(tester, 'Field 2 · South bed');
    await tester.tap(byTestId(TestIds.fieldDetailDeleteButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.deleteFieldDialogConfirmButton));
    await tester.pumpAndSettle();
    expect(find.text('3 fields'), findsOneWidget);

    await tester.tap(byTestId(TestIds.tabMoreButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.settingsResetDataButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.resetDataDialog), findsOneWidget);
    await tester.tap(byTestId(TestIds.resetDataDialogConfirmButton));
    await tester.pumpAndSettle();

    expect(find.text('Demo data reset.'), findsOneWidget);
    expect(byTestId(TestIds.settingsScreen), findsOneWidget);

    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();
    expect(find.text('4 fields'), findsOneWidget);
  });

  testWidgets('the new account leaves the welcome card after its first field', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.newFarm);
    expect(byTestId(TestIds.homeEmptyFarmCard), findsOneWidget);

    await tester.tap(byTestId(TestIds.homeEmptyAddFieldButton));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldsEmptyAddButton));
    await tester.pumpAndSettle();

    await tester.enterText(byTestId(TestIds.fieldFormNameInput), 'Home patch');
    await tester.enterText(byTestId(TestIds.fieldFormSizeInput), '0.2');
    await tester.tap(byTestId(TestIds.fieldFormSoilDropdown));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldFormSoilOptionLoam));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldFormSaveButton));
    await tester.pumpAndSettle();

    await tester.tap(byTestId(TestIds.tabHomeButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.homeEmptyFarmCard), findsNothing);
    expect(byTestId(TestIds.homeWeatherCard), findsOneWidget);
    expect(find.text('No tasks for today.'), findsOneWidget);
    expect(
      find.descendant(
        of: byTestId(TestIds.homeStatFieldsCard),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(find.text('Tk 0'), findsOneWidget);
  });
}
