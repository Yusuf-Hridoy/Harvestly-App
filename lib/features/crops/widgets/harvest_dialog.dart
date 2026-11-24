import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Asks how much was picked when a crop is marked as harvested.
///
/// It works at any stage, because people do harvest early.
class HarvestDialog extends StatefulWidget {
  const HarvestDialog({super.key});

  /// The largest amount that can be typed, in kilograms.
  static const double maxKg = 100000;

  static const String emptyError = 'Please enter the amount.';
  static const String formatError = 'Use numbers only, like 12.5.';
  static const String tooSmallError = 'Amount must be more than 0.';
  static const String tooBigError = 'Amount must be 100,000 kg or less.';

  /// Shows the dialog and returns the amount in kilograms, or null when the
  /// user cancels.
  static Future<double?> show(BuildContext context) {
    return showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) => const HarvestDialog(),
    );
  }

  /// Checks the typed amount. Returns the error text, or null when it is fine.
  static String? checkAmount(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return emptyError;
    final double? number = double.tryParse(value);
    if (number == null) return formatError;
    if (number <= 0) return tooSmallError;
    if (number > maxKg) return tooBigError;
    return null;
  }

  @override
  State<HarvestDialog> createState() => _HarvestDialogState();
}

class _HarvestDialogState extends State<HarvestDialog> {
  final TextEditingController _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final String? error = HarvestDialog.checkAmount(_amount.text);
    setState(() => _error = error);
    if (error != null) return;
    Navigator.of(context).pop(double.parse(_amount.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.harvestDialog,
      container: true,
      child: AlertDialog(
        title: const Text('How much did you harvest?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.harvestDialogAmountInput,
              child: TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  // Numbers with up to 2 decimals, nothing else.
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(labelText: 'Amount (kg)'),
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
                  TestIds.harvestDialogAmountErrorText,
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
            TestIds.harvestDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.harvestDialogSaveButton,
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
