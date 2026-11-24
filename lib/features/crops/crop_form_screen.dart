import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/crop_catalog.dart';
import '../../data/farm_models.dart';
import '../../data/farm_repository.dart';
import '../../shared/logic/app_clock.dart';
import '../../shared/logic/crop_growth.dart';
import '../../shared/logic/date_text.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/discard_changes.dart';
import '../../shared/widgets/missing_item_screen.dart';

/// Add a crop to one field: pick the type, the planting date and how many
/// plants went in.
class CropFormScreen extends StatefulWidget {
  const CropFormScreen({super.key, required this.fieldId});

  final String fieldId;

  /// How far back a planting date may go.
  static const int pastDaysAllowed = 365;

  static const int minPlants = 1;
  static const int maxPlants = 9999;
  static const int defaultPlants = 10;

  static const String noCropError = 'Please pick a crop.';
  static const String plantsEmptyError = 'Please enter the number of plants.';
  static const String plantsRangeError = 'Use a whole number from 1 to 9,999.';

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _plants = TextEditingController(
    text: '${CropFormScreen.defaultPlants}',
  );

  String? _typeId;
  late DateTime _plantedOn = AppClock.today();
  String? _cropError;
  String? _plantsError;

  bool get _hasChanges =>
      _typeId != null ||
      _plants.text != '${CropFormScreen.defaultPlants}' ||
      _plantedOn != AppClock.today();

  /// The number in the plants box, or null when it is not a whole number.
  int? get _plantsNumber => int.tryParse(_plants.text.trim());

  @override
  void dispose() {
    _search.dispose();
    _plants.dispose();
    super.dispose();
  }

  void _step(int by) {
    final int current = _plantsNumber ?? CropFormScreen.defaultPlants;
    final int next = (current + by).clamp(
      CropFormScreen.minPlants,
      CropFormScreen.maxPlants,
    );
    setState(() {
      _plants.text = '$next';
      _plantsError = null;
    });
  }

