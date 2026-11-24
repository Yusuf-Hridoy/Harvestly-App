import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/farm_models.dart';
import '../../data/farm_repository.dart';
import '../../shared/logic/crop_growth.dart';
import '../../shared/logic/date_text.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/missing_item_screen.dart';
import '../../shared/widgets/stage_chip.dart';
import 'widgets/harvest_dialog.dart';

/// One crop: how far along it is, its dates, and the two actions.
class CropDetailScreen extends StatefulWidget {
  const CropDetailScreen({
    super.key,
    required this.fieldId,
    required this.cropId,
  });

  final String fieldId;
  final String cropId;

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  /// The last field and crop this screen showed.
  ///
  /// Harvesting or deleting takes the crop out of the repository while this
  /// screen is still on top. Holding the last copy lets it finish drawing
  /// until the move back to Field detail happens, instead of flashing the
  /// "no longer exists" message at the user.
  Field? _lastField;
  Crop? _lastCrop;

  Future<void> _harvest(Field field, Crop crop) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final double? amount = await HarvestDialog.show(context);
    if (amount == null || !mounted) return;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await repository.harvestCrop(
      fieldId: field.id,
      cropId: crop.id,
      amountKg: amount,
    );
    router.go(AppRoutes.fieldDetail(field.id));
    AppSnackbar.showOn(messenger, '${crop.name} marked as harvested.');
  }

  Future<void> _delete(Field field, Crop crop) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final bool confirmed = await ConfirmDialog.show(
      context,
      dialogTestId: TestIds.deleteCropDialog,
      title: 'Delete this crop?',
      message: deleteCropMessage(crop: crop, field: field),
      messageTestId: TestIds.deleteCropDialogMessageText,
      cancelLabel: 'Cancel',
      cancelTestId: TestIds.deleteCropDialogCancelButton,
      confirmLabel: 'Delete',
      confirmTestId: TestIds.deleteCropDialogConfirmButton,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await repository.deleteCrop(fieldId: field.id, cropId: crop.id);
    router.go(AppRoutes.fieldDetail(field.id));
    AppSnackbar.showOn(messenger, 'Crop deleted.');
  }

  /// "Tomato in Field 2 · South bed will be removed. You can't undo this."
  static String deleteCropMessage({required Crop crop, required Field field}) =>
      '${crop.name} in ${field.name} will be removed. You can\'t undo this.';

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final Field? field = repository.fieldById(widget.fieldId) ?? _lastField;
    final Crop? crop =
        repository.cropById(widget.fieldId, widget.cropId) ?? _lastCrop;
    if (field == null || crop == null) {
      return const MissingItemScreen(message: 'That crop no longer exists.');
    }
    _lastField = field;
    _lastCrop = crop;

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CropGrowth growth = crop.growth;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go(AppRoutes.fieldDetail(field.id)),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: TestId(
          TestIds.cropDetailNameText,
          child: Text(crop.name, overflow: TextOverflow.ellipsis),
        ),
      ),
      body: TestId(
        TestIds.cropDetailScreen,
        container: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            8,
            AppSizes.screenPadding,
            28,
          ),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TestId(
                      TestIds.cropDetailFieldText,
                      child: Text(
                        field.name,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TestId(
                            TestIds.cropDetailDaysLeftText,
                            child: Text(
                              growth.daysLeftText,
                              style: textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TestId(
                          TestIds.cropDetailStageChip,
                          child: StageChip(label: growth.stage.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TestId(
                      TestIds.cropDetailStageBar,
                      container: true,
                      child: _StageBar(stage: growth.stage),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.gap),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Column(
                  children: <Widget>[
                    _InfoRow(
                      testId: TestIds.cropDetailPlantedText,
                      label: 'Planted',
                      value: DateText.dayMonthYear(crop.plantedOn),
                    ),
                    const Divider(),
                    _InfoRow(
                      testId: TestIds.cropDetailHarvestDateText,
                      label: 'Harvest around',
                      value: DateText.dayMonthYear(growth.harvestOn),
                    ),
                    const Divider(),
                    _InfoRow(
                      testId: TestIds.cropDetailPlantsText,
                      label: 'Plants',
                      value: '${crop.plants}',
                    ),
                    const Divider(),
                    _InfoRow(
                      testId: TestIds.cropDetailDaysToGrowText,
                      label: 'Days to grow',
                      value: '${growth.daysToHarvest}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TestId(
              TestIds.cropDetailHarvestButton,
              merge: true,
              child: FilledButton.icon(
                onPressed: () => _harvest(field, crop),
                icon: const Icon(Icons.agriculture_outlined),
                label: const Text('Mark as harvested'),
              ),
            ),
            const SizedBox(height: 10),
            TestId(
              TestIds.cropDetailDeleteButton,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: () => _delete(field, crop),
                icon: Icon(Icons.delete_outline, color: colors.error),
                label: Text(
                  'Delete crop',
                  style: textTheme.labelLarge?.copyWith(color: colors.error),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The four-step bar: Seedling, Growing, Flowering, Ready.
class _StageBar extends StatelessWidget {
  const _StageBar({required this.stage});

  final CropStage stage;

  /// The short label under each step.
  static const List<String> stepLabels = <String>[
    'Seedling',
    'Growing',
    'Flowering',
    'Ready',
  ];

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int current = CropStage.values.indexOf(stage);

    return Row(
      children: <Widget>[
        for (int i = 0; i < stepLabels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == stepLabels.length - 1 ? 0 : 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= current
                          ? colors.secondary
                          : colors.secondarySoft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepLabels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: i == current ? colors.text : colors.textMuted,
                      fontWeight: i == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.testId,
    required this.label,
    required this.value,
  });

  final String testId;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ),
          TestId(testId, child: Text(value, style: textTheme.titleSmall)),
        ],
      ),
    );
  }
}
