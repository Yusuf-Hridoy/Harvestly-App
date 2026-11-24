import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/discard_changes.dart';

/// What a finished batch form hands back.
class NewBatch {
  const NewBatch({required this.startedOn, required this.eggs});

  final DateTime startedOn;
  final int eggs;
}

/// Start a hatch batch: when the eggs went in and how many.
///
/// It is a pushed screen, not a route, because it belongs to the Hatching
/// tab rather than to a place the user can link to.
class HatchBatchForm extends StatefulWidget {
  const HatchBatchForm({super.key});

  static const int minEggs = 1;
  static const int maxEggs = 500;
  static const int defaultEggs = 10;

  /// How far back a start date may go.
  static const int pastDaysAllowed = 60;

  static const String eggsEmptyError = 'Please enter the number of eggs.';
  static const String eggsRangeError = 'Use a whole number from 1 to 500.';

  /// Opens the form and returns the new batch, or null when it is left.
  static Future<NewBatch?> open(BuildContext context) {
    return Navigator.of(context).push<NewBatch>(
      MaterialPageRoute<NewBatch>(
        builder: (BuildContext _) => const HatchBatchForm(),
      ),
    );
  }

  @override
  State<HatchBatchForm> createState() => _HatchBatchFormState();
}

class _HatchBatchFormState extends State<HatchBatchForm> {
  final TextEditingController _eggs = TextEditingController(
    text: '${HatchBatchForm.defaultEggs}',
  );

  late DateTime _startedOn = AppClock.today();
  String? _eggsError;

  int? get _eggsNumber => int.tryParse(_eggs.text.trim());

  bool get _hasChanges =>
      _eggs.text != '${HatchBatchForm.defaultEggs}' ||
      _startedOn != AppClock.today();

  @override
  void dispose() {
    _eggs.dispose();
    super.dispose();
  }

  void _step(int by) {
    final int current = _eggsNumber ?? HatchBatchForm.defaultEggs;
    final int next = (current + by).clamp(
      HatchBatchForm.minEggs,
      HatchBatchForm.maxEggs,
    );
    setState(() {
      _eggs.text = '$next';
      _eggsError = null;
    });
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startedOn,
      firstDate: today.subtract(
        const Duration(days: HatchBatchForm.pastDaysAllowed),
      ),
      lastDate: today,
      helpText: 'Start date',
    );
    if (picked != null && mounted) {
      setState(() => _startedOn = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String raw = _eggs.text.trim();
    final int? eggs = _eggsNumber;
    final String? error = raw.isEmpty
        ? HatchBatchForm.eggsEmptyError
        : (eggs == null ||
              eggs < HatchBatchForm.minEggs ||
              eggs > HatchBatchForm.maxEggs)
        ? HatchBatchForm.eggsRangeError
        : null;

    setState(() => _eggsError = error);
    if (error != null) return;

    Navigator.of(context).pop(NewBatch(startedOn: _startedOn, eggs: eggs!));
  }

  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? eggs = _eggsNumber;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _leave,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('New batch'),
        ),
        body: TestId(
          TestIds.batchFormScreen,
          container: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              28,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
                child: Text('Start date', style: textTheme.titleSmall),
              ),
              TestId(
                TestIds.batchFormDateInput,
                merge: true,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(DateText.dayMonthYear(_startedOn)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
                child: Text('Number of eggs', style: textTheme.titleSmall),
              ),
              Row(
                children: <Widget>[
                  TestId(
                    TestIds.batchFormEggsMinusButton,
                    merge: true,
                    child: IconButton.outlined(
                      tooltip: 'One less egg',
                      onPressed: eggs != null && eggs > HatchBatchForm.minEggs
                          ? () => _step(-1)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TestId(
                      TestIds.batchFormEggsInput,
                      child: TextField(
                        controller: _eggs,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (String _) => setState(() {
                          _eggsError = null;
                        }),
                      ),
                    ),
                  ),
                  TestId(
                    TestIds.batchFormEggsPlusButton,
                    merge: true,
                    child: IconButton.outlined(
                      tooltip: 'One more egg',
                      onPressed: eggs != null && eggs < HatchBatchForm.maxEggs
                          ? () => _step(1)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
              if (_eggsError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 6, 0, 0),
                  child: TestId(
                    TestIds.batchFormEggsErrorText,
                    child: Text(
                      _eggsError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              TestId(
                TestIds.batchFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save batch'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.batchFormCancelButton,
                merge: true,
                child: OutlinedButton(
                  onPressed: _leave,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
