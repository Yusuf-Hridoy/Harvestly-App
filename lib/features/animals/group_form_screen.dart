import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/animal_models.dart';
import '../../data/farm_repository.dart';
import '../../shared/logic/app_clock.dart';
import '../../shared/logic/date_text.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/discard_changes.dart';
import 'animals_screen.dart';

/// Add animal group and Edit animal group. One screen does both.
///
/// When [groupId] is null the form is empty and Save adds a new group.
/// Otherwise the form starts filled in, the type is locked, and the screen
/// also offers Delete group.
class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key, this.groupId});

  final String? groupId;

  static const int minCount = 1;
  static const int maxCount = 9999;
  static const int defaultCount = 10;

  /// How far back a start date may go.
  static const int pastYearsAllowed = 10;

  static const String nameEmptyError = 'Please enter a group name.';
  static const String nameLengthError = 'Use 2 to 30 characters.';
  static const String nameTakenError =
      'This name is already used. Pick another one.';
  static const String typeEmptyError = 'Please pick an animal type.';
  static const String countEmptyError = 'Please enter the number of animals.';
  static const String countRangeError = 'Use a whole number from 1 to 9,999.';

  static const String lockedTypeText =
      "Animal type can't be changed after the group is made.";

  /// The help line under the type chips, which depends on the kind.
  static String helpTextFor(AnimalType type) => type.isFlock
      ? 'Birds track eggs, hatching and health.'
      : 'Goats and cows track milk, breeding and health.';

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _count = TextEditingController(
    text: '${GroupFormScreen.defaultCount}',
  );

  AnimalType? _type;
  late DateTime _startedOn = AppClock.today();

  String? _nameError;
  String? _typeError;
  String? _countError;

  String _startName = '';
  String _startCount = '${GroupFormScreen.defaultCount}';
  AnimalType? _startType;
  late DateTime _startDate = AppClock.today();
  bool _loaded = false;

  bool get _isEdit => widget.groupId != null;

  /// The number in the count box, or null when it is not a whole number.
  int? get _countNumber => int.tryParse(_count.text.trim());

  @override
  void dispose() {
    _name.dispose();
    _count.dispose();
    super.dispose();
  }

  /// Fills the form from the group being edited, once.
  void _loadOnce(FarmRepository repository) {
    if (_loaded) return;
    _loaded = true;
    final String? id = widget.groupId;
    if (id == null) return;
    final AnimalGroup? group = repository.groupById(id);
    if (group == null) return;

    _name.text = group.name;
    _count.text = '${group.count}';
    _type = group.type;
    _startedOn = group.startedOn;
    _startName = _name.text;
    _startCount = _count.text;
    _startType = _type;
    _startDate = _startedOn;
  }

  bool get _hasChanges =>
      _name.text != _startName ||
      _count.text != _startCount ||
      _type != _startType ||
      _startedOn != _startDate;

  /// Checks the name. Returns the error text, or null when it is fine.
  String? _checkName(FarmRepository repository) {
    final String value = _name.text.trim();
    if (value.isEmpty) return GroupFormScreen.nameEmptyError;
    if (value.length < 2 || value.length > 30) {
      return GroupFormScreen.nameLengthError;
    }
    if (repository.isGroupNameTaken(value, exceptGroupId: widget.groupId)) {
      return GroupFormScreen.nameTakenError;
    }
    return null;
  }

  /// Checks the count. Returns the error text, or null when it is fine.
  String? _checkCount() {
    final String raw = _count.text.trim();
    if (raw.isEmpty) return GroupFormScreen.countEmptyError;
    final int? number = int.tryParse(raw);
    if (number == null ||
        number < GroupFormScreen.minCount ||
        number > GroupFormScreen.maxCount) {
      return GroupFormScreen.countRangeError;
    }
    return null;
  }

  void _step(int by) {
    final int current = _countNumber ?? GroupFormScreen.defaultCount;
    final int next = (current + by).clamp(
      GroupFormScreen.minCount,
      GroupFormScreen.maxCount,
    );
    setState(() {
      _count.text = '$next';
      _countError = null;
    });
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startedOn,
      firstDate: DateTime(
        today.year - GroupFormScreen.pastYearsAllowed,
        today.month,
        today.day,
      ),
      lastDate: today,
      helpText: 'Start date',
    );
    if (picked != null && mounted) {
      setState(() => _startedOn = AppClock.dateOnly(picked));
    }
  }

  Future<void> _save() async {
    final FarmRepository repository = context.read<FarmRepository>();
    final String? nameError = _checkName(repository);
    final String? typeError = _type == null
        ? GroupFormScreen.typeEmptyError
        : null;
    final String? countError = _checkCount();

    setState(() {
      _nameError = nameError;
      _typeError = typeError;
      _countError = countError;
    });
    if (nameError != null || typeError != null || countError != null) return;

    final String name = _name.text.trim();
    final int count = _countNumber!;
    final String? editId = widget.groupId;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (editId == null) {
      final AnimalGroup added = await repository.addGroup(
        name: name,
        type: _type!,
        count: count,
        startedOn: _startedOn,
      );
      router.go(AppRoutes.groupDetail(added.id));
      AppSnackbar.showOn(messenger, 'Group added.');
    } else {
      await repository.editGroup(
        groupId: editId,
        name: name,
        count: count,
        startedOn: _startedOn,
      );
      router.go(AppRoutes.groupDetail(editId));
      AppSnackbar.showOn(messenger, 'Group updated.');
    }
  }

  Future<void> _delete(AnimalGroup group) async {
    final GoRouter router = GoRouter.of(context);
    final bool deleted = await AnimalsScreen.confirmDeleteGroup(context, group);
    if (deleted) router.go(AppRoutes.animals);
  }

  /// Leaves the screen, asking first when something was changed.
  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (!mounted) return;
    final String? id = widget.groupId;
    context.go(id == null ? AppRoutes.animals : AppRoutes.groupDetail(id));
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    _loadOnce(repository);

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String title = _isEdit ? 'Edit animal group' : 'Add animal group';
    final AnimalGroup? editing = _isEdit
        ? repository.groupById(widget.groupId!)
        : null;
    final AnimalType? type = _type;
    final int? count = _countNumber;

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
          title: TestId(TestIds.groupFormTitleText, child: Text(title)),
        ),
        body: TestId(
          TestIds.groupFormScreen,
          container: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              28,
            ),
            children: <Widget>[
              const _Label(text: 'Group name'),
              TestId(
                TestIds.groupFormNameInput,
                child: TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  maxLength: 30,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(hintText: 'Flock B'),
                  onChanged: (String _) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ),
              _ErrorLine(
                testId: TestIds.groupFormNameErrorText,
                message: _nameError,
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Animal type'),
              _TypeChips(
                selected: type,
                // The type is fixed once a group is made, so editing shows
                // the chips but does not let them change.
                locked: _isEdit,
                onPick: (AnimalType picked) => setState(() {
                  _type = picked;
                  _typeError = null;
                }),
              ),
              _ErrorLine(
                testId: TestIds.groupFormTypeErrorText,
                message: _typeError,
              ),
              if (_isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TestId(
                    TestIds.groupFormTypeLockedText,
                    child: Text(
                      GroupFormScreen.lockedTypeText,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              if (type != null) ...<Widget>[
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
                    TestIds.groupFormTypeHelpText,
                    child: Text(
                      GroupFormScreen.helpTextFor(type),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSecondarySoft,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const _Label(text: 'Number of animals'),
              Row(
                children: <Widget>[
                  TestId(
                    TestIds.groupFormCountMinusButton,
                    merge: true,
                    child: IconButton.outlined(
                      tooltip: 'One less animal',
                      onPressed:
                          count != null && count > GroupFormScreen.minCount
                          ? () => _step(-1)
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TestId(
                      TestIds.groupFormCountInput,
                      child: TextField(
                        controller: _count,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (String _) => setState(() {
                          _countError = null;
                        }),
                      ),
                    ),
                  ),
                  TestId(
                    TestIds.groupFormCountPlusButton,
                    merge: true,
                    child: IconButton.outlined(
                      tooltip: 'One more animal',
                      onPressed:
                          count != null && count < GroupFormScreen.maxCount
                          ? () => _step(1)
                          : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
              _ErrorLine(
                testId: TestIds.groupFormCountErrorText,
                message: _countError,
              ),
              const SizedBox(height: 16),
              const _Label(text: 'Start date'),
              TestId(
                TestIds.groupFormDateInput,
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
              const SizedBox(height: 24),
              TestId(
                TestIds.groupFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save group'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.groupFormCancelButton,
                merge: true,
                child: OutlinedButton(
                  onPressed: _leave,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              if (editing != null) ...<Widget>[
                const SizedBox(height: 24),
                TestId(
                  TestIds.groupFormDeleteButton,
                  merge: true,
                  child: OutlinedButton.icon(
                    onPressed: () => _delete(editing),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete group'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(
                        color: colors.error,
                        width: AppSizes.borderWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hides Flutter's own counter, because this form shows none.
  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}

/// The five animal type chips.
class _TypeChips extends StatelessWidget {
  const _TypeChips({
    required this.selected,
    required this.locked,
    required this.onPick,
  });

  final AnimalType? selected;

  /// True on the Edit form, where the chips only show the current type.
  final bool locked;

  final void Function(AnimalType type) onPick;

  static const Map<AnimalType, String> _testIds = <AnimalType, String>{
    AnimalType.hens: TestIds.groupFormTypeHensChip,
    AnimalType.ducks: TestIds.groupFormTypeDucksChip,
    AnimalType.quail: TestIds.groupFormTypeQuailChip,
    AnimalType.goats: TestIds.groupFormTypeGoatsChip,
    AnimalType.cows: TestIds.groupFormTypeCowsChip,
  };

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final AnimalType type in AnimalType.values)
          TestId(
            _testIds[type]!,
            merge: true,
            child: InkWell(
              onTap: locked ? null : () => onPick(type),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.minTapTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: type == selected
                      ? colors.secondarySoft
                      : colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: type == selected ? colors.secondary : colors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Text(
                  type.label,
                  style: textTheme.labelLarge?.copyWith(
                    color: type == selected
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
