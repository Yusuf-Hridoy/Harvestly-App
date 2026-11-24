import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/animal_models.dart';
import '../../data/farm_repository.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'widgets/group_card.dart';
import 'widgets/group_menu_sheet.dart';

/// Which groups the Animals list is showing.
enum GroupFilter {
  all('All'),
  birds('Birds'),
  goats('Goats'),
  cows('Cows');

  const GroupFilter(this.label);

  /// The chip text, without the count.
  final String label;

  /// True when a group belongs under this chip.
  bool matches(AnimalGroup group) {
    switch (this) {
      case GroupFilter.all:
        return true;
      case GroupFilter.birds:
        return group.isFlock;
      case GroupFilter.goats:
        return group.type == AnimalType.goats;
      case GroupFilter.cows:
        return group.type == AnimalType.cows;
    }
  }
}

/// The Animals tab: search, filter and the list of the account's groups.
///
/// Groups stay in the order they were added. There is no sort.
class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  /// The message inside the delete dialog.
  static String deleteGroupMessage(AnimalGroup group) =>
      '${group.name} and all its records will be removed. '
      "You can't undo this.";

  /// Asks before deleting, then deletes. Shared with the group form, so both
  /// places show the same dialog and the same snackbar.
  static Future<bool> confirmDeleteGroup(
    BuildContext context,
    AnimalGroup group,
  ) async {
    final FarmRepository repository = context.read<FarmRepository>();
    final bool confirmed = await ConfirmDialog.show(
      context,
      dialogTestId: TestIds.deleteGroupDialog,
      title: 'Delete this group?',
      message: AnimalsScreen.deleteGroupMessage(group),
      messageTestId: TestIds.deleteGroupDialogMessageText,
      cancelLabel: 'Cancel',
      cancelTestId: TestIds.deleteGroupDialogCancelButton,
      confirmLabel: 'Delete',
      confirmTestId: TestIds.deleteGroupDialogConfirmButton,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await repository.deleteGroup(group.id);
    AppSnackbar.showOn(messenger, 'Group deleted.');
    return true;
  }

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final TextEditingController _search = TextEditingController();

  GroupFilter _filter = GroupFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// The groups that match the search text, before the filter chips.
  List<AnimalGroup> _searched(List<AnimalGroup> groups) {
    final String needle = _search.text.trim().toLowerCase();
    if (needle.isEmpty) return groups;
    return groups
        .where((AnimalGroup g) => g.name.toLowerCase().contains(needle))
        .toList();
  }

  void _clearSearchAndFilter() {
    setState(() {
      _search.clear();
      _filter = GroupFilter.all;
    });
  }

  Future<void> _openMenu(AnimalGroup group) async {
    final GroupMenuAction? action = await GroupMenuSheet.show(
      context,
      groupName: group.name,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case GroupMenuAction.edit:
        context.go(AppRoutes.groupEdit(group.id));
      case GroupMenuAction.delete:
        await AnimalsScreen.confirmDeleteGroup(context, group);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<AnimalGroup> all = repository.animals;
    final List<AnimalGroup> searched = _searched(all);
    final List<AnimalGroup> shown = searched
        .where((AnimalGroup g) => _filter.matches(g))
        .toList();

    return Scaffold(
      body: TestId(
        TestIds.animalsScreen,
        container: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  8,
                  AppSizes.screenPadding,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Animals', style: textTheme.headlineMedium),
                    ),
                    TestId(
                      TestIds.animalsAddButton,
                      merge: true,
                      child: IconButton(
                        tooltip: 'Add group',
                        onPressed: () => context.go(AppRoutes.groupNew),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.secondarySoft,
                          foregroundColor: colors.onSecondarySoft,
                          minimumSize: const Size(
                            AppSizes.minTapTarget,
                            AppSizes.minTapTarget,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (all.isEmpty)
                Expanded(
                  child: _EmptyGroups(
                    onAdd: () => context.go(AppRoutes.groupNew),
                  ),
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    12,
                    AppSizes.screenPadding,
                    0,
                  ),
                  child: _SearchBox(
                    controller: _search,
                    onChanged: () => setState(() {}),
                    onClear: () => setState(_search.clear),
                  ),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _filter,
                  counts: <GroupFilter, int>{
                    for (final GroupFilter filter in GroupFilter.values)
                      filter: searched
                          .where((AnimalGroup g) => filter.matches(g))
                          .length,
                  },
                  onPick: (GroupFilter filter) =>
                      setState(() => _filter = filter),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: shown.isEmpty
                      ? _NoResults(onClear: _clearSearchAndFilter)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.screenPadding,
                            4,
                            AppSizes.screenPadding,
                            24,
                          ),
                          itemCount: shown.length,
                          separatorBuilder: (BuildContext _, int _) =>
                              const SizedBox(height: AppSizes.gap),
                          itemBuilder: (BuildContext context, int index) {
                            final AnimalGroup group = shown[index];
                            return GroupCard(
                              number: index + 1,
                              group: group,
                              onOpen: () =>
                                  context.go(AppRoutes.groupDetail(group.id)),
                              onLongPress: () => _openMenu(group),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TestId(
      TestIds.animalsSearchInput,
      child: TextField(
        controller: controller,
        onChanged: (String _) => onChanged(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search groups',
          prefixIcon: const Icon(Icons.search_rounded),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: controller.text.isEmpty
              ? null
              : TestId(
                  TestIds.animalsSearchClearButton,
                  merge: true,
                  child: IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.counts,
    required this.onPick,
  });

  final GroupFilter selected;
  final Map<GroupFilter, int> counts;
  final void Function(GroupFilter filter) onPick;

  static const Map<GroupFilter, String> _testIds = <GroupFilter, String>{
    GroupFilter.all: TestIds.animalsFilterAllChip,
    GroupFilter.birds: TestIds.animalsFilterBirdsChip,
    GroupFilter.goats: TestIds.animalsFilterGoatsChip,
    GroupFilter.cows: TestIds.animalsFilterCowsChip,
  };

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // A Wrap, not a scrolling row, so every chip is always on screen.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          for (final GroupFilter filter in GroupFilter.values)
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
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: filter == selected
                        ? colors.secondarySoft
                        : colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: filter == selected
                          ? colors.secondary
                          : colors.border,
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Text(
                    '${filter.label} ${counts[filter] ?? 0}',
                    style: textTheme.labelLarge?.copyWith(
                      color: filter == selected
                          ? colors.onSecondarySoft
                          : colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.animalsEmptyState,
      container: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: colors.secondarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.egg_outlined, color: colors.onSecondarySoft),
              ),
              const SizedBox(height: 16),
              Text('No animals yet', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Add a flock or herd to start tracking.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              TestId(
                TestIds.animalsEmptyAddButton,
                merge: true,
                child: FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                  child: const Text('Add group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Scrollable, so the keyboard can never squash it into an overflow.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off_rounded, size: 40, color: colors.textMuted),
            const SizedBox(height: 12),
            TestId(
              TestIds.animalsNoResultsText,
              child: Text('No groups match.', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            TestId(
              TestIds.animalsNoResultsClearButton,
              merge: true,
              child: OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
