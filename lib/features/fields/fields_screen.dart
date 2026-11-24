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
import '../../shared/widgets/confirm_dialog.dart';
import 'widgets/field_card.dart';
import 'widgets/field_menu_sheet.dart';
import 'widgets/fields_sort_sheet.dart';

/// Which fields the list is showing.
enum FieldFilter {
  all('All'),
  growing('Growing'),
  empty('Empty'),
  harvestSoon('Harvest soon');

  const FieldFilter(this.label);

  /// The chip text, without the count.
  final String label;
}

/// The Fields tab: search, filter, sort and the list of the account's fields.
class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  /// A field counts as "harvest soon" at this many days left or fewer.
  static const int harvestSoonDays = 14;

  /// The message inside the delete dialog, which changes when the field has
  /// crops in it.
  static String deleteFieldMessage(Field field) {
    if (field.crops.isEmpty) {
      return '${field.name} will be removed. You can\'t undo this.';
    }
    return 'This field has ${field.cropCountText.toLowerCase()}. '
        'Deleting it removes them too. You can\'t undo this.';
  }

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final TextEditingController _search = TextEditingController();

  FieldFilter _filter = FieldFilter.all;
  FieldSort _sort = FieldSort.name;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// The fields that match the search text, before the filter chips.
  List<Field> _searched(List<Field> fields) {
    final String needle = _search.text.trim().toLowerCase();
    if (needle.isEmpty) return fields;
    return fields
        .where((Field field) => field.name.toLowerCase().contains(needle))
        .toList();
  }

  bool _matchesFilter(Field field, FieldFilter filter) {
    switch (filter) {
      case FieldFilter.all:
        return true;
      case FieldFilter.growing:
        return field.crops.isNotEmpty;
      case FieldFilter.empty:
        return field.crops.isEmpty;
      case FieldFilter.harvestSoon:
        return field.hasHarvestSoon;
    }
  }

  List<Field> _sorted(List<Field> fields) {
    final List<Field> list = List<Field>.of(fields);
    switch (_sort) {
      case FieldSort.name:
        list.sort(
          (Field a, Field b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case FieldSort.size:
        list.sort((Field a, Field b) {
          final int bySize = b.sizeAcres.compareTo(a.sizeAcres);
          return bySize != 0
              ? bySize
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case FieldSort.harvestDate:
        list.sort((Field a, Field b) {
          final int? left = a.soonestDaysLeft;
          final int? right = b.soonestDaysLeft;
          // Fields with no crops go to the end, in name order.
          if (left == null && right == null) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          if (left == null) return 1;
          if (right == null) return -1;
          final int byDays = left.compareTo(right);
          return byDays != 0
              ? byDays
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    }
    return list;
  }

  void _clearSearchAndFilter() {
    setState(() {
      _search.clear();
      _filter = FieldFilter.all;
    });
  }

  Future<void> _openSortSheet() async {
    final FieldSort? picked = await FieldsSortSheet.show(context, _sort);
    if (picked != null && mounted) setState(() => _sort = picked);
  }

  Future<void> _openMenu(Field field) async {
    final FieldMenuAction? action = await FieldMenuSheet.show(
      context,
      fieldName: field.name,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case FieldMenuAction.edit:
        context.go(AppRoutes.fieldEdit(field.id));
      case FieldMenuAction.delete:
        await _confirmDelete(field);
    }
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

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await repository.deleteField(field.id);
    AppSnackbar.showOn(messenger, 'Field deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<Field> all = repository.fields;
    final List<Field> searched = _searched(all);
    final List<Field> shown = _sorted(
      searched.where((Field f) => _matchesFilter(f, _filter)).toList(),
    );

    return Scaffold(
      body: TestId(
        TestIds.fieldsScreen,
        container: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  8,
                  AppSizes.screenPadding,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Fields', style: textTheme.headlineMedium),
                    ),
                    TestId(
                      TestIds.fieldsAddButton,
                      merge: true,
                      child: IconButton(
                        tooltip: 'Add field',
                        onPressed: () => context.go(AppRoutes.fieldNew),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.secondarySoft,
                          foregroundColor: colors.onSecondarySoft,
                          minimumSize: const Size(
                            AppSizes.minTapTarget,
                            AppSizes.minTapTarget,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (all.isEmpty)
                Expanded(
                  child: _EmptyFields(
                    onAdd: () => context.go(AppRoutes.fieldNew),
                  ),
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    12,
                    AppSizes.screenPadding,
                    0,
                  ),
                  child: _SearchBox(
                    controller: _search,
                    onChanged: () => setState(() {}),
                    onClear: () => setState(_search.clear),
                  ),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _filter,
                  counts: <FieldFilter, int>{
                    for (final FieldFilter filter in FieldFilter.values)
                      filter: searched
                          .where((Field f) => _matchesFilter(f, filter))
                          .length,
                  },
                  onPick: (FieldFilter filter) =>
                      setState(() => _filter = filter),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    12,
                    8,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TestId(
                          TestIds.fieldsCountText,
                          child: Text(
                            countText(shown.length),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      TestId(
                        TestIds.fieldsSortButton,
                        merge: true,
                        child: TextButton.icon(
                          onPressed: _openSortSheet,
                          icon: const Icon(Icons.swap_vert_rounded, size: 18),
                          label: Text('Sort: ${_sort.label}'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: shown.isEmpty
                      ? _NoResults(onClear: _clearSearchAndFilter)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding,
                            4,
                            AppSizes.screenPadding,
                            24,
                          ),
                          itemCount: shown.length,
                          separatorBuilder: (BuildContext _, int _) =>
                              const SizedBox(height: AppSizes.gap),
                          itemBuilder: (BuildContext context, int index) {
                            final Field field = shown[index];
                            return FieldCard(
                              number: index + 1,
                              field: field,
                              onOpen: () =>
                                  context.go(AppRoutes.fieldDetail(field.id)),
                              onLongPress: () => _openMenu(field),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// "4 fields" or "1 field".
  static String countText(int count) =>
      count == 1 ? '1 field' : '$count fields';
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TestId(
      TestIds.fieldsSearchInput,
      child: TextField(
        controller: controller,
        onChanged: (String _) => onChanged(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search fields',
          prefixIcon: const Icon(Icons.search_rounded),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: controller.text.isEmpty
              ? null
              : TestId(
                  TestIds.fieldsSearchClearButton,
                  merge: true,
                  child: IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.counts,
    required this.onPick,
  });

  final FieldFilter selected;
  final Map<FieldFilter, int> counts;
  final void Function(FieldFilter filter) onPick;

  static const Map<FieldFilter, String> _testIds = <FieldFilter, String>{
    FieldFilter.all: TestIds.fieldsFilterAllChip,
    FieldFilter.growing: TestIds.fieldsFilterGrowingChip,
    FieldFilter.empty: TestIds.fieldsFilterEmptyChip,
    FieldFilter.harvestSoon: TestIds.fieldsFilterHarvestSoonChip,
  };

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // A Wrap, not a scrolling row, so every chip is always on screen.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final FieldFilter filter in FieldFilter.values)
            TestId(
              _testIds[filter]!,
              merge: true,
              child: InkWell(
                onTap: () => onPick(filter),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.minTapTarget,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: filter == selected
                        ? colors.secondarySoft
                        : colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: filter == selected
                          ? colors.secondary
                          : colors.border,
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Text(
                    '${filter.label} ${counts[filter] ?? 0}',
                    style: textTheme.labelLarge?.copyWith(
                      color: filter == selected
                          ? colors.onSecondarySoft
                          : colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyFields extends StatelessWidget {
  const _EmptyFields({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.fieldsEmptyState,
      container: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: colors.secondarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: colors.onSecondarySoft,
                ),
              ),
              const SizedBox(height: 16),
              Text('No fields yet', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Add your first field to start tracking crops.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              TestId(
                TestIds.fieldsEmptyAddButton,
                merge: true,
                child: FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                  child: const Text('Add field'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Scrollable, so the keyboard can never squash it into an overflow.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off_rounded, size: 40, color: colors.textMuted),
            const SizedBox(height: 12),
            TestId(
              TestIds.fieldsNoResultsText,
              child: Text('No fields match.', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            TestId(
              TestIds.fieldsNoResultsClearButton,
              merge: true,
              child: OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
