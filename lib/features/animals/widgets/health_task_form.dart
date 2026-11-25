import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/discard_changes.dart';

/// What a finished health task form hands back.
class NewHealthTask {
  const NewHealthTask({required this.title, required this.dueOn});

  final String title;
  final DateTime dueOn;
}

/// Add a health task: what to do and when it is due.
///
/// A past due date is allowed on purpose, because that is how a late task
/// gets into the list.
class HealthTaskForm extends StatefulWidget {
  const HealthTaskForm({super.key});

  /// How far the due date may go back and forward.
  static const int daysAllowed = 365;

  static const String titleEmptyError = 'Please enter a task name.';
  static const String titleLengthError = 'Use 2 to 40 characters.';

  /// Opens the form and returns the new task, or null when it is left.
  static Future<NewHealthTask?> open(BuildContext context) {
    return Navigator.of(context).push<NewHealthTask>(
      MaterialPageRoute<NewHealthTask>(
        builder: (BuildContext _) => const HealthTaskForm(),
      ),
    );
  }

  @override
  State<HealthTaskForm> createState() => _HealthTaskFormState();
}

class _HealthTaskFormState extends State<HealthTaskForm> {
  final TextEditingController _title = TextEditingController();

  late DateTime _dueOn = AppClock.today();
  String? _titleError;

  bool get _hasChanges => _title.text.isNotEmpty || _dueOn != AppClock.today();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueOn,
      firstDate: today.subtract(
        const Duration(days: HealthTaskForm.daysAllowed),
      ),
      lastDate: today.add(const Duration(days: HealthTaskForm.daysAllowed)),
      helpText: 'Due date',
    );
    if (picked != null && mounted) {
      setState(() => _dueOn = AppClock.dateOnly(picked));
    }
  }

  void _save() {
    final String value = _title.text.trim();
    final String? error = value.isEmpty
        ? HealthTaskForm.titleEmptyError
        : (value.length < 2 || value.length > 40
              ? HealthTaskForm.titleLengthError
              : null);

    setState(() => _titleError = error);
    if (error != null) return;

    Navigator.of(context).pop(NewHealthTask(title: value, dueOn: _dueOn));
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
          title: const Text('Add health task'),
        ),
        body: TestId(
          TestIds.healthTaskFormScreen,
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
                child: Text('Task name', style: textTheme.titleSmall),
              ),
              TestId(
                TestIds.healthTaskFormTitleInput,
                child: TextField(
                  controller: _title,
                  textInputAction: TextInputAction.done,
                  maxLength: 40,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(
                    hintText: 'Newcastle booster',
                  ),
                  onChanged: (String _) => setState(() {
                    _titleError = null;
                  }),
                ),
              ),
              if (_titleError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 6, 0, 0),
                  child: TestId(
                    TestIds.healthTaskFormTitleErrorText,
                    child: Text(
                      _titleError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
                child: Text('Due date', style: textTheme.titleSmall),
              ),
              TestId(
                TestIds.healthTaskFormDateInput,
                merge: true,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(DateText.dayMonthYear(_dueOn)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TestId(
                TestIds.healthTaskFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save task'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.healthTaskFormCancelButton,
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

  /// Hides Flutter's own counter.
  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}
