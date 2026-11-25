import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/farm_repository.dart';
import '../../data/task_models.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import 'widgets/task_group_section.dart';

/// Which tasks the list is showing.
enum TaskFilter {
  all('All'),
  fields('Fields'),
  animals('Animals'),
  general('General');

  const TaskFilter(this.label);

  /// The chip text, without the count.
  final String label;

  /// True when a task belongs under this chip.
  bool matches(FarmTask task) {
    switch (this) {
      case TaskFilter.all:
        return true;
      case TaskFilter.fields:
        return task.link?.kind == TaskLinkKind.field;
      case TaskFilter.animals:
        return task.link?.kind == TaskLinkKind.group;
      case TaskFilter.general:
        return task.link == null;
    }
  }
}

/// The Tasks tab: filter chips and the four groups of tasks.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  static const String emptyTitle = 'No tasks yet';
  static const String emptyMessage = 'Add a task to plan your farm work.';
  static const String filterEmptyText = 'Nothing here. Try another filter.';
  static const String doneMessage = 'Marked as done.';

  /// Whether the Done list is open.
  ///
  /// Kept on the class, not in the state, so it survives opening a task and
  /// coming back. It goes back to folded when the app closes, which is what
  /// the brief asks for.
  static bool doneOpen = false;

  /// Completes a task and offers Undo.
  ///
  /// Shared with Home, so both places behave the same. Undo reopens the
  /// task, and for a repeating task also removes the one it started.
  static Future<void> completeWithUndo(
    BuildContext context,
    FarmTask task,
  ) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final TaskCompletion completion = await repository.completeTask(task.id);
    if (!completion.happened) return;

    AppSnackbar.showAction(
      messenger,
      message: doneMessage,
      actionLabel: 'Undo',
      actionTestId: TestIds.tasksUndoButton,
      onAction: () => repository.undoComplete(completion),
    );
  }

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter.all;

  /// The tasks of one group that match the chosen chip.
  List<FarmTask> _shown(FarmRepository repository, TaskGroup group) =>
      repository
          .tasksIn(group)
          .where((FarmTask task) => _filter.matches(task))
          .toList();

  /// How many open tasks each chip covers.
  int _countFor(FarmRepository repository, TaskFilter filter) => repository
      .openTasks
      .where((FarmTask task) => filter.matches(task))
      .length;

  Future<void> _toggle(FarmTask task) async {
    if (task.isDone) {
      await context.read<FarmRepository>().reopenTask(task.id);
      return;
    }
    await TasksScreen.completeWithUndo(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AppColorSet colors = context.colors;

    final Map<TaskGroup, List<FarmTask>> groups = <TaskGroup, List<FarmTask>>{
      for (final TaskGroup group in TaskGroup.values)
        group: _shown(repository, group),
    };
    final bool nothingAtAll = repository.tasks.isEmpty;
    final bool filterIsEmpty =
        !nothingAtAll && _countFor(repository, _filter) == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: <Widget>[
          TestId(
            TestIds.tasksAddButton,
            merge: true,
            child: IconButton(
              tooltip: 'Add task',
              onPressed: () => context.go(AppRoutes.taskNew),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: TestId(
        TestIds.tasksScreen,
        container: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            4,
            AppSizes.screenPadding,
            28,
          ),
          children: <Widget>[
            _FilterChips(
              chosen: _filter,
              countOf: (TaskFilter filter) => _countFor(repository, filter),
              onPick: (TaskFilter filter) => setState(() => _filter = filter),
            ),
            const SizedBox(height: 8),
            if (nothingAtAll)
              _EmptyState(onAdd: () => context.go(AppRoutes.taskNew))
            else ...<Widget>[
              if (filterIsEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
                  child: TestId(
                    TestIds.tasksFilterEmptyText,
                    child: Text(
                      TasksScreen.filterEmptyText,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.textMuted),
                    ),
                  ),
                ),
              for (final TaskGroup group in TaskGroup.values)
                TaskGroupSection(
                  group: group,
                  tasks: groups[group]!,
                  linkNameOf: repository.linkNameFor,
                  onToggle: (FarmTask task) => _checkboxFor(task),
                  onOpen: (FarmTask task) =>
                      context.go(AppRoutes.taskDetail(task.id)),
                  folded: group == TaskGroup.done && !TasksScreen.doneOpen,
                  onFoldTap: group == TaskGroup.done
                      ? () => setState(
                          () => TasksScreen.doneOpen = !TasksScreen.doneOpen,
                        )
                      : null,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// What the checkbox on a row does, or null when it is off.
  ///
  /// A done repeating task cannot be reopened, because finishing it already
  /// made the next one. Task detail says so.
  VoidCallback? _checkboxFor(FarmTask task) {
    if (task.isDone && task.repeats) return null;
    return () => _toggle(task);
  }
}

/// The four filter chips, each with how many open tasks it covers.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.chosen,
    required this.countOf,
    required this.onPick,
  });

  final TaskFilter chosen;
  final int Function(TaskFilter filter) countOf;
  final void Function(TaskFilter filter) onPick;

  static const Map<TaskFilter, String> _testIds = <TaskFilter, String>{
    TaskFilter.all: TestIds.tasksFilterAllChip,
    TaskFilter.fields: TestIds.tasksFilterFieldsChip,
    TaskFilter.animals: TestIds.tasksFilterAnimalsChip,
    TaskFilter.general: TestIds.tasksFilterGeneralChip,
  };

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final TaskFilter filter in TaskFilter.values)
          TestId(
            _testIds[filter]!,
            merge: true,
            child: InkWell(
              onTap: () => onPick(filter),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.minTapTarget,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: filter == chosen
                      ? colors.secondarySoft
                      : colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: filter == chosen ? colors.secondary : colors.border,
                    width: AppSizes.borderWidth,
                  ),
                ),
                child: Text(
                  '${filter.label} ${countOf(filter)}',
                  style: textTheme.labelLarge?.copyWith(
                    color: filter == chosen
                        ? colors.onSecondarySoft
                        : colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shown when the account has no tasks at all.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.tasksEmptyState,
      container: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 48, 8, 8),
        child: Column(
          children: <Widget>[
            Icon(Icons.task_alt_rounded, size: 48, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(TasksScreen.emptyTitle, style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              TasksScreen.emptyMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 20),
            TestId(
              TestIds.tasksEmptyAddButton,
              merge: true,
              child: FilledButton(
                onPressed: onAdd,
                child: const Text('Add task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
