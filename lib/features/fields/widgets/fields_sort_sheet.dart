import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The three ways the Fields list can be ordered.
enum FieldSort {
  name('Name'),
  size('Size'),
  harvestDate('Harvest date');

  const FieldSort(this.label);

  /// The name shown on the Sort button, for example "Sort: Name".
  final String label;
}

/// The bottom sheet that picks the order of the Fields list.
///
/// The choice lasts until the app closes. It is not saved.
class FieldsSortSheet extends StatelessWidget {
  const FieldsSortSheet({super.key, required this.current});

  final FieldSort current;

  /// Shows the sheet and returns the chosen order, or null when it is closed
  /// without choosing.
  static Future<FieldSort?> show(BuildContext context, FieldSort current) {
    return showModalBottomSheet<FieldSort>(
      context: context,
      builder: (BuildContext sheetContext) => FieldsSortSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TestId(
      TestIds.fieldsSortSheet,
      container: true,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Sort fields by',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _SortOption(
              testId: TestIds.fieldsSortNameOption,
              sort: FieldSort.name,
              detail: 'A to Z',
              current: current,
            ),
            _SortOption(
              testId: TestIds.fieldsSortSizeOption,
              sort: FieldSort.size,
              detail: 'Largest first',
              current: current,
            ),
            _SortOption(
              testId: TestIds.fieldsSortHarvestOption,
              sort: FieldSort.harvestDate,
              detail: 'Soonest harvest first',
              current: current,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.testId,
    required this.sort,
    required this.detail,
    required this.current,
  });

  final String testId;
  final FieldSort sort;
  final String detail;
  final FieldSort current;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool selected = sort == current;

    return TestId(
      testId,
      merge: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(sort),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(sort.label, style: textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? colors.link : colors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
