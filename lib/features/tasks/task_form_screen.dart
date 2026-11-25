import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/farm_repository.dart';
import '../../data/task_models.dart';
import '../../data/task_rules.dart';
import '../../notifications/notification_service.dart';
import '../../shared/logic/app_clock.dart';
import '../../shared/logic/date_text.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/discard_changes.dart';
import 'widgets/link_picker_sheet.dart';
import 'widgets/reminder_explainer_sheet.dart';

/// Add task and Edit task. One screen does both.
///
/// When [taskId] is null the form is empty and Save adds a new task.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  /// How far the date picker reaches, each way.
  static const int daysEitherWay = 365;

  /// The time a new task starts with.
  static const TimeOfDay defaultTime = TimeOfDay(hour: 9, minute: 0);

  static const int minTitle = 2;
  static const int maxTitle = 60;
  static const int maxNote = 200;

  static const String nameEmptyError = 'Please enter a task.';
  static const String nameLengthError = 'Use 2 to 60 characters.';
  static const String reminderPastError =
      'This reminder time has already passed.';

  /// Shown when the task was kept but no reminder could be booked.
  static const String remindersOffMessage = 'Task saved. Reminders are off.';

  /// The line under the reminder chips.
  static String reminderLineFor(DateTime at) =>
      'Reminder on ${DateText.weekdayDayMonth(at)} at '
      '${DateText.timeOfDay(at)}';

  /// Walks the permission flow and returns whether reminders can show.
  ///
  /// Shared with Settings, so both places ask in the same order: the
  /// explainer first, then Android's own pop-up, and never a pop-up twice.
  static Future<bool> askForNotifications(BuildContext context) async {
    final NotificationService service = context.read<NotificationService>();
    final FarmRepository repository = context.read<FarmRepository>();

    final NotificationPermission state = await service.permission();
    switch (state) {
      case NotificationPermission.allowed:
        return true;
      case NotificationPermission.off:
        // Already refused, or turned off in Android's settings. Android
        // would not show the pop-up again, so nothing is asked.
        return false;
      case NotificationPermission.notAsked:
        break;
    }

    if (!context.mounted) return false;
    final bool carryOn = await ReminderExplainerSheet.show(context);
    if (!carryOn) return false;

    final bool allowed = await service.requestPermission();
    // The save happened while notifications were still off, so the
    // reminders have to be booked now.
    if (allowed) repository.refreshReminders();
    return allowed;
  }

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _note = TextEditingController();

  late DateTime _date = AppClock.today();
  TimeOfDay _time = TaskFormScreen.defaultTime;
  Repeat _repeat = Repeat.none;
  TaskLink? _link;
  ReminderOffset _reminder = ReminderOffset.none;

  String? _nameError;
  String? _reminderError;

  String _startName = '';
  String _startNote = '';
  late DateTime _startDate = AppClock.today();
  TimeOfDay _startTime = TaskFormScreen.defaultTime;
  Repeat _startRepeat = Repeat.none;
  TaskLink? _startLink;
  ReminderOffset _startReminder = ReminderOffset.none;
  bool _loaded = false;

  bool get _isEdit => widget.taskId != null;

  /// The date and time together, which is what the task is saved with.
  DateTime get _dueAt =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  /// When the reminder would show, or null when there is none.
  DateTime? get _reminderAt {
    final Duration? before = _reminder.before;
    if (before == null) return null;
    return _dueAt.subtract(before);
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Fills the form from the task being edited, once.
  void _loadOnce(FarmRepository repository) {
    if (_loaded) return;
    _loaded = true;
    final String? id = widget.taskId;
    if (id == null) return;
    final FarmTask? task = repository.taskById(id);
    if (task == null) return;

    _name.text = task.title;
    _note.text = task.note;
    _date = AppClock.dateOnly(task.dueAt);
    _time = TimeOfDay(hour: task.dueAt.hour, minute: task.dueAt.minute);
    _repeat = task.repeat;
    _link = task.link;
    _reminder = task.reminder;

    _startName = _name.text;
    _startNote = _note.text;
    _startDate = _date;
    _startTime = _time;
    _startRepeat = _repeat;
    _startLink = _link;
    _startReminder = _reminder;
  }

  bool get _hasChanges =>
      _name.text != _startName ||
      _note.text != _startNote ||
      _date != _startDate ||
      _time != _startTime ||
      _repeat != _startRepeat ||
      _link != _startLink ||
      _reminder != _startReminder;

  String? _checkName() {
    final String value = _name.text.trim();
    if (value.isEmpty) return TaskFormScreen.nameEmptyError;
    if (value.length < TaskFormScreen.minTitle ||
        value.length > TaskFormScreen.maxTitle) {
      return TaskFormScreen.nameLengthError;
    }
    return null;
  }

  String? _checkReminder() {
    final DateTime? at = _reminderAt;
    if (at == null) return null;
    if (at.isAfter(AppClock.now())) return null;
    return TaskFormScreen.reminderPastError;
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today.subtract(
        const Duration(days: TaskFormScreen.daysEitherWay),
      ),
      lastDate: today.add(const Duration(days: TaskFormScreen.daysEitherWay)),
      helpText: 'Due date',
    );
    if (picked != null && mounted) {
      setState(() {
        _date = AppClock.dateOnly(picked);
        _reminderError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Due time',
    );
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
        _reminderError = null;
      });
    }
  }

  Future<void> _pickLink(FarmRepository repository) async {
    final LinkChoice? choice = await LinkPickerSheet.show(
      context,
      fields: repository.fields,
      groups: repository.animals,
      chosen: _link,
    );
    if (choice == null || !mounted) return;
    setState(() => _link = choice.link);
  }

  Future<void> _save() async {
    final String? nameError = _checkName();
    final String? reminderError = _checkReminder();
    setState(() {
      _nameError = nameError;
      _reminderError = reminderError;
    });
    if (nameError != null || reminderError != null) return;

    final FarmRepository repository = context.read<FarmRepository>();
    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String title = _name.text.trim();
    final String note = _note.text.trim();
    final String? editId = widget.taskId;

    String message;
    String goTo;
    if (editId == null) {
      final FarmTask added = await repository.addTask(
        title: title,
        note: note,
        dueAt: _dueAt,
        repeat: _repeat,
        link: _link,
        reminder: _reminder,
      );
      message = 'Task added.';
      goTo = AppRoutes.taskDetail(added.id);
    } else {
      await repository.editTask(
        taskId: editId,
        title: title,
        note: note,
        dueAt: _dueAt,
        repeat: _repeat,
        link: _link,
        reminder: _reminder,
      );
      message = 'Task updated.';
      goTo = AppRoutes.taskDetail(editId);
    }

    // The task is always kept, whatever the user says to Android.
    if (_reminder.isOn && mounted) {
      final bool booked = await TaskFormScreen.askForNotifications(context);
      if (!booked) message = TaskFormScreen.remindersOffMessage;
    }

    router.go(goTo);
    AppSnackbar.showOn(messenger, message);
  }

  /// Leaves the screen, asking first when something was changed.
  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (!mounted) return;
    final String? id = widget.taskId;
    context.go(id == null ? AppRoutes.tasks : AppRoutes.taskDetail(id));
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    _loadOnce(repository);

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String title = _isEdit ? 'Edit task' : 'Add task';
    final DateTime? reminderAt = _reminderAt;

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
          title: TestId(TestIds.taskFormTitleText, child: Text(title)),
        ),
        body: TestId(
          TestIds.taskFormScreen,
          container: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              28,
            ),
            children: <Widget>[
              const _Label(text: 'Task'),
              TestId(
                TestIds.taskFormNameInput,
                child: TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  maxLength: TaskFormScreen.maxTitle,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(
                    hintText: 'Water tomato beds',
                  ),
                  onChanged: (String _) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ),
              _ErrorLine(
                testId: TestIds.taskFormNameErrorText,
                message: _nameError,
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Note'),
              TestId(
                TestIds.taskFormNoteInput,
                child: TextField(
                  controller: _note,
                  maxLines: 3,
                  maxLength: TaskFormScreen.maxNote,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(
                    hintText: 'Anything worth remembering',
                  ),
                  onChanged: (String _) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 4, 0, 0),
                child: TestId(
                  TestIds.taskFormNoteCounterText,
                  child: Text(
                    '${_note.text.characters.length} / '
                    '${TaskFormScreen.maxNote}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _Label(text: 'Due date'),
                        TestId(
                          TestIds.taskFormDateInput,
                          merge: true,
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                            label: Text(DateText.dayMonth(_date)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _Label(text: 'Time'),
                        TestId(
                          TestIds.taskFormTimeInput,
                          merge: true,
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.schedule_outlined, size: 18),
                            label: Text(
                              DateText.timeOfDay(
                                DateTime(2026, 1, 1, _time.hour, _time.minute),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Repeat'),
              _ChipRow<Repeat>(
                values: Repeat.values,
                selected: _repeat,
                labelOf: (Repeat value) => value.label,
                testIdOf: (Repeat value) => _repeatIds[value]!,
                onPick: (Repeat value) => setState(() => _repeat = value),
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Linked to'),
              TestId(
                TestIds.taskFormLinkInput,
                merge: true,
                child: OutlinedButton(
                  onPressed: () => _pickLink(repository),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    alignment: Alignment.centerLeft,
                  ),
                  child: _LinkLabel(
                    name: _link == null
                        ? TaskRules.generalName
                        : repository.linkNameFor(
                            FarmTask(
                              id: '',
                              title: '',
                              dueAt: _dueAt,
                              link: _link,
                            ),
                          ),
                    tag: _link?.kind.tag,
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Reminder'),
              _ChipRow<ReminderOffset>(
                values: ReminderOffset.values,
                selected: _reminder,
                labelOf: (ReminderOffset value) => value.label,
                testIdOf: (ReminderOffset value) => _reminderIds[value]!,
                onPick: (ReminderOffset value) => setState(() {
                  _reminder = value;
                  _reminderError = null;
                }),
              ),
              if (reminderAt != null) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondarySoft,
                    borderRadius: BorderRadius.circular(AppSizes.controlRadius),
                  ),
                  child: TestId(
                    TestIds.taskFormReminderLineText,
                    child: Text(
                      TaskFormScreen.reminderLineFor(reminderAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSecondarySoft,
                      ),
                    ),
                  ),
                ),
              ],
              _ErrorLine(
                testId: TestIds.taskFormReminderErrorText,
                message: _reminderError,
              ),
              const SizedBox(height: 24),
              TestId(
                TestIds.taskFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save task'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.taskFormCancelButton,
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

  static const Map<Repeat, String> _repeatIds = <Repeat, String>{
    Repeat.none: TestIds.taskFormRepeatNoneChip,
    Repeat.daily: TestIds.taskFormRepeatDailyChip,
    Repeat.weekly: TestIds.taskFormRepeatWeeklyChip,
    Repeat.monthly: TestIds.taskFormRepeatMonthlyChip,
  };

  static const Map<ReminderOffset, String> _reminderIds =
      <ReminderOffset, String>{
        ReminderOffset.none: TestIds.taskFormReminderNoneChip,
        ReminderOffset.atDue: TestIds.taskFormReminderAtDueChip,
        ReminderOffset.hourBefore: TestIds.taskFormReminderHourBeforeChip,
        ReminderOffset.dayBefore: TestIds.taskFormReminderDayBeforeChip,
      };

  /// Hides Flutter's own counter. The note has one of its own with an ID.
  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}

/// The chosen link, with a small tag saying which list it came from.
class _LinkLabel extends StatelessWidget {
  const _LinkLabel({
    required this.name,
    required this.tag,
    required this.colors,
  });

  final String name;

  /// "Fields" or "Animals", or null for a general task.
  final String? tag;

  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? tagText = tag;

    return Row(
      children: <Widget>[
        Expanded(child: Text(name, style: textTheme.bodyLarge)),
        if (tagText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.secondarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tagText,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSecondarySoft,
              ),
            ),
          ),
      ],
    );
  }
}

/// A row of chips where exactly one is picked.
class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.testIdOf,
    required this.onPick,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final String Function(T value) testIdOf;
  final void Function(T value) onPick;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final T value in values)
          TestId(
            testIdOf(value),
            merge: true,
            child: InkWell(
              onTap: () => onPick(value),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.minTapTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: value == selected
                      ? colors.secondarySoft
                      : colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: value == selected ? colors.secondary : colors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Text(
                  labelOf(value),
                  style: textTheme.labelLarge?.copyWith(
                    color: value == selected
                        ? colors.onSecondarySoft
                        : colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.testId, required this.message});

  final String testId;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 0, 0),
      child: TestId(
        testId,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.colors.error),
        ),
      ),
    );
  }
}
