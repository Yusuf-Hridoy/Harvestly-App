import 'package:material_ui/material_ui.dart';

import '../testing/test_ids.dart';
import 'confirm_dialog.dart';

/// The "Discard your changes?" question, used by every form in Harvestly.
class DiscardChanges {
  const DiscardChanges._();

  /// Asks the user, and returns true only when they choose Discard.
  static Future<bool> confirm(BuildContext context) => ConfirmDialog.show(
    context,
    dialogTestId: TestIds.discardDialog,
    title: 'Discard your changes?',
    cancelLabel: 'Keep editing',
    cancelTestId: TestIds.discardDialogKeepButton,
    confirmLabel: 'Discard',
    confirmTestId: TestIds.discardDialogDiscardButton,
    destructive: true,
  );
}
