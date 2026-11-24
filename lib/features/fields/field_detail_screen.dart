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
import '../../shared/widgets/discard_changes.dart';
import '../../shared/widgets/missing_item_screen.dart';
import '../../shared/widgets/stage_chip.dart';
import 'fields_screen.dart';
import 'widgets/field_map.dart';

/// One field: its drawn map, the crops in it and its past harvests.
class FieldDetailScreen extends StatefulWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  /// The shape being dragged. Null while it matches the saved shape.
  List<MapPoint>? _draftCorners;

  /// The last field this screen showed.
  ///
  /// Deleting takes the field out of the repository while this screen is
  /// still on top. Holding the last copy lets it finish drawing until the
  /// move back to the Fields list happens, instead of flashing the
  /// "no longer exists" message at the user.
  Field? _lastField;

  bool get _hasShapeChanges => _draftCorners != null;

  void _onCornerMoved(int index, MapPoint point, Field field) {
    setState(() {
      final List<MapPoint> next = List<MapPoint>.of(
        _draftCorners ?? field.corners,
      );
      next[index] = point;
      _draftCorners = next;
    });
  }

  Future<void> _saveShape(Field field) async {
    final List<MapPoint>? corners = _draftCorners;
    if (corners == null) return;
    await context.read<FarmRepository>().saveShape(
      fieldId: field.id,
      corners: corners,
    );
    if (!mounted) return;
    setState(() => _draftCorners = null);
    AppSnackbar.show(context, 'Shape saved.');
  }

  void _undoShape() => setState(() => _draftCorners = null);

  /// Leaves the screen, asking first when the shape was dragged but not saved.
  Future<void> _leave() async {
    if (_hasShapeChanges && !await DiscardChanges.confirm(context)) return;
    if (!mounted) return;
    context.go(AppRoutes.fields);
  }

  Future<void> _confirmDelete(Field field) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final bool confirmed = await ConfirmDialog.show(
      context,
      dialogTestId: TestIds.deleteFieldDialog,
      title: 'Delete this field?',
      message: FieldsScreen.deleteFieldMessage(field),
      messageTestId: TestIds.deleteFieldDialogMessageText,
      cancelLabel: 'Cancel',
      cancelTestId: TestIds.deleteFieldDialogCancelButton,
      confirmLabel: 'Delete',
      confirmTestId: TestIds.deleteFieldDialogConfirmButton,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await repository.deleteField(field.id);
    router.go(AppRoutes.fields);
    AppSnackbar.showOn(messenger, 'Field deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final Field? field = repository.fieldById(widget.fieldId) ?? _lastField;
    if (field == null) {
      return const MissingItemScreen(message: 'That field no longer exists.');
    }
    _lastField = field;

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<MapPoint> corners = _draftCorners ?? field.corners;
    final List<Crop> crops = field.cropsByDaysLeft;

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
            TestIds.fieldDetailTitleText,
            child: Text(field.name, overflow: TextOverflow.ellipsis),
          ),
          actions: <Widget>[
            TestId(
              TestIds.fieldDetailEditButton,
              merge: true,
              child: IconButton(
                tooltip: 'Edit field',
                onPressed: () => context.go(AppRoutes.fieldEdit(field.id)),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ],
        ),
        body: TestId(
          TestIds.fieldDetailScreen,
          container: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              4,
              AppSizes.screenPadding,
              28,
            ),
            children: <Widget>[
              TestId(
                TestIds.fieldDetailInfoText,
                child: Text(
                  field.note.isEmpty
                      ? field.shortLine
                      : '${field.shortLine} · ${field.note}',
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ),
              const SizedBox(height: 14),
              FieldMap(
                corners: corners,
                onCornerMoved: (int index, MapPoint point) =>
                    _onCornerMoved(index, point, field),
              ),
              if (_hasShapeChanges) ...<Widget>[
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TestId(
                        TestIds.fieldMapSaveShapeButton,
                        merge: true,
                        child: FilledButton(
                          onPressed: () => _saveShape(field),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Save shape'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: TestId(
                        TestIds.fieldMapUndoShapeButton,
                        merge: true,
                        child: OutlinedButton(
                          onPressed: _undoShape,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Undo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(child: Text('Crops', style: textTheme.titleMedium)),
                  TestId(
                    TestIds.fieldDetailAddCropButton,
                    merge: true,
                    child: TextButton.icon(
                      onPressed: () => context.go(AppRoutes.cropNew(field.id)),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add crop'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (crops.isEmpty)
                _NoCrops(onAdd: () => context.go(AppRoutes.cropNew(field.id)))
              else
                for (int i = 0; i < crops.length; i++) ...<Widget>[
                  _CropCard(
                    number: i + 1,
                    crop: crops[i],
                    onOpen: () =>
                        context.go(AppRoutes.cropDetail(field.id, crops[i].id)),
                  ),
                  const SizedBox(height: AppSizes.gap),
                ],
              if (field.harvests.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                TestId(
                  TestIds.fieldDetailPastHarvestsSection,
                  container: true,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Past harvests', style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          for (int i = 0; i < field.harvests.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TestId(
                                TestIds.fieldDetailPastHarvestItem(i + 1),
                                child: Text(
                                  harvestLine(field.harvests[i]),
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              TestId(
                TestIds.fieldDetailDeleteButton,
                merge: true,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(field),
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  label: Text(
                    'Delete field',
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
      ),
    );
  }

  /// "Tomato · 6 Dec 2026 · 18.50 kg".
  static String harvestLine(Harvest harvest) =>
      '${harvest.name} · ${DateText.dayMonthYear(harvest.harvestedOn)} · '
      '${harvest.amountKg.toStringAsFixed(2)} kg';
}

/// One crop card inside a field.
class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.number,
    required this.crop,
    required this.onOpen,
  });

  final int number;
  final Crop crop;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CropGrowth growth = crop.growth;

    return TestId(
      TestIds.fieldDetailCropItem(number),
      container: true,
      child: Card(
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TestId(
                        TestIds.fieldDetailCropItemName(number),
                        child: Text(crop.name, style: textTheme.titleMedium),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StageChip(label: growth.stage.label),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${crop.plants} plants · '
                  'Planted ${DateText.dayMonth(crop.plantedOn)}',
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: growth.progress,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  growth.daysLeftText,
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoCrops extends StatelessWidget {
  const _NoCrops({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.fieldDetailCropsEmptyText,
              child: Text(
                'No crops in this field yet.',
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            TestId(
              TestIds.fieldDetailCropsEmptyAddButton,
              merge: true,
              child: FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                child: const Text('Add crop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
