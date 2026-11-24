import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// What a finished loss dialog hands back.
class LossEntry {
  const LossEntry({
    required this.amount,
    required this.reason,
    required this.date,
  });

  final int amount;
  final LossReason reason;
  final DateTime date;
}

/// Records animals that left the group, and why.
class LossDialog extends StatefulWidget {
  const LossDialog({super.key, required this.type, required this.count});

  final AnimalType type;

  /// How many animals the group has now, which is the largest loss allowed.
  final int count;

  /// How far back the date may go.
  static const int pastDaysAllowed = 365;

  static const String amountEmptyError = 'Please enter a number.';
  static const String amountWholeError = 'Use a whole number from 1.';
  static const String reasonEmptyError = 'Please pick a reason.';

  /// "You only have 24 birds." or "You only have 1 animal."
  static String tooManyError(AnimalType type, int count) =>
      'You only have ${type.countText(count)}.';

  /// Checks the typed amount. Returns the error text, or null when it fits.
  static String? checkAmount(String raw, AnimalType type, int count) {
    final String value = raw.trim();
    if (value.isEmpty) return amountEmptyError;
    final int? number = int.tryParse(value);
    if (number == null || number < 1) return amountWholeError;
    if (number > count) return tooManyError(type, count);
    return null;
  }

  /// Shows the dialog and returns the loss, or null when it is cancelled.
  static Future<LossEntry?> show(
    BuildContext context, {
    required AnimalType type,
    required int count,
  }) {
    return showDialog<LossEntry>(
      context: context,
      builder: (BuildContext dialogContext) =>
          LossDialog(type: type, count: count),
    );
  }

  @override
  State<LossDialog> createState() => _LossDialogState();
}

class _LossDialogState extends State<LossDialog> {
  final TextEditingController _amount = TextEditingController();

  LossReason? _reason;
  late DateTime _date = AppClock.today();
  String? _amountError;
  String? _reasonError;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickReason() async {
    final LossReason? picked = await LossReasonSheet.show(context, _reason);
    if (picked == null || !mounted) return;
    setState(() {
      _reason = picked;
      _reasonError = null;
    });
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today.subtract(
        const Duration(days: LossDialog.pastDaysAllowed),
      ),
      lastDate: today,
      helpText: 'When',
    );
    if (picked != null && mounted) {
      setState(() => _date = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String? amountError = LossDialog.checkAmount(
      _amount.text,
      widget.type,
      widget.count,
    );
    final String? reasonError = _reason == null
        ? LossDialog.reasonEmptyError
        : null;

    setState(() {
      _amountError = amountError;
      _reasonError = reasonError;
    });
    if (amountError != null || reasonError != null) return;

    Navigator.of(context).pop(
      LossEntry(
        amount: int.parse(_amount.text.trim()),
        reason: _reason!,
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.lossDialog,
      container: true,
      child: AlertDialog(
        title: const Text('Record loss'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TestId(
                TestIds.lossDialogAmountInput,
                child: TextField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(labelText: 'How many'),
                  onChanged: (String _) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                ),
              ),
              if (_amountError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TestId(
                    TestIds.lossDialogAmountErrorText,
                    child: Text(
                      _amountError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TestId(
                TestIds.lossDialogReasonPicker,
                merge: true,
                child: OutlinedButton(
                  onPressed: _pickReason,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _reason?.label ?? 'Pick a reason',
                          style: textTheme.bodyLarge?.copyWith(
                            color: _reason == null ? colors.textMuted : null,
                          ),
                        ),
                      ),
                      Icon(Icons.expand_more_rounded, color: colors.textMuted),
                    ],
                  ),
                ),
              ),
              if (_reasonError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TestId(
                    TestIds.lossDialogReasonErrorText,
                    child: Text(
                      _reasonError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TestId(
                TestIds.lossDialogDateInput,
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
            ],
          ),
        ),
        actions: <Widget>[
          TestId(
            TestIds.lossDialogCancelButton,
            merge: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          TestId(
            TestIds.lossDialogSaveButton,
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

/// The reason picker, built like the soil picker so every option is its own
/// clickable node in the Android UI tree.
class LossReasonSheet extends StatelessWidget {
  const LossReasonSheet({super.key, this.current});

  final LossReason? current;

  static const Map<LossReason, String> testIds = <LossReason, String>{
    LossReason.sickness: TestIds.lossDialogReasonOptionSickness,
    LossReason.predator: TestIds.lossDialogReasonOptionPredator,
    LossReason.accident: TestIds.lossDialogReasonOptionAccident,
    LossReason.sold: TestIds.lossDialogReasonOptionSold,
    LossReason.other: TestIds.lossDialogReasonOptionOther,
  };

  /// Shows the sheet and returns the reason picked, or null when it closes
  /// without one.
  static Future<LossReason?> show(BuildContext context, LossReason? current) {
    return showModalBottomSheet<LossReason>(
      context: context,
      builder: (BuildContext sheetContext) => LossReasonSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Reason',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final LossReason reason in LossReason.values)
            _ReasonOption(reason: reason, selected: reason == current),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({required this.reason, required this.selected});

  final LossReason reason;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return TestId(
      LossReasonSheet.testIds[reason]!,
      merge: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(reason),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  reason.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? colors.link : colors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
