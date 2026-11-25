import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/task_models.dart';
import '../../../data/task_rules.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// Today's jobs on Home, read from the account's real tasks.
///
/// A warning line counts anything overdue, then come up to three tasks due
/// today: the open ones first, then the ones already ticked off today.
class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.overdueCount,
    required this.linkNameOf,
    required this.onToggle,
    required this.onOpenTask,
    required this.onOpenOverdue,
    required this.onSeeAll,
  });

  /// The tasks to show, already in the right order.
  final List<FarmTask> tasks;

  /// How many open tasks are late.
  final int overdueCount;

  /// The field or group name for one task, or "General".
  final String Function(FarmTask task) linkNameOf;

  /// Completes an open task, or reopens a done one. Null turns the checkbox
  /// off, which is how a done repeating task shows.
  final VoidCallback? Function(FarmTask task) onToggle;

  final void Function(FarmTask task) onOpenTask;

  /// Opens the Tasks tab from the overdue line.
  final VoidCallback onOpenOverdue;

  /// Called when "See all" is tapped.
  final VoidCallback onSeeAll;

  /// "1 overdue task" or "3 overdue tasks".
  static String overdueText(int count) =>
      count == 1 ? '1 overdue task' : '$count overdue tasks';

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
              if (overdueCount > 0)
                TestId(
                  TestIds.homeTasksOverdueText,
                  merge: true,
                  child: InkWell(
                    onTap: onOpenOverdue,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: colors.warningText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            overdueText(overdueCount),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.warningText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (tasks.isEmpty && overdueCount == 0)
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
                  linkName: linkNameOf(tasks[i]),
                  colors: colors,
                  onToggle: onToggle(tasks[i]),
                  onOpen: () => onOpenTask(tasks[i]),
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
    required this.linkName,
    required this.colors,
    required this.onToggle,
    required this.onOpen,
  });

  final int number;
  final FarmTask task;
  final String linkName;
  final AppColorSet colors;
  final VoidCallback? onToggle;
  final VoidCallback onOpen;

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
              child: Checkbox(
                value: task.isDone,
                onChanged: onToggle == null ? null : (bool? _) => onToggle!(),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: textTheme.bodyLarge?.copyWith(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone ? colors.textMuted : colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        TaskRules.lineFor(task, linkName),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
