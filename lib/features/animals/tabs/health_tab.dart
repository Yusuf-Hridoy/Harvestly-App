import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../data/farm_repository.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../widgets/health_task_form.dart';
import '../widgets/loss_dialog.dart';

/// The Health tab. It is the same for flocks and herds.
///
/// It shows how many animals are left, the open tasks in the order they need
/// doing, and a history of done tasks and losses.
class HealthTab extends StatelessWidget {
  const HealthTab({super.key, required this.groupId});

  final String groupId;

  Future<void> _recordLoss(BuildContext context, AnimalGroup group) async {
    final LossEntry? loss = await LossDialog.show(
      context,
      type: group.type,
      count: group.count,
    );
    if (loss == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().recordLoss(
      groupId: group.id,
      amount: loss.amount,
      reason: loss.reason,
      date: loss.date,
    );
    AppSnackbar.showOn(messenger, 'Loss saved.');
  }

  Future<void> _addTask(BuildContext context, AnimalGroup group) async {
    final NewHealthTask? made = await HealthTaskForm.open(context);
    if (made == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().addHealthTask(
      groupId: group.id,
      title: made.title,
      dueOn: made.dueOn,
    );
    AppSnackbar.showOn(messenger, 'Health task added.');
  }

  Future<void> _markDone(
    BuildContext context,
    AnimalGroup group,
    HealthTask task,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().markTaskDone(
      groupId: group.id,
      taskId: task.id,
    );
    AppSnackbar.showOn(messenger, 'Marked as done.');
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AnimalGroup? group = repository.groupById(groupId);
    if (group == null) return const SizedBox.shrink();

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<HealthTask> open = group.openTasks;
    final List<HealthHistoryEntry> history = HealthHistoryEntry.of(group);

    return TestId(
      TestIds.healthTab,
      container: true,
      child: ListView(
        key: const PageStorageKey<String>('health_tab'),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.gap,
          AppSizes.screenPadding,
          24,
        ),
        children: <Widget>[
          _CountCard(
            group: group,
            onRecordLoss: () => _recordLoss(context, group),
          ),
          const SizedBox(height: AppSizes.gap),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Health tasks',
                          style: textTheme.titleMedium,
                        ),
                      ),
                      TestId(
                        TestIds.healthAddTaskButton,
                        merge: true,
                        child: TextButton.icon(
                          onPressed: () => _addTask(context, group),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                  if (open.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TestId(
                        TestIds.healthTasksEmptyText,
                        child: Text(
                          "No health tasks. You're all caught up.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < open.length; i++)
                      _TaskRow(
                        number: i + 1,
                        task: open[i],
                        onDone: () => _markDone(context, group, open[i]),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('History', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (history.isEmpty)
                    TestId(
                      TestIds.healthHistoryEmptyText,
                      child: Text(
                        'Nothing here yet.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < history.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: TestId(
                          TestIds.healthHistoryItem(i + 1),
                          child: Text(
                            history[i].text,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.group, required this.onRecordLoss});

  final AnimalGroup group;
  final VoidCallback onRecordLoss;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TestId(
              TestIds.healthCountTitleText,
              child: Text(
                group.isFlock ? 'Birds now' : 'Animals now',
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            TestId(
              TestIds.healthCountValueText,
              child: Text('${group.count}', style: textTheme.displaySmall),
            ),
            const SizedBox(height: 12),
            TestId(
              TestIds.healthRecordLossButton,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: onRecordLoss,
                icon: const Icon(Icons.trending_down_rounded, size: 18),
                label: const Text('Record loss'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: colors.error,
                    width: AppSizes.borderWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.number,
    required this.task,
    required this.onDone,
  });

  final int number;
  final HealthTask task;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isLate = task.state == HealthState.late;

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
      TestIds.healthTaskItem(number),
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: colors.secondarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.health_and_safety_outlined,
                size: 20,
                color: colors.onSecondarySoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TestId(
                    TestIds.healthTaskItemTitle(number),
                    child: Text(task.title, style: textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 2),
                  TestId(
                    TestIds.healthTaskItemState(number),
                    child: Text(
                      task.stateText,
                      style: textTheme.bodySmall?.copyWith(
                        color: stateColor,
                        fontWeight: isLate ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TestId(
              TestIds.healthTaskItemDoneButton(number),
              merge: true,
              child: OutlinedButton(
                onPressed: onDone,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    AppSizes.minTapTarget,
                    AppSizes.minTapTarget,
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
