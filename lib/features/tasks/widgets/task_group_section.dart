import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/task_models.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import 'task_row.dart';

/// One heading on the Tasks list with the rows under it.
///
/// Overdue, Today and Upcoming always show their rows. Done has a heading
/// that folds the list away, and starts folded.
class TaskGroupSection extends StatelessWidget {
  const TaskGroupSection({
    super.key,
    required this.group,
    required this.tasks,
    required this.linkNameOf,
    required this.onToggle,
    required this.onOpen,
    this.folded = false,
    this.onFoldTap,
  });

  final TaskGroup group;

  /// The tasks in this group, already in the right order.
  final List<FarmTask> tasks;

  /// The field or group name for one task, or "General".
  final String Function(FarmTask task) linkNameOf;

  /// Completes an open task, or reopens a done one. Null means the row's
  /// checkbox is off, which is how a done repeating task shows.
  final VoidCallback? Function(FarmTask task) onToggle;

  final void Function(FarmTask task) onOpen;

  /// Whether the rows are hidden. Only Done uses this.
  final bool folded;

  /// Set on Done, so tapping the heading opens and closes the list.
  final VoidCallback? onFoldTap;

  static const Map<TaskGroup, String> _headerIds = <TaskGroup, String>{
    TaskGroup.overdue: TestIds.tasksOverdueHeader,
    TaskGroup.today: TestIds.tasksTodayHeader,
    TaskGroup.upcoming: TestIds.tasksUpcomingHeader,
    TaskGroup.done: TestIds.tasksDoneToggle,
  };

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Header(
          testId: _headerIds[group]!,
          text: '${group.label} · ${tasks.length}',
          warning: group == TaskGroup.overdue,
          folded: onFoldTap == null ? null : folded,
          onTap: onFoldTap,
        ),
        if (!folded)
          for (int i = 0; i < tasks.length; i++)
            TaskRow(
              task: tasks[i],
              group: group,
              number: i + 1,
              linkName: linkNameOf(tasks[i]),
              onToggle: onToggle(tasks[i]),
              onOpen: () => onOpen(tasks[i]),
            ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.testId,
    required this.text,
    required this.warning,
    required this.folded,
    required this.onTap,
  });

  final String testId;
  final String text;

  /// True for Overdue, which uses the warning color.
  final bool warning;

  /// Null when the heading does not fold.
  final bool? folded;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final bool? isFolded = folded;

    final Widget line = Container(
      constraints: BoxConstraints(
        minHeight: onTap == null ? 0 : AppSizes.minTapTarget,
      ),
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: warning ? colors.warningText : colors.textMuted,
            ),
          ),
          if (isFolded != null) ...<Widget>[
            const SizedBox(width: 4),
            Icon(
              isFolded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_rounded,
              size: 20,
              color: colors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return TestId(testId, child: line);
    return TestId(
      testId,
      merge: true,
      child: InkWell(onTap: onTap, child: line),
    );
  }
}
