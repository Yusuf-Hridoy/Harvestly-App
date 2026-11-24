import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/farm_models.dart';
import '../../data/farm_repository.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/discard_changes.dart';
import 'widgets/soil_picker_sheet.dart';

/// Add field and Edit field. One screen does both.
///
/// When [fieldId] is null the form is empty and Save adds a new field.
/// Otherwise the form starts filled in and Save changes that field.
class FieldFormScreen extends StatefulWidget {
  const FieldFormScreen({super.key, this.fieldId});

  final String? fieldId;

  /// The longest a note can be.
  static const int noteLimit = 120;

  /// The smallest and largest size, in acres.
  static const double maxSizeAcres = 1000;

  static const String nameEmptyError = 'Please enter a field name.';
  static const String nameLengthError = 'Use 2 to 30 characters.';
  static const String nameTakenError =
      'This name is already used. Pick another one.';
  static const String sizeEmptyError = 'Please enter the size.';
  static const String sizeFormatError = 'Use numbers only, like 0.5.';
  static const String sizeTooSmallError = 'Size must be more than 0.';
  static const String sizeTooBigError = 'Size must be 1,000 acres or less.';
  static const String soilEmptyError = 'Please pick a soil type.';

  @override
  State<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends State<FieldFormScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _size = TextEditingController();
  final TextEditingController _note = TextEditingController();

  SoilType? _soil;
  String? _nameError;
  String? _sizeError;
  String? _soilError;

  String _startName = '';
  String _startSize = '';
  String _startNote = '';
  SoilType? _startSoil;
  bool _loaded = false;

  bool get _isEdit => widget.fieldId != null;

