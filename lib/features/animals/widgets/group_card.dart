import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// One animal group in the Animals list.
///
/// [number] is the card's place on screen after the search and the filter,
/// counting from 1, so a test can point at "the second card".
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.number,
    required this.group,
    required this.onOpen,
    required this.onLongPress,
  });

  final int number;
  final AnimalGroup group;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? warning = group.warningText;

    return TestId(
      TestIds.animalsListItem(number),
      container: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onOpen,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: colors.secondarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        group.isFlock
                            ? Icons.egg_outlined
                            : Icons.water_drop_outlined,
                        color: colors.onSecondarySoft,
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TestId(
                            TestIds.animalsListItemName(number),
                            child: Text(
                              group.name,
                              style: textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            group.summaryLine,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TestId(
                      TestIds.animalsListItemToday(number),
                      child: Text(
                        group.todayText,
                        textAlign: TextAlign.right,
                        style: textTheme.labelLarge?.copyWith(
                          color: group.hasTodayLog
                              ? colors.secondary
                              : colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                if (warning != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 16,
                        color: colors.warningText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TestId(
                          TestIds.animalsListItemWarning(number),
                          child: Text(
                            warning,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.warningText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
