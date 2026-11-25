import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/task_models.dart';
import '../../../data/task_rules.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// One task on the Tasks list.
///
/// The checkbox completes the task, and so does a swipe to the right. A
/// swipe to the left does nothing, because nothing on this list deletes.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.group,
    required this.number,
    required this.linkName,
    required this.onToggle,
    required this.onOpen,
  });

  final FarmTask task;

  /// Which group the row is in: overdue, today, upcoming or done.
  final TaskGroup group;

  /// The row's place in its group, counting from 1.
  final int number;

  /// The field or animal group name, or "General".
  final String linkName;

  /// Completes an open task, or reopens a done one.
  final VoidCallback? onToggle;

  /// Opens Task detail.
  final VoidCallback onOpen;

  /// The word used in this row's test IDs.
  String get _groupName => group.name;

  @override
  Widget build(BuildContext context) {
    final Widget row = _buildRow(context);

    // Only an open task can be swiped, and only to the right.
    if (task.isDone) return row;
    return Dismissible(
      key: ValueKey<String>('swipe-${task.id}'),
      direction: DismissDirection.startToEnd,
      background: _SwipeBackground(colors: context.colors),
      confirmDismiss: (DismissDirection _) async {
        onToggle?.call();
        // The row is never really removed here: completing it moves it to
        // the Done group, and the list rebuilds on its own.
        return false;
      },
      child: row,
    );
  }

  Widget _buildRow(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool overdue = group == TaskGroup.overdue;

    return TestId(
      TestIds.tasksItem(_groupName, number),
      container: true,
      child: Material(
        color: colors.surface,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TestId(
                  TestIds.tasksItemCheckbox(_groupName, number),
                  child: Checkbox(
                    value: task.isDone,
                    onChanged: onToggle == null
                        ? null
                        : (bool? _) => onToggle!(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TestId(
                        TestIds.tasksItemTitle(_groupName, number),
                        child: Text(
                          task.title,
                          style: textTheme.bodyLarge?.copyWith(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isDone ? colors.textMuted : colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      TestId(
                        TestIds.tasksItemLine(_groupName, number),
                        child: Text(
                          TaskRules.lineFor(task, linkName),
                          style: textTheme.bodySmall?.copyWith(
                            color: overdue
                                ? colors.warningText
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.repeats)
                  TestId(
                    TestIds.tasksItemRepeatIcon(_groupName, number),
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ),
                if (task.reminder.isOn) ...<Widget>[
                  const SizedBox(width: 8),
                  TestId(
                    TestIds.tasksItemReminderIcon(_groupName, number),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
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

/// What shows under a row while it is swiped to the right.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.colors});

  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.secondarySoft,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_rounded, color: colors.onSecondarySoft),
          const SizedBox(width: 8),
          Text(
            'Done',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: colors.onSecondarySoft),
          ),
        ],
      ),
    );
  }
}
