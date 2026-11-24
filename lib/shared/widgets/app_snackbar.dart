import 'package:material_ui/material_ui.dart';

import '../testing/test_id_wrapper.dart';
import '../testing/test_ids.dart';

/// The one snackbar style used everywhere in Harvestly.
class AppSnackbar {
  const AppSnackbar._();

  /// Shows a short message at the bottom of the screen.
  static void show(BuildContext context, String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: TestId(TestIds.appSnackbarText, child: Text(message)),
      ),
    );
  }
}
