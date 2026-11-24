import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The rules for typing an eggs or a milk amount.
///
/// Eggs are whole numbers; milk takes one decimal. The two dialogs below and
/// the production tab all check an amount through this.
class AmountRules {
  const AmountRules({required this.isEggs, required this.max});

  /// The rules for an eggs amount, 0 to 9,999 whole.
  static const AmountRules eggs = AmountRules(isEggs: true, max: 9999);

  /// The rules for a milk amount, 0 to 9,999.5 litres.
  static const AmountRules milk = AmountRules(isEggs: false, max: 9999.5);

  final bool isEggs;

  /// The largest amount that can be saved.
  final double max;

  static const String emptyError = 'Please enter an amount.';
  static const String wholeNumberError = 'Use a whole number.';
  static const String decimalError = 'Use numbers only, like 12.5.';
  static const String rangeError = 'Use a number from 0 to 9,999.';

  /// What the input allows the user to type.
  List<TextInputFormatter> get formatters => <TextInputFormatter>[
    if (isEggs)
      FilteringTextInputFormatter.digitsOnly
    else
      // Numbers with one decimal, nothing else.
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
  ];

  /// Checks a typed amount. Returns the error text, or null when it is fine.
  String? check(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return emptyError;
    if (isEggs) {
      final int? whole = int.tryParse(value);
      if (whole == null) return wholeNumberError;
      if (whole < 0 || whole > max) return rangeError;
      return null;
    }
    final double? number = double.tryParse(value);
    if (number == null) return decimalError;
    if (number < 0 || number > max) return rangeError;
    return null;
  }

  /// "18" for eggs, "14.0" for milk.
  String value(double amount) =>
      isEggs ? '${amount.round()}' : amount.toStringAsFixed(1);

  /// "18 eggs", "1 egg" or "14.0 L".
  String withUnit(double amount) {
    if (!isEggs) return '${value(amount)} L';
    final int eggs = amount.round();
    return eggs == 1 ? '1 egg' : '$eggs eggs';
  }
}

/// Types today's amount, opened by tapping the big number.
class AmountDialog extends StatefulWidget {
  const AmountDialog({
    super.key,
    required this.rules,
    required this.title,
    required this.startAmount,
  });

  final AmountRules rules;

  /// "Eggs today" or "Milk today".
  final String title;

  /// What the box starts with.
  final double startAmount;

  /// Shows the dialog and returns the amount, or null when it is cancelled.
  static Future<double?> show(
    BuildContext context, {
    required AmountRules rules,
    required String title,
    required double startAmount,
  }) {
    return showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) =>
          AmountDialog(rules: rules, title: title, startAmount: startAmount),
    );
  }

  @override
  State<AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<AmountDialog> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.rules.value(widget.startAmount),
  );
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final String? error = widget.rules.check(_amount.text);
    setState(() => _error = error);
    if (error != null) return;
    Navigator.of(context).pop(double.parse(_amount.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.amountDialog,
      container: true,
      child: AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.amountDialogInput,
              child: TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: !widget.rules.isEggs,
                ),
                inputFormatters: widget.rules.formatters,
                decoration: InputDecoration(
                  labelText: widget.rules.isEggs ? 'Eggs' : 'Litres',
                ),
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
                  TestIds.amountDialogErrorText,
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
            TestIds.amountDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.amountDialogSaveButton,
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

/// One day's amount, picked by date. Used by Edit a past day.
class PastDayAmount {
  const PastDayAmount({required this.date, required this.amount});

  final DateTime date;
  final double amount;
}

/// Picks a past day and types the amount for it.
class PastDayDialog extends StatefulWidget {
  const PastDayDialog({super.key, required this.rules});

  final AmountRules rules;

  /// How far back a past day may go.
  static const int pastDaysAllowed = 365;

  /// Shows the dialog and returns the day and amount, or null when it is
  /// cancelled.
  static Future<PastDayAmount?> show(
    BuildContext context, {
    required AmountRules rules,
  }) {
    return showDialog<PastDayAmount>(
      context: context,
      builder: (BuildContext dialogContext) => PastDayDialog(rules: rules),
    );
  }

  @override
  State<PastDayDialog> createState() => _PastDayDialogState();
}

class _PastDayDialogState extends State<PastDayDialog> {
  final TextEditingController _amount = TextEditingController();

  /// Yesterday, because today is changed on the card itself.
  late DateTime _date = AppClock.today().subtract(const Duration(days: 1));
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime yesterday = AppClock.today().subtract(
      const Duration(days: 1),
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: AppClock.today().subtract(
        const Duration(days: PastDayDialog.pastDaysAllowed),
      ),
      lastDate: yesterday,
      helpText: 'Which day',
    );
    if (picked != null && mounted) {
      setState(() => _date = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String? error = widget.rules.check(_amount.text);
    setState(() => _error = error);
    if (error != null) return;
    Navigator.of(context).pop(
      PastDayAmount(date: _date, amount: double.parse(_amount.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.pastDayDialog,
      container: true,
      child: AlertDialog(
        title: const Text('Edit a past day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.pastDayDialogDateInput,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(DateText.dayMonthYear(_date)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TestId(
              TestIds.pastDayDialogAmountInput,
              child: TextField(
                controller: _amount,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: !widget.rules.isEggs,
                ),
                inputFormatters: widget.rules.formatters,
                decoration: InputDecoration(
                  labelText: widget.rules.isEggs ? 'Eggs' : 'Litres',
                ),
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
                  TestIds.pastDayDialogErrorText,
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
            TestIds.pastDayDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.pastDayDialogSaveButton,
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
