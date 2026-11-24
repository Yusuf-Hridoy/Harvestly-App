import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The one health task that needs attention most, across every group.
///
/// Hidden when nothing is late, due today or due inside a week. Tapping it
/// opens that group on its Health tab.
class AnimalHealthCard extends StatelessWidget {
  const AnimalHealthCard({
    super.key,
    required this.group,
    required this.task,
    required this.onOpen,
  });

  final AnimalGroup group;
  final HealthTask task;

  /// Called when the card is tapped.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color stateColor;
    switch (task.state) {
      case HealthState.late:
        stateColor = colors.warningText;
      case HealthState.dueToday:
        stateColor = colors.link;
      case HealthState.comingUp:
        stateColor = colors.textMuted;
    }

    return TestId(
      TestIds.homeAnimalHealthCard,
      container: true,
      child: Card(
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: colors.secondarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: colors.onSecondarySoft,
                  ),
                ),
                const SizedBox(width: AppSizes.gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Animal health', style: textTheme.titleMedium),
                      const SizedBox(height: 6),
                      TestId(
                        TestIds.homeAnimalHealthTitleText,
                        child: Text(
                          '${task.title} · ${group.name}',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 2),
                      TestId(
                        TestIds.homeAnimalHealthStateText,
                        child: Text(
                          task.stateText,
                          style: textTheme.bodySmall?.copyWith(
                            color: stateColor,
                            fontWeight: task.state == HealthState.late
                                ? FontWeight.w700
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
