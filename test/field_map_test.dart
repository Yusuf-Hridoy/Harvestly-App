import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/fields/widgets/field_map.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/testing/test_ids.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Pinch and corner dragging cannot be driven through `adb shell input`,
/// which has no second finger, so the zoom rules are checked here instead.
void main() {
  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  /// Logs in as the farmer and opens Field 2, which has the drawn shape.
  Future<void> openFieldTwo(WidgetTester tester) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);
    await tester.tap(byTestId(TestIds.tabFieldsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Field 2 · South bed'));
    await tester.pumpAndSettle();
  }

  /// The middle of a corner handle on screen.
  Offset cornerCentre(WidgetTester tester, int number) =>
      tester.getCenter(byTestId(TestIds.fieldMapCorner(number)));

  /// Pinches outwards around the middle of the map to zoom in.
  Future<void> pinchOut(WidgetTester tester, double by) async {
    final Offset middle = tester.getCenter(byTestId(TestIds.fieldMapCanvas));
    const Offset gap = Offset(40, 0);
    final TestGesture left = await tester.startGesture(middle - gap);
    final TestGesture right = await tester.startGesture(middle + gap);
    await tester.pump();
    for (int step = 1; step <= 10; step++) {
      await left.moveTo(middle - gap * (1 + (by - 1) * step / 10));
      await right.moveTo(middle + gap * (1 + (by - 1) * step / 10));
      await tester.pump();
    }
    await left.up();
    await right.up();
    await tester.pumpAndSettle();
  }

  testWidgets('the map starts at 1.0x with no reset button', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);

    expect(textOfTestId(tester, TestIds.fieldMapZoomText), '1.0×');
    expect(byTestId(TestIds.fieldMapResetZoomButton), findsNothing);
    expect(textOfTestId(tester, TestIds.fieldMapAreaText), 'Area ≈ 0.40 acre');
  });

  testWidgets('all four corner handles are at least 44 by 44', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);

    for (int i = 1; i <= 4; i++) {
      final Size size = tester.getSize(byTestId(TestIds.fieldMapCorner(i)));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
  });

  testWidgets('dragging a corner changes the area and shows the buttons', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);

    expect(byTestId(TestIds.fieldMapSaveShapeButton), findsNothing);

    await tester.dragFrom(cornerCentre(tester, 1), const Offset(-30, -20));
    await tester.pumpAndSettle();

    expect(
      textOfTestId(tester, TestIds.fieldMapAreaText),
      isNot('Area ≈ 0.40 acre'),
    );
    expect(byTestId(TestIds.fieldMapSaveShapeButton), findsOneWidget);
    expect(byTestId(TestIds.fieldMapUndoShapeButton), findsOneWidget);
  });

  testWidgets('Undo puts the saved shape back, Save keeps the new one', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);

    await tester.dragFrom(cornerCentre(tester, 1), const Offset(-30, -20));
    await tester.pumpAndSettle();
    final String changed = textOfTestId(tester, TestIds.fieldMapAreaText);

    await tester.tap(byTestId(TestIds.fieldMapUndoShapeButton));
    await tester.pumpAndSettle();
    expect(textOfTestId(tester, TestIds.fieldMapAreaText), 'Area ≈ 0.40 acre');
    expect(byTestId(TestIds.fieldMapSaveShapeButton), findsNothing);

    await tester.dragFrom(cornerCentre(tester, 1), const Offset(-30, -20));
    await tester.pumpAndSettle();
    await tester.tap(byTestId(TestIds.fieldMapSaveShapeButton));
    await tester.pumpAndSettle();

    expect(find.text('Shape saved.'), findsOneWidget);
    expect(byTestId(TestIds.fieldMapSaveShapeButton), findsNothing);
    expect(textOfTestId(tester, TestIds.fieldMapAreaText), changed);
  });

  testWidgets('a corner never leaves the map box', (WidgetTester tester) async {
    await openFieldTwo(tester);
    final Rect box = tester.getRect(byTestId(TestIds.fieldMapCanvas));

    await tester.dragFrom(cornerCentre(tester, 1), const Offset(-900, -900));
    await tester.pumpAndSettle();

    final Offset corner = cornerCentre(tester, 1);
    expect(corner.dx, greaterThanOrEqualTo(box.left - 0.5));
    expect(corner.dy, greaterThanOrEqualTo(box.top - 0.5));
  });

  testWidgets('pinching zooms in, and Reset zoom goes back to 1.0x', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);

    await pinchOut(tester, 2.5);

    final String zoom = textOfTestId(tester, TestIds.fieldMapZoomText);
    expect(zoom, isNot('1.0×'));
    final double level = double.parse(zoom.replaceAll('×', ''));
    expect(level, greaterThan(1.0));
    expect(level, lessThanOrEqualTo(FieldMap.maxZoom));

    expect(byTestId(TestIds.fieldMapResetZoomButton), findsOneWidget);
    await tester.tap(byTestId(TestIds.fieldMapResetZoomButton));
    await tester.pumpAndSettle();

    expect(textOfTestId(tester, TestIds.fieldMapZoomText), '1.0×');
    expect(byTestId(TestIds.fieldMapResetZoomButton), findsNothing);
  });

  testWidgets('the zoom never goes past 3.0x', (WidgetTester tester) async {
    await openFieldTwo(tester);

    await pinchOut(tester, 8);

    expect(textOfTestId(tester, TestIds.fieldMapZoomText), '3.0×');
  });

  testWidgets('a corner still drags while the map is zoomed in', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);
    await pinchOut(tester, 2.5);
    expect(textOfTestId(tester, TestIds.fieldMapZoomText), isNot('1.0×'));

    // Zoomed in, the corners sit outside the box, so pan the view until one
    // is back on screen. One finger on empty space pans; one finger on a
    // handle drags that corner.
    final Rect box = tester.getRect(byTestId(TestIds.fieldMapCanvas));
    await tester.dragFrom(box.center, const Offset(260, 140));
    await tester.pumpAndSettle();
    expect(box.contains(cornerCentre(tester, 1)), isTrue);

    final String before = textOfTestId(tester, TestIds.fieldMapAreaText);
    await tester.dragFrom(cornerCentre(tester, 1), const Offset(40, 30));
    await tester.pumpAndSettle();

    expect(textOfTestId(tester, TestIds.fieldMapAreaText), isNot(before));
    expect(byTestId(TestIds.fieldMapSaveShapeButton), findsOneWidget);
    // The zoom is untouched by the corner drag.
    expect(textOfTestId(tester, TestIds.fieldMapZoomText), isNot('1.0×'));
  });

  testWidgets('leaving with an unsaved shape asks first', (
    WidgetTester tester,
  ) async {
    await openFieldTwo(tester);
    await tester.dragFrom(cornerCentre(tester, 1), const Offset(-30, -20));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.discardDialog), findsOneWidget);
    await tester.tap(byTestId(TestIds.discardDialogDiscardButton));
    await tester.pumpAndSettle();

    expect(byTestId(TestIds.fieldsScreen), findsOneWidget);
  });
}
