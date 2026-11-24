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
import '../../shared/widgets/missing_item_screen.dart';
import 'tabs/breeding_tab.dart';
import 'tabs/hatching_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/production_tab.dart';

/// One animal group: a header and three tabs that depend on its kind.
///
/// A flock gets Eggs, Hatching and Health. A herd gets Milk, Breeding and
/// Health. It is one screen for both, because only the tab list changes.
class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId, this.tab});

  final String groupId;

  /// The tab from the URL: eggs, milk, hatching, breeding or health. A name
  /// that does not fit the group's kind opens the first tab.
  final String? tab;

  /// The tab names a kind has, in the order they are shown.
  static List<String> tabNamesFor(AnimalType type) => type.isFlock
      ? const <String>['eggs', 'hatching', 'health']
      : const <String>['milk', 'breeding', 'health'];

  /// Which tab a URL name means, or 0 when the name does not fit this kind.
  static int indexOfTab(AnimalType type, String? name) {
    if (name == null) return 0;
    final int at = tabNamesFor(type).indexOf(name);
    return at < 0 ? 0 : at;
  }

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with TickerProviderStateMixin {
  TabController? _tabs;

  /// The kind the current controller was built for. A group can never change
  /// kind, so this only rebuilds when the screen opens a different group.
  AnimalType? _builtFor;

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  /// Makes the controller the first time, and keeps it on the tab the URL
  /// asks for.
  TabController _controllerFor(AnimalType type) {
    final int wanted = GroupDetailScreen.indexOfTab(type, widget.tab);
    TabController? tabs = _tabs;

    if (tabs == null || _builtFor != type) {
      tabs?.dispose();
      tabs = TabController(
        length: GroupDetailScreen.tabNamesFor(type).length,
        initialIndex: wanted,
        vsync: this,
      );
      tabs.addListener(_onTabChanged);
      _tabs = tabs;
      _builtFor = type;
      return tabs;
    }

    // The URL changed under us, for example from a tap on Home's animal
    // health card while this screen was already open.
    if (!tabs.indexIsChanging && tabs.index != wanted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabs?.index != wanted) _tabs?.animateTo(wanted);
      });
    }
    return tabs;
  }

  /// Keeps the URL on the tab the user is looking at, so the link can be
  /// shared and Back works the way the user expects.
  void _onTabChanged() {
    final TabController? tabs = _tabs;
    final AnimalType? type = _builtFor;
    if (tabs == null || type == null || tabs.indexIsChanging) return;

    final String name = GroupDetailScreen.tabNamesFor(type)[tabs.index];
    if (name == widget.tab) return;
    if (!mounted) return;
    GoRouter.of(context)
        .replace(AppRoutes.groupDetail(widget.groupId, tab: name));
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AnimalGroup? group = repository.groupById(widget.groupId);
    if (group == null) {
      return const MissingItemScreen(
        message: 'That animal group no longer exists.',
        goTo: AppRoutes.animals,
      );
    }

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TabController tabs = _controllerFor(group.type);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go(AppRoutes.animals),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: TestId(
          TestIds.groupDetailTitleText,
          child: Text(group.name, overflow: TextOverflow.ellipsis),
        ),
        actions: <Widget>[
          TestId(
            TestIds.groupDetailEditButton,
            merge: true,
            child: IconButton(
              tooltip: 'Edit group',
              onPressed: () => context.go(AppRoutes.groupEdit(group.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
      body: TestId(
        TestIds.groupDetailScreen,
        container: true,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                4,
                AppSizes.screenPadding,
                10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TestId(
                  TestIds.groupDetailInfoText,
                  child: Text(
                    group.infoLine,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            _GroupTabBar(tabs: tabs, type: group.type),
            Expanded(
              child: TabBarView(
                controller: tabs,
                children: <Widget>[
                  if (group.isFlock) ...<Widget>[
                    ProductionTab(groupId: group.id),
                    HatchingTab(groupId: group.id),
                  ] else ...<Widget>[
                    ProductionTab(groupId: group.id),
                    BreedingTab(groupId: group.id),
                  ],
                  HealthTab(groupId: group.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The three tabs, each with its own test ID.
class _GroupTabBar extends StatelessWidget {
  const _GroupTabBar({required this.tabs, required this.type});

  final TabController tabs;
  final AnimalType type;

  static const Map<String, String> _testIds = <String, String>{
    'eggs': TestIds.groupTabEggs,
    'milk': TestIds.groupTabMilk,
    'hatching': TestIds.groupTabHatching,
    'breeding': TestIds.groupTabBreeding,
    'health': TestIds.groupTabHealth,
  };

  static const Map<String, String> _labels = <String, String>{
    'eggs': 'Eggs',
    'milk': 'Milk',
    'hatching': 'Hatching',
    'breeding': 'Breeding',
    'health': 'Health',
  };

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> names = GroupDetailScreen.tabNamesFor(type);

    return TabBar(
      controller: tabs,
      labelColor: colors.text,
      unselectedLabelColor: colors.textMuted,
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: textTheme.labelLarge,
      indicatorColor: colors.secondary,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: colors.border,
      tabs: <Widget>[
        for (final String name in names)
          TestId(_testIds[name]!, merge: true, child: Tab(text: _labels[name])),
      ],
    );
  }
}
