import 'package:material_ui/material_ui.dart';

import '../testing/test_id_wrapper.dart';
import '../testing/test_ids.dart';

/// The one snackbar style used everywhere in Harvestly.
class AppSnackbar {
  const AppSnackbar._();

  /// Shows a short message at the bottom of the screen.
  static void show(BuildContext context, String message) =>
      showOn(ScaffoldMessenger.of(context), message);

  /// Shows the message on a messenger that was read earlier.
  ///
  /// Use this when the screen navigates away in the same step, because by
  /// then its own context may be gone.
  static void showOn(ScaffoldMessengerState messenger, String message) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: TestId(TestIds.appSnackbarText, child: Text(message)),
      ),
    );
  }
}
