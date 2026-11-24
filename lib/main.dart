import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/harvestly_app.dart';
import 'data/demo_accounts.dart';
import 'features/login/login_controller.dart';
import 'features/settings/theme_controller.dart';
import 'shared/app_info/app_version_reader.dart';
import 'shared/session/session_store.dart';

/// Loads the saved settings, then starts Harvestly.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SessionStore sessionStore = SessionStore(prefs);
  final AppVersion appVersion = await AppVersionReader.load();

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
      appVersion: appVersion,
    ),
  );
}
