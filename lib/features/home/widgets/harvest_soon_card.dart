import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/sample_farm_data.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The crop that is closest to picking. Hidden when the farm has no crops.
class HarvestSoonCard extends StatelessWidget {
  const HarvestSoonCard({super.key, required this.harvest});

  final HarvestSoon harvest;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.homeHarvestCard,
      container: true,
      child: Card(
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
                      '${harvest.crop} · ${harvest.field}',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    '${harvest.progressPercent}%',
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
                    value: harvest.progress,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${harvest.daysLeft} days left',
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
