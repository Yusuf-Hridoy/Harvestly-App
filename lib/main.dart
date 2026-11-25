import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/harvestly_app.dart';
import 'data/demo_accounts.dart';
import 'data/farm_repository.dart';
import 'features/login/login_controller.dart';
import 'features/settings/theme_controller.dart';
import 'notifications/notification_actions.dart';
import 'notifications/notification_service.dart';
import 'shared/app_info/app_version_reader.dart';
import 'shared/session/session_store.dart';

/// Loads the saved settings, starts the notification plugin, then starts
/// Harvestly.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SessionStore sessionStore = SessionStore(prefs);
  final AppVersion appVersion = await AppVersionReader.load();

  final NotificationService notifications = NotificationService(
    plugin: LocalNotificationPlugin(
      // Android calls this on its own isolate when a reminder's button is
      // pressed while Harvestly is closed.
      backgroundHandler: onBackgroundNotificationResponse,
    ),
    prefs: prefs,
  );
  // Reminders are useful, but the farm data matters more: if the plugin
  // cannot start, Harvestly still opens and everything but notifications
  // works.
  try {
    await notifications.start();
  } catch (error) {
    debugPrint('Harvestly notifications: could not start ($error)');
  }

  final String? savedEmail = sessionStore.savedAccountEmail();
  final DemoAccount? savedAccount = savedEmail == null
      ? null
      : DemoAccounts.findByEmail(savedEmail);

  runApp(
    HarvestlyApp(
      loginController: LoginController(
        sessionStore,
        startAccount: savedAccount,
      ),
      themeController: ThemeController(prefs),
      farmRepository: FarmRepository(prefs),
      notifications: notifications,
      appVersion: appVersion,
    ),
  );
}
