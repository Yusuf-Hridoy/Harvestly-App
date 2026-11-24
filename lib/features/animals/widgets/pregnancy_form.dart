import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/discard_changes.dart';

/// What a finished pregnancy form hands back.
class NewPregnancy {
  const NewPregnancy({required this.animalName, required this.matedOn});

  final String animalName;
  final DateTime matedOn;
}

/// Add a pregnancy: which animal, and when it was mated.
class PregnancyForm extends StatefulWidget {
  const PregnancyForm({super.key});

  /// How long a name or ear tag can be.
  static const int nameLimit = 20;

  /// How far back a mating date may go.
  static const int pastDaysAllowed = 365;

  static const String nameEmptyError = "Please enter the animal's name or tag.";
  static const String nameLengthError = 'Use up to 20 characters.';

  /// Opens the form and returns the new pregnancy, or null when it is left.
  static Future<NewPregnancy?> open(BuildContext context) {
    return Navigator.of(context).push<NewPregnancy>(
      MaterialPageRoute<NewPregnancy>(
        builder: (BuildContext _) => const PregnancyForm(),
      ),
    );
  }

  @override
  State<PregnancyForm> createState() => _PregnancyFormState();
}

class _PregnancyFormState extends State<PregnancyForm> {
  final TextEditingController _name = TextEditingController();

  late DateTime _matedOn = AppClock.today();
  String? _nameError;

  bool get _hasChanges => _name.text.isNotEmpty || _matedOn != AppClock.today();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _matedOn,
      firstDate: today.subtract(
        const Duration(days: PregnancyForm.pastDaysAllowed),
      ),
      lastDate: today,
      helpText: 'Mating date',
    );
    if (picked != null && mounted) {
      setState(() => _matedOn = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String value = _name.text.trim();
    final String? error = value.isEmpty
        ? PregnancyForm.nameEmptyError
        : (value.length > PregnancyForm.nameLimit
              ? PregnancyForm.nameLengthError
              : null);

    setState(() => _nameError = error);
    if (error != null) return;

    Navigator.of(context)
        .pop(NewPregnancy(animalName: value, matedOn: _matedOn));
  }

  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
          title: const Text('New pregnancy'),
        ),
        body: TestId(
          TestIds.pregnancyFormScreen,
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
                child: Text('Animal name or tag', style: textTheme.titleSmall),
              ),
              TestId(
                TestIds.pregnancyFormNameInput,
                child: TextField(
                  controller: _name,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(hintText: 'Lali'),
                  onChanged: (String _) => setState(() {
                    _nameError = null;
                  }),
                ),
              ),
              if (_nameError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 6, 0, 0),
                  child: TestId(
                    TestIds.pregnancyFormNameErrorText,
                    child: Text(
                      _nameError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
                child: Text('Mating date', style: textTheme.titleSmall),
              ),
              TestId(
                TestIds.pregnancyFormDateInput,
                merge: true,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(DateText.dayMonthYear(_matedOn)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TestId(
                TestIds.pregnancyFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save pregnancy'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.pregnancyFormCancelButton,
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
