import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/sample_farm_data.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Today's jobs, with a checkbox on each row.
///
/// In Phase 1 the ticks live in memory only and reset when the app restarts.
class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.doneFlags,
    required this.onToggle,
    required this.onSeeAll,
  });

  final List<FarmTask> tasks;

  /// One flag per task, in the same order.
  final List<bool> doneFlags;

  /// Called with the task index when a checkbox is tapped.
  final void Function(int index) onToggle;

  /// Called when "See all" is tapped.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.homeTasksCard,
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Today's tasks", style: textTheme.titleMedium),
                  ),
                  TestId(
                    TestIds.homeTasksSeeAllLink,
                    merge: true,
                    child: TextButton(
                      onPressed: onSeeAll,
                      child: const Text('See all'),
                    ),
                  ),
                ],
              ),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
                  child: TestId(
                    TestIds.homeTasksEmptyText,
                    child: Text(
                      'No tasks for today.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              for (int i = 0; i < tasks.length; i++)
                _TaskRow(
                  number: i + 1,
                  task: tasks[i],
                  done: doneFlags[i],
                  colors: colors,
                  onToggle: () => onToggle(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.number,
    required this.task,
    required this.done,
    required this.colors,
    required this.onToggle,
  });

  final int number;
  final FarmTask task;
  final bool done;
  final AppColorSet colors;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.homeTaskItem(number),
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TestId(
              TestIds.homeTaskCheckbox(number),
              child: Checkbox(value: done, onChanged: (_) => onToggle()),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.title,
                    style: textTheme.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? colors.textMuted : colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.detail,
                    style: textTheme.bodySmall?.copyWith(
                      color: task.detailIsWarning
                          ? colors.warningText
                          : colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
