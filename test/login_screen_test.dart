import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/login/login_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_harvestly_app.dart';

/// Reads what is currently typed in the email or password field.
String _fieldText(WidgetTester tester, int index) {
  final TextField field = tester.widget<TextField>(
    find.byType(TextField).at(index),
  );
  return field.controller!.text;
}

Future<void> _tapLogIn(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
  await tester.pump();
}

void main() {
  testWidgets('empty email shows a message', (WidgetTester tester) async {
    await pumpHarvestlyApp(tester);

    await _tapLogIn(tester);

    expect(find.text(LoginController.emailEmptyError), findsOneWidget);
  });

  testWidgets('a badly formed email shows a message', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextField).at(1), DemoAccounts.password);
    await _tapLogIn(tester);

    expect(find.text(LoginController.emailFormatError), findsOneWidget);
  });

  testWidgets('empty password shows a message', (WidgetTester tester) async {
    await pumpHarvestlyApp(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      DemoAccounts.farmer.email,
    );
    await _tapLogIn(tester);

    expect(find.text(LoginController.passwordEmptyError), findsOneWidget);
  });

  testWidgets('a field error goes away as soon as the user types', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await _tapLogIn(tester);
    expect(find.text(LoginController.emailEmptyError), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'f');
    await tester.pump();

    expect(find.text(LoginController.emailEmptyError), findsNothing);
  });

  testWidgets('a wrong password shows the banner', (WidgetTester tester) async {
    await pumpHarvestlyApp(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      DemoAccounts.farmer.email,
    );
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await _tapLogIn(tester);

    // The button shows a spinner during the 800 ms fake network wait.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(LoginController.fakeNetworkWait);
    await tester.pumpAndSettle();

    expect(find.text(LoginController.wrongDetailsError), findsOneWidget);
  });

  testWidgets('each Use button fills that account and the password', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    final List<DemoAccount> accounts = DemoAccounts.all;
    for (int i = 0; i < accounts.length; i++) {
      await tester.tap(find.widgetWithText(OutlinedButton, 'Use').at(i));
      await tester.pump();

      expect(_fieldText(tester, 0), accounts[i].email);
      expect(_fieldText(tester, 1), DemoAccounts.password);
    }
  });

  testWidgets('a Use button does not log the user in by itself', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Use').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });

  testWidgets('correct details reach the home screen', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      DemoAccounts.farmer.email,
    );
    await tester.enterText(find.byType(TextField).at(1), DemoAccounts.password);
    await _tapLogIn(tester);
    await tester.pump(LoginController.fakeNetworkWait);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Log in'), findsNothing);
    expect(find.text("Today's tasks"), findsOneWidget);
  });

  testWidgets('the email match ignores case and outer spaces', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      '  FARMER@Harvestly.TEST  ',
    );
    await tester.enterText(find.byType(TextField).at(1), DemoAccounts.password);
    await _tapLogIn(tester);
    await tester.pump(LoginController.fakeNetworkWait);
    await tester.pumpAndSettle();

    expect(find.text("Today's tasks"), findsOneWidget);
  });

  testWidgets('Forgot password shows the later phase message', (
    WidgetTester tester,
  ) async {
    await pumpHarvestlyApp(tester);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Password reset comes in a later phase.'), findsOneWidget);
  });
}