  @override
  void dispose() {
    _name.dispose();
    _size.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Fills the form from the field being edited, once.
  void _loadOnce(FarmRepository repository) {
    if (_loaded) return;
    _loaded = true;
    final String? id = widget.fieldId;
    if (id == null) return;
    final Field? field = repository.fieldById(id);
    if (field == null) return;

    _name.text = field.name;
    _size.text = field.sizeText;
    _note.text = field.note;
    _soil = field.soil;
    _startName = _name.text;
    _startSize = _size.text;
    _startNote = _note.text;
    _startSoil = _soil;
  }

  bool get _hasChanges =>
      _name.text != _startName ||
      _size.text != _startSize ||
      _note.text != _startNote ||
      _soil != _startSoil;

  /// Checks the name. Returns the error text, or null when it is fine.
  String? _checkName(FarmRepository repository) {
    final String value = _name.text.trim();
    if (value.isEmpty) return FieldFormScreen.nameEmptyError;
    if (value.length < 2 || value.length > 30) {
      return FieldFormScreen.nameLengthError;
    }
    if (repository.isNameTaken(value, exceptFieldId: widget.fieldId)) {
      return FieldFormScreen.nameTakenError;
    }
    return null;
  }

  /// Checks the size. Returns the error text, or null when it is fine.
  String? _checkSize() {
    final String value = _size.text.trim();
    if (value.isEmpty) return FieldFormScreen.sizeEmptyError;
    final double? number = double.tryParse(value);
    if (number == null) return FieldFormScreen.sizeFormatError;
    if (number <= 0) return FieldFormScreen.sizeTooSmallError;
    if (number > FieldFormScreen.maxSizeAcres) {
      return FieldFormScreen.sizeTooBigError;
    }
    return null;
  }

  Future<void> _save() async {
    final FarmRepository repository = context.read<FarmRepository>();
    final String? nameError = _checkName(repository);
    final String? sizeError = _checkSize();
    final String? soilError = _soil == null
        ? FieldFormScreen.soilEmptyError
        : null;

    setState(() {
      _nameError = nameError;
      _sizeError = sizeError;
      _soilError = soilError;
    });

    if (nameError != null || sizeError != null || soilError != null) return;

    final String name = _name.text.trim();
    final double size = double.parse(_size.text.trim());
    final String note = _note.text.trim();
    final String? editId = widget.fieldId;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (editId == null) {
      final Field added = await repository.addField(
        name: name,
        sizeAcres: size,
        soil: _soil!,
        note: note,
      );
      router.go(AppRoutes.fieldDetail(added.id));
      AppSnackbar.showOn(messenger, 'Field added.');
    } else {
      await repository.editField(
        fieldId: editId,
        name: name,
        sizeAcres: size,
        soil: _soil!,
        note: note,
      );
      router.go(AppRoutes.fieldDetail(editId));
      AppSnackbar.showOn(messenger, 'Field updated.');
    }
  }

  /// Opens the soil picker and keeps what the user chose.
  Future<void> _pickSoil() async {
    final SoilType? picked = await SoilPickerSheet.show(context, _soil);
    if (picked == null || !mounted) return;
    setState(() {
      _soil = picked;
      _soilError = null;
    });
  }

  /// Leaves the screen, asking first when something was changed.
  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (!mounted) return;
    final String? id = widget.fieldId;
    context.go(id == null ? AppRoutes.fields : AppRoutes.fieldDetail(id));
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    _loadOnce(repository);

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String title = _isEdit ? 'Edit field' : 'Add field';

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
          title: TestId(TestIds.fieldFormTitleText, child: Text(title)),
        ),
        body: TestId(
          TestIds.fieldFormScreen,
          container: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              28,
            ),
            children: <Widget>[
              _Label(text: 'Field name'),
              TestId(
                TestIds.fieldFormNameInput,
                child: TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  maxLength: 30,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(
                    hintText: 'Field 5 · West plot',
                  ),
                  onChanged: (String _) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ),
              _ErrorLine(
                testId: TestIds.fieldFormNameErrorText,
                message: _nameError,
              ),
              const SizedBox(height: 16),
              _Label(text: 'Size (acres)'),
              TestId(
                TestIds.fieldFormSizeInput,
                child: TextField(
                  controller: _size,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    // Numbers with up to 2 decimals, nothing else.
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: '0.5'),
                  onChanged: (String _) {
                    if (_sizeError != null) setState(() => _sizeError = null);
                  },
                ),
              ),
              _ErrorLine(
                testId: TestIds.fieldFormSizeErrorText,
                message: _sizeError,
              ),
              const SizedBox(height: 16),
              _Label(text: 'Soil type'),
              TestId(
                TestIds.fieldFormSoilDropdown,
                merge: true,
                child: OutlinedButton(
                  onPressed: _pickSoil,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _soil?.label ?? 'Pick a soil type',
                          style: textTheme.bodyLarge?.copyWith(
                            color: _soil == null ? colors.textMuted : null,
                          ),
                        ),
                      ),
                      Icon(Icons.expand_more_rounded, color: colors.textMuted),
                    ],
                  ),
                ),
              ),
              _ErrorLine(
                testId: TestIds.fieldFormSoilErrorText,
                message: _soilError,
              ),
              const SizedBox(height: 16),
              _Label(text: 'Note (optional)'),
              TestId(
                TestIds.fieldFormNoteInput,
                child: TextField(
                  controller: _note,
                  maxLines: 3,
                  maxLength: FieldFormScreen.noteLimit,
                  buildCounter: _noCounter,
                  decoration: const InputDecoration(
                    hintText: 'Near the water pump',
                  ),
                  onChanged: (String _) => setState(() {}),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TestId(
                  TestIds.fieldFormNoteCounterText,
                  child: Text(
                    '${_note.text.characters.length}/'
                    '${FieldFormScreen.noteLimit}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TestId(
                TestIds.fieldFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save field'),
                ),
              ),
              const SizedBox(height: 10),
              TestId(
                TestIds.fieldFormCancelButton,
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

  /// Hides Flutter's own counter, because the form shows its own.
  static Widget? _noCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
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