  Future<void> _pickDate() async {
    final DateTime today = AppClock.today();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantedOn,
      firstDate: today.subtract(
        const Duration(days: CropFormScreen.pastDaysAllowed),
      ),
      lastDate: today,
      helpText: 'Planting date',
    );
    if (picked != null && mounted) {
      setState(() => _plantedOn = AppClock.dateOnly(picked));
    }
  }

  Future<void> _save(Field field) async {
    final String? typeId = _typeId;
    final int? plants = _plantsNumber;
    final String raw = _plants.text.trim();

    final String? cropError = typeId == null
        ? CropFormScreen.noCropError
        : null;
    final String? plantsError = raw.isEmpty
        ? CropFormScreen.plantsEmptyError
        : (plants == null ||
              plants < CropFormScreen.minPlants ||
              plants > CropFormScreen.maxPlants)
        ? CropFormScreen.plantsRangeError
        : null;

    setState(() {
      _cropError = cropError;
      _plantsError = plantsError;
    });
    if (cropError != null || plantsError != null) return;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().addCrop(
      fieldId: field.id,
      typeId: typeId!,
      plantedOn: _plantedOn,
      plants: plants!,
    );
    router.go(AppRoutes.fieldDetail(field.id));
    AppSnackbar.showOn(
      messenger,
      '${CropCatalog.nameOf(typeId)} added to ${field.name}.',
    );
  }

  Future<void> _leave() async {
    if (_hasChanges && !await DiscardChanges.confirm(context)) return;
    if (!mounted) return;
    context.go(AppRoutes.fieldDetail(widget.fieldId));
  }

  /// "4 of 40" while searching, "40 crops" with an empty search box.
  static String resultCountText(int shown, String search) =>
      search.trim().isEmpty
      ? '${CropCatalog.count} crops'
      : '$shown of ${CropCatalog.count}';

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final Field? field = repository.fieldById(widget.fieldId);
    if (field == null) {
      return const MissingItemScreen(message: 'That field no longer exists.');
    }

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<CropType> results = CropCatalog.search(_search.text);
    final String? typeId = _typeId;

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
          title: TestId(
            TestIds.cropFormTitleText,
            child: Text(
              'Add crop to ${field.name}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        body: TestId(
          TestIds.cropFormScreen,
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  4,
                  AppSizes.screenPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TestId(
                      TestIds.cropFormSearchInput,
                      child: TextField(
                        controller: _search,
                        onChanged: (String _) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: 'Search crops',
                          prefixIcon: Icon(Icons.search_rounded),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TestId(
                            TestIds.cropFormResultCountText,
                            child: Text(
                              resultCountText(results.length, _search.text),
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_cropError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: TestId(
                          TestIds.cropFormCropErrorText,
                          child: Text(
                            _cropError!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TestId(
                  TestIds.cropFormCropList,
                  container: true,
                  child: results.isEmpty
                      ? Center(
                          child: TestId(
                            TestIds.cropFormNoResultsText,
                            child: Text(
                              'No crops match.',
                              style: textTheme.titleMedium,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.screenPadding,
                          ),
                          itemCount: results.length,
                          itemBuilder: (BuildContext context, int index) {
                            final CropType type = results[index];
                            return _CropOption(
                              type: type,
                              selected: type.id == typeId,
                              onPick: () => setState(() {
                                _typeId = type.id;
                                _cropError = null;
                              }),
                            );
                          },
                        ),
                ),
              ),
              _BottomPanel(
                plantedOn: _plantedOn,
                onPickDate: _pickDate,
                plants: _plants,
                plantsError: _plantsError,
                onPlantsChanged: () => setState(() => _plantsError = null),
                onStep: _step,
                typeId: typeId,
                onSave: () => _save(field),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One crop in the catalog list.
class _CropOption extends StatelessWidget {
  const _CropOption({
    required this.type,
    required this.selected,
    required this.onPick,
  });

  final CropType type;
  final bool selected;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.cropFormCropOption(type.id),
      merge: true,
      child: InkWell(
        onTap: onPick,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? colors.link : colors.border,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(type.name, style: textTheme.bodyLarge)),
              Text(
                '${type.daysToHarvest} days',
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The date, the plant counter, the harvest estimate and Save crop.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.plantedOn,
    required this.onPickDate,
    required this.plants,
    required this.plantsError,
    required this.onPlantsChanged,
    required this.onStep,
    required this.typeId,
    required this.onSave,
  });

  final DateTime plantedOn;
  final VoidCallback onPickDate;
  final TextEditingController plants;
  final String? plantsError;
  final VoidCallback onPlantsChanged;
  final void Function(int by) onStep;
  final String? typeId;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? number = int.tryParse(plants.text.trim());
    final String? type = typeId;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: AppSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            14,
            AppSizes.screenPadding,
            14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Planted on', style: textTheme.titleSmall),
                        const SizedBox(height: 6),
                        TestId(
                          TestIds.cropFormDateInput,
                          merge: true,
                          child: OutlinedButton.icon(
                            onPressed: onPickDate,
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                            label: Text(DateText.dayMonthYear(plantedOn)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.gap),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Plants', style: textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          TestId(
                            TestIds.cropFormPlantsMinusButton,
                            merge: true,
                            child: IconButton.outlined(
                              tooltip: 'One less plant',
                              onPressed:
                                  number != null &&
                                      number > CropFormScreen.minPlants
                                  ? () => onStep(-1)
                                  : null,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: TestId(
                              TestIds.cropFormPlantsInput,
                              child: TextField(
                                controller: plants,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (String _) => onPlantsChanged(),
                              ),
                            ),
                          ),
                          TestId(
                            TestIds.cropFormPlantsPlusButton,
                            merge: true,
                            child: IconButton.outlined(
                              tooltip: 'One more plant',
                              onPressed:
                                  number != null &&
                                      number < CropFormScreen.maxPlants
                                  ? () => onStep(1)
                                  : null,
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (plantsError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TestId(
                    TestIds.cropFormPlantsErrorText,
                    child: Text(
                      plantsError!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ),
              if (type != null) ...<Widget>[
                const SizedBox(height: 10),
                TestId(
                  TestIds.cropFormHarvestEstimateText,
                  child: Text(
                    'Harvest around ${DateText.dayMonthYear(CropGrowth.of(typeId: type, plantedOn: plantedOn).harvestOn)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TestId(
                TestIds.cropFormSaveButton,
                merge: true,
                child: FilledButton(
                  onPressed: onSave,
                  child: const Text('Save crop'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
