import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Opens the More tab, where the theme choice lives.
Future<void> _openMoreTab(WidgetTester tester) async {
  await tester.tap(find.text('More'));
  await tester.pumpAndSettle();
}

ThemeMode _themeModeOf(WidgetTester tester) {
  final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
  return app.themeMode!;
}

void main() {
  testWidgets('the default theme mode is System', (WidgetTester tester) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
    );

    expect(parts.theme.mode, ThemeMode.system);
    expect(_themeModeOf(tester), ThemeMode.system);
  });

  testWidgets('choosing Dark sets dark mode and saves it', (
    WidgetTester tester,
  ) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
    );

    await _openMoreTab(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(parts.theme.mode, ThemeMode.dark);
    expect(_themeModeOf(tester), ThemeMode.dark);
    expect(parts.prefs.getString('settings_theme_mode'), 'dark');
  });

  testWidgets('choosing Light sets light mode and saves it', (
    WidgetTester tester,
  ) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
    );

    await _openMoreTab(tester);
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(parts.theme.mode, ThemeMode.light);
    expect(parts.prefs.getString('settings_theme_mode'), 'light');
  });

  testWidgets('the saved choice is loaded on the next app start', (
    WidgetTester tester,
  ) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
      savedSettings: const <String, Object>{'settings_theme_mode': 'dark'},
    );

    expect(parts.theme.mode, ThemeMode.dark);
    expect(_themeModeOf(tester), ThemeMode.dark);
  });

  testWidgets('the theme choice stays after logging out', (
    WidgetTester tester,
  ) async {
    final TestAppParts parts = await pumpHarvestlyApp(
      tester,
      startAccount: DemoAccounts.farmer,
      savedSettings: const <String, Object>{'settings_theme_mode': 'dark'},
    );

    await _openMoreTab(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    expect(parts.theme.mode, ThemeMode.dark);
    expect(parts.prefs.getString('settings_theme_mode'), 'dark');
  });

  testWidgets('Cancel in the log out dialog keeps the user logged in', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester, startAccount: DemoAccounts.farmer);

    await _openMoreTab(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Log out of Harvestly?'), findsNothing);
    expect(find.text(DemoAccounts.farmer.email), findsOneWidget);
  });
}
