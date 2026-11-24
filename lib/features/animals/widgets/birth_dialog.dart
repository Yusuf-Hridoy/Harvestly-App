import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// What a finished birth dialog hands back.
class BirthResult {
  const BirthResult({required this.young, required this.bornOn});

  /// How many were born. Zero means none survived.
  final int young;

  final DateTime bornOn;
}

/// Records a birth: how many young, and the day they came.
class BirthDialog extends StatefulWidget {
  const BirthDialog({super.key, required this.matedOn});

  /// The mating date, which is as far back as the birth date may go.
  final DateTime matedOn;

  static const int maxYoung = 5;

  static const String emptyError = 'Please enter a number.';
  static const String rangeError = 'Use a whole number from 0 to 5.';

  /// Checks the typed number. Returns the error text, or null when it fits.
  static String? check(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return emptyError;
    final int? number = int.tryParse(value);
    if (number == null || number < 0 || number > maxYoung) return rangeError;
    return null;
  }

  /// Shows the dialog and returns the birth, or null when it is cancelled.
  static Future<BirthResult?> show(
    BuildContext context, {
    required DateTime matedOn,
  }) {
    return showDialog<BirthResult>(
      context: context,
      builder: (BuildContext dialogContext) => BirthDialog(matedOn: matedOn),
    );
  }

  @override
  State<BirthDialog> createState() => _BirthDialogState();
}

class _BirthDialogState extends State<BirthDialog> {
  final TextEditingController _young = TextEditingController();

  late DateTime _bornOn = AppClock.today();
  String? _error;

  @override
  void dispose() {
    _young.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _bornOn,
      firstDate: AppClock.dateOnly(widget.matedOn),
      lastDate: AppClock.today(),
      helpText: 'Birth date',
    );
    if (picked != null && mounted) {
      setState(() => _bornOn = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String? error = BirthDialog.check(_young.text);
    setState(() => _error = error);
    if (error != null) return;
    Navigator.of(
      context,
    ).pop(BirthResult(young: int.parse(_young.text.trim()), bornOn: _bornOn));
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.birthDialog,
      container: true,
      child: AlertDialog(
        title: const Text('Record birth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.birthDialogYoungInput,
              child: TextField(
                controller: _young,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: const InputDecoration(labelText: 'Number of young'),
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
                  TestIds.birthDialogYoungErrorText,
                  child: Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(color: colors.error),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TestId(
              TestIds.birthDialogDateInput,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(DateText.dayMonthYear(_bornOn)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TestId(
            TestIds.birthDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.birthDialogSaveButton,
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
