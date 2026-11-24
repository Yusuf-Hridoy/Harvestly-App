import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/app/harvestly_app.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/features/login/login_controller.dart';
import 'package:harvestly/features/settings/theme_controller.dart';
import 'package:harvestly/shared/app_info/app_version_reader.dart';
import 'package:harvestly/shared/session/session_store.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The controllers a pumped test app is built from, so a test can read them.
class TestAppParts {
  const TestAppParts({
    required this.login,
    required this.theme,
    required this.prefs,
  });

  final LoginController login;
  final ThemeController theme;
  final SharedPreferences prefs;
}

/// Starts Harvestly inside a test, the same way main.dart does.
///
/// Pass [startAccount] to begin already logged in.
Future<TestAppParts> pumpHarvestlyApp(
  WidgetTester tester, {
  DemoAccount? startAccount,
  Map<String, Object> savedSettings = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(savedSettings);

  // A tall phone-sized screen, so a whole screen is built in one go.
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final LoginController login = LoginController(
    SessionStore(prefs),
    startAccount: startAccount,
  );
  final ThemeController theme = ThemeController(prefs);

  await tester.pumpWidget(
    HarvestlyApp(
      loginController: login,
      themeController: theme,
      appVersion: const AppVersion(name: '0.1.0', code: '1'),
    ),
  );
  await tester.pumpAndSettle();

  return TestAppParts(login: login, theme: theme, prefs: prefs);
}
