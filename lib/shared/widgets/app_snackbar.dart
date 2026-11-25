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

  /// How long a snackbar with an action stays up.
  static const Duration undoWait = Duration(seconds: 5);

  /// Shows a message with one action button, such as Undo.
  ///
  /// It stays up for 5 seconds, which is long enough to read and tap.
  static void showAction(
    ScaffoldMessengerState messenger, {
    required String message,
    required String actionLabel,
    required String actionTestId,
    required VoidCallback onAction,
  }) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: undoWait,
        // The button is part of the content rather than the snackbar's own
        // action slot, because only a widget can carry a test ID.
        content: Row(
          children: <Widget>[
            Expanded(
              child: TestId(TestIds.appSnackbarText, child: Text(message)),
            ),
            TestId(
              actionTestId,
              merge: true,
              child: TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
