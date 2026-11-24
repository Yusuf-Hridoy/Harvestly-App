import 'package:material_ui/material_ui.dart';

import '../../app/app_colors.dart';
import '../../app/app_theme.dart';
import '../testing/test_id_wrapper.dart';

/// The one "are you sure?" dialog used everywhere in Harvestly.
///
/// Every confirm looks and behaves the same, and each place that uses it
/// passes its own test IDs so Appium can tell them apart.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.dialogTestId,
    required this.title,
    this.message,
    this.messageTestId,
    required this.cancelLabel,
    required this.cancelTestId,
    required this.confirmLabel,
    required this.confirmTestId,
    this.destructive = false,
  });

  /// The test ID of the whole dialog.
  final String dialogTestId;

  /// The question at the top, for example "Delete this field?".
  final String title;

  /// The line under the title. Null when the title says enough.
  final String? message;

  /// The test ID of the message line.
  ///
  /// Leave it out when the message needs no ID of its own. Reusing the
  /// dialog's ID here would put the same ID on two nodes, which breaks
  /// finding by ID.
  final String? messageTestId;

  final String cancelLabel;
  final String cancelTestId;
  final String confirmLabel;
  final String confirmTestId;

  /// Whether the confirm button should use the error color.
  final bool destructive;

  /// Shows the dialog and returns true only when the user confirms.
  static Future<bool> show(
    BuildContext context, {
    required String dialogTestId,
    required String title,
    String? message,
    String? messageTestId,
    required String cancelLabel,
    required String cancelTestId,
    required String confirmLabel,
    required String confirmTestId,
    bool destructive = false,
  }) async {
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmDialog(
        dialogTestId: dialogTestId,
        title: title,
        message: message,
        messageTestId: messageTestId,
        cancelLabel: cancelLabel,
        cancelTestId: cancelTestId,
        confirmLabel: confirmLabel,
        confirmTestId: confirmTestId,
        destructive: destructive,
      ),
    );
    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? text = message;
    final String? textId = messageTestId;

    Widget? content;
    if (text != null) {
      final Widget line = Text(text, style: textTheme.bodyMedium);
      content = textId == null ? line : TestId(textId, child: line);
    }

    return TestId(
      dialogTestId,
      container: true,
      child: AlertDialog(
        title: Text(title),
        content: content,
        actions: <Widget>[
          TestId(
            cancelTestId,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
          ),
          TestId(
            confirmTestId,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: destructive ? colors.error : colors.link,
                minimumSize: const Size(
                  AppSizes.minTapTarget,
                  AppSizes.minTapTarget,
                ),
              ),
              child: Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
