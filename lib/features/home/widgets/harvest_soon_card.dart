import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/farm_models.dart';
import '../../../shared/logic/crop_growth.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The crop closest to picking, across every field.
///
/// Hidden when the account has no crops. Tapping it opens that crop.
class HarvestSoonCard extends StatelessWidget {
  const HarvestSoonCard({
    super.key,
    required this.field,
    required this.crop,
    required this.onOpen,
  });

  final Field field;
  final Crop crop;

  /// Called when the card is tapped.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CropGrowth growth = crop.growth;

    return TestId(
      TestIds.homeHarvestCard,
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
                Text('Harvest soon', style: textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${crop.name} · ${field.name}',
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${growth.percent}%',
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TestId(
                  TestIds.homeHarvestProgressBar,
                  container: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: growth.progress,
                      minHeight: 10,
                    ),
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
