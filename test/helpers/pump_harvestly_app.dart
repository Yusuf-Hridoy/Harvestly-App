import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/app/harvestly_app.dart';
import 'package:harvestly/data/demo_accounts.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/features/login/login_controller.dart';
import 'package:harvestly/features/settings/theme_controller.dart';
import 'package:harvestly/notifications/notification_service.dart';
import 'package:harvestly/shared/app_info/app_version_reader.dart';
import 'package:harvestly/shared/session/session_store.dart';
import 'package:harvestly/shared/testing/test_id_wrapper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_notifications.dart';

/// The controllers a pumped test app is built from, so a test can read them.
class TestAppParts {
  const TestAppParts({
    required this.login,
    required this.theme,
    required this.farm,
    required this.prefs,
    required this.notifications,
    required this.plugin,
    required this.settings,
  });

  final LoginController login;
  final ThemeController theme;
  final FarmRepository farm;
  final SharedPreferences prefs;

  /// The real service, driving a fake plugin.
  final NotificationService notifications;

  /// What the app asked Android to do.
  final FakeNotificationPlugin plugin;

  /// The pretend Android version and settings page.
  final FakeSettingsChannel settings;
}

/// Starts Harvestly inside a test, the same way main.dart does.
///
/// Pass [startAccount] to begin already logged in.
Future<TestAppParts> pumpHarvestlyApp(
  WidgetTester tester, {
  DemoAccount? startAccount,
  Map<String, Object> savedSettings = const <String, Object>{},
  bool notificationsAllowed = true,
  bool grantOnRequest = true,
  int androidVersion = 33,
}) async {
  SharedPreferences.setMockInitialValues(savedSettings);

  // A tall phone-sized screen, so a whole screen is built in one go.
  // Home grew another card in Phase 4, so the window grew with it.
  tester.view.physicalSize = const Size(1200, 5200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final LoginController login = LoginController(
    SessionStore(prefs),
    startAccount: startAccount,
  );
  final ThemeController theme = ThemeController(prefs);
  final FarmRepository farm = FarmRepository(prefs);

  final FakeNotificationPlugin plugin = FakeNotificationPlugin()
    ..enabled = notificationsAllowed
    ..grantOnRequest = grantOnRequest;
  final FakeSettingsChannel settings = FakeSettingsChannel(
    version: androidVersion,
  );
  final NotificationService notifications = NotificationService(
    plugin: plugin,
    prefs: prefs,
    settings: settings,
  );
  await notifications.start();

  await tester.pumpWidget(
    HarvestlyApp(
      loginController: login,
      themeController: theme,
      farmRepository: farm,
      notifications: notifications,
      appVersion: const AppVersion(name: '0.2.0', code: '2'),
    ),
  );
  await tester.pumpAndSettle();

  return TestAppParts(
    login: login,
    theme: theme,
    farm: farm,
    prefs: prefs,
    notifications: notifications,
    plugin: plugin,
    settings: settings,
  );
}

/// Finds the widget carrying a test ID, the same ID Appium uses on Android.
Finder byTestId(String id) => find.byWidgetPredicate(
  (Widget widget) => widget is TestId && widget.id == id,
);

/// The text inside the widget carrying a test ID.
String textOfTestId(WidgetTester tester, String id) => tester
    .widget<Text>(
      find.descendant(of: byTestId(id), matching: find.byType(Text)),
    )
    .data!;
