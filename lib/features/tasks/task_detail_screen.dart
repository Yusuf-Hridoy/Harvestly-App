import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/animal_models.dart';
import '../../data/farm_models.dart';
import '../../data/farm_repository.dart';
import '../../data/task_models.dart';
import '../../data/task_rules.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/missing_item_screen.dart';
import 'tasks_screen.dart';

/// One task: when it is due, what it belongs to, and what can be done to it.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  /// Why a done repeating task has no reopen button.
  static const String repeatLockedText =
      "Repeating tasks can't be reopened. The next one is already in your "
      'list.';

  /// The line inside the delete dialog.
  static String deleteMessage(FarmTask task) =>
      "${task.title} will be removed. You can't undo this.";

  /// Asks before deleting, then deletes and goes back to the list.
  static Future<void> confirmDelete(BuildContext context, FarmTask task) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final bool confirmed = await ConfirmDialog.show(
      context,
      dialogTestId: TestIds.deleteTaskDialog,
      title: 'Delete this task?',
      message: deleteMessage(task),
      messageTestId: TestIds.deleteTaskDialogMessageText,
      cancelLabel: 'Cancel',
      cancelTestId: TestIds.deleteTaskDialogCancelButton,
      confirmLabel: 'Delete',
      confirmTestId: TestIds.deleteTaskDialogConfirmButton,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final GoRouter router = GoRouter.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    // Deleting also cancels the reminder, because the repository tells the
    // notification service about every task change.
    await repository.deleteTask(task.id);
    router.go(AppRoutes.tasks);
    AppSnackbar.showOn(messenger, 'Task deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final FarmTask? task = repository.taskById(taskId);

    if (task == null) {
      return const MissingItemScreen(
        message: 'That task no longer exists.',
        goTo: AppRoutes.tasks,
      );
    }

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool overdue = TaskRules.groupOf(task) == TaskGroup.overdue;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go(AppRoutes.tasks),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Task'),
        actions: <Widget>[
          TestId(
            TestIds.taskDetailEditButton,
            merge: true,
            child: IconButton(
              tooltip: 'Edit task',
              onPressed: () => context.go(AppRoutes.taskEdit(task.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: TestId(
        TestIds.taskDetailScreen,
        container: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            8,
            AppSizes.screenPadding,
            28,
          ),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TestId(
                      TestIds.taskDetailTitleText,
                      child: Text(task.title, style: textTheme.headlineSmall),
                    ),
                    const SizedBox(height: 10),
                    _DueChip(text: TaskRules.dueChipText(task), warn: overdue),
                  ],
                ),
              ),
            ),
            if (task.link != null) ...<Widget>[
              const SizedBox(height: AppSizes.gap),
              _LinkCard(task: task, repository: repository),
            ],
            const SizedBox(height: AppSizes.gap),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: <Widget>[
                    _InfoRow(
                      icon: Icons.repeat_rounded,
                      label: 'Repeat',
                      testId: TestIds.taskDetailRepeatText,
                      value: TaskRules.repeatText(task),
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.notifications_none_rounded,
                      label: 'Reminder',
                      testId: TestIds.taskDetailReminderText,
                      value: TaskRules.reminderText(task),
                    ),
                    if (task.note.isNotEmpty) ...<Widget>[
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Note',
                        testId: TestIds.taskDetailNoteText,
                        value: task.note,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (task.isOpen)
              TestId(
                TestIds.taskDetailDoneButton,
                merge: true,
                child: FilledButton.icon(
                  onPressed: () => TasksScreen.completeWithUndo(context, task),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Mark as done'),
                ),
              )
            else if (task.repeats)
              TestId(
                TestIds.taskDetailRepeatLockedText,
                child: Text(
                  repeatLockedText,
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              )
            else
              TestId(
                TestIds.taskDetailReopenButton,
                merge: true,
                child: FilledButton.icon(
                  onPressed: () => repository.reopenTask(task.id),
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Mark as not done'),
                ),
              ),
            const SizedBox(height: 10),
            TestId(
              TestIds.taskDetailDeleteButton,
              merge: true,
              child: OutlinedButton.icon(
                onPressed: () => confirmDelete(context, task),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  minimumSize: const Size.fromHeight(52),
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

/// When the task is due, or that it is already done.
class _DueChip extends StatelessWidget {
  const _DueChip({required this.text, required this.warn});

  final String text;

  /// True when the task is late, which uses the warning color.
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return TestId(
      TestIds.taskDetailDueChip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: warn ? colors.surface : colors.secondarySoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: warn ? colors.warningText : colors.secondary,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: warn ? colors.warningText : colors.onSecondarySoft,
          ),
        ),
      ),
    );
  }
}

/// The field or animal group the task belongs to, with a way to open it.
class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.task, required this.repository});

  final FarmTask task;
  final FarmRepository repository;

  /// "Field 2 · South bed · 0.4 acre" or "Duck pond · 6 birds".
  String _nameLine() {
    final TaskLink link = task.link!;
    switch (link.kind) {
      case TaskLinkKind.field:
        final Field? field = repository.fieldById(link.id);
        if (field == null) return TaskRules.generalName;
        return '${field.name} · ${field.sizeText} acre';
      case TaskLinkKind.group:
        final AnimalGroup? group = repository.groupById(link.id);
        if (group == null) return TaskRules.generalName;
        return '${group.name} · ${group.type.countText(group.count)}';
    }
  }

  String _route() {
    final TaskLink link = task.link!;
    switch (link.kind) {
      case TaskLinkKind.field:
        return AppRoutes.fieldDetail(link.id);
      case TaskLinkKind.group:
        return AppRoutes.groupDetail(link.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isField = task.link!.kind == TaskLinkKind.field;

    return TestId(
      TestIds.taskDetailLinkCard,
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                  isField ? Icons.grid_view_rounded : Icons.egg_outlined,
                  color: colors.onSecondarySoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Linked to',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TestId(
                      TestIds.taskDetailLinkNameText,
                      child: Text(
                        _nameLine(),
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              TestId(
                TestIds.taskDetailLinkOpenButton,
                merge: true,
                child: TextButton(
                  onPressed: () => context.go(_route()),
                  child: const Text('Open →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line in the info card: an icon, a label and the value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.testId,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String testId;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: colors.textMuted),
          const SizedBox(width: 12),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ),
          Expanded(
            child: TestId(
              testId,
              child: Text(value, style: textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
