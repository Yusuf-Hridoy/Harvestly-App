import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Asks how many eggs hatched when a batch is finished.
///
/// It works on any day, because eggs do hatch early.
class HatchResultDialog extends StatefulWidget {
  const HatchResultDialog({super.key, required this.eggs});

  /// How many eggs were set, which is the largest answer allowed.
  final int eggs;

  static const String emptyError = 'Please enter a number.';

  /// "Use a whole number from 0 to 10.", with the batch's own egg count.
  static String rangeError(int eggs) => 'Use a whole number from 0 to $eggs.';

  /// Checks the typed number. Returns the error text, or null when it fits.
  static String? check(String raw, int eggs) {
    final String value = raw.trim();
    if (value.isEmpty) return emptyError;
    final int? number = int.tryParse(value);
    if (number == null || number < 0 || number > eggs) {
      return rangeError(eggs);
    }
    return null;
  }

  /// Shows the dialog and returns how many hatched, or null when cancelled.
  static Future<int?> show(BuildContext context, {required int eggs}) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => HatchResultDialog(eggs: eggs),
    );
  }

  @override
  State<HatchResultDialog> createState() => _HatchResultDialogState();
}

class _HatchResultDialogState extends State<HatchResultDialog> {
  final TextEditingController _hatched = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _hatched.dispose();
    super.dispose();
  }

  void _save() {
    final String? error = HatchResultDialog.check(_hatched.text, widget.eggs);
    setState(() => _error = error);
    if (error != null) return;
    Navigator.of(context).pop(int.parse(_hatched.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.hatchResultDialog,
      container: true,
      child: AlertDialog(
        title: const Text('How many hatched?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.hatchResultDialogInput,
              child: TextField(
                controller: _hatched,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(labelText: 'Out of ${widget.eggs}'),
                onChanged: (String _) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (String _) => _save(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TestId(
                  TestIds.hatchResultDialogErrorText,
                  child: Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(color: colors.error),
                  ),
                ),
              ),
          ],
        ),
        actions: <Widget>[
          TestId(
            TestIds.hatchResultDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.hatchResultDialogSaveButton,
            merge: true,
            child: TextButton(
              onPressed: _save,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  AppSizes.minTapTarget,
                  AppSizes.minTapTarget,
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
