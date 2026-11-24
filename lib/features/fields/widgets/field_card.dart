import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/farm_models.dart';
import '../../../shared/logic/crop_growth.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/stage_chip.dart';

/// One field in the Fields list.
///
/// The number is the card's place on screen right now, after search, filter
/// and sort, counting from 1.
class FieldCard extends StatelessWidget {
  const FieldCard({
    super.key,
    required this.number,
    required this.field,
    required this.onOpen,
    required this.onLongPress,
  });

  final int number;
  final Field field;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Crop? main = field.mainCrop;
    final CropGrowth? growth = main?.growth;

    return TestId(
      TestIds.fieldsListItem(number),
      container: true,
      child: Card(
        child: InkWell(
          onTap: onOpen,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TestId(
                        TestIds.fieldsListItemName(number),
                        child: Text(field.name, style: textTheme.titleMedium),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TestId(
                      TestIds.fieldsListItemStageChip(number),
                      child: StageChip(
                        label: growth?.stage.label ?? 'Empty',
                        quiet: growth == null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  field.summaryLine,
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
                if (main != null && growth != null) ...<Widget>[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: growth.progress,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(main.name, style: textTheme.bodyMedium),
                      ),
                      Text(
                        growth.daysLeftText,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
