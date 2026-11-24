import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../data/demo_accounts.dart';
import '../../data/farm_models.dart';
import '../../data/farm_repository.dart';
import '../../data/sample_farm_data.dart';
import '../../shared/testing/test_id_wrapper.dart';
import '../../shared/testing/test_ids.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../login/login_controller.dart';
import 'widgets/empty_farm_card.dart';
import 'widgets/harvest_soon_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/today_tasks_card.dart';
import 'widgets/weather_card.dart';

/// The Home tab. The fields and crops are real data; the eggs, money, weather
/// and tasks are still sample values.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// How long pull to refresh waits before showing the same data again.
  static const Duration refreshWait = Duration(milliseconds: 800);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _fieldsTabIndex = 1;
  static const int _tasksTabIndex = 3;

  List<bool> _done = <bool>[];
  String? _loadedForAccount;

  void _loadTicks(FarmData data, String accountId) {
    if (_loadedForAccount == accountId) return;
    _loadedForAccount = accountId;
    _done = data.tasks.map((FarmTask t) => t.startsDone).toList();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(HomeScreen.refreshWait);
  }

  void _openTab(int index) {
    StatefulNavigationShell.of(context).goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final DemoAccount? account = context.watch<LoginController>().account;
    if (account == null) return const SizedBox.shrink();

    final FarmRepository repository = context.watch<FarmRepository>();
    final FarmData data = SampleFarmData.forAccount(account.id);
    _loadTicks(data, account.id);

    final AppColorSet colors = context.colors;
    final DateTime now = DateTime.now();
    final List<Field> fields = repository.fields;
    final ({Field field, Crop crop})? harvest = repository.soonestHarvest;

    // The welcome card is only for an account that has nothing at all yet.
    final bool farmIsEmpty =
        fields.isEmpty && data.tasks.isEmpty && data.eggsToday == 0;

    return Scaffold(
      body: TestId(
        TestIds.homeScreen,
        container: true,
        child: SafeArea(
          child: TestId(
            TestIds.homeRefreshIndicator,
            container: true,
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: colors.secondary,
              backgroundColor: colors.surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  8,
                  AppSizes.screenPadding,
                  24,
                ),
                children: <Widget>[
                  _Header(account: account, now: now),
                  const SizedBox(height: 20),
                  if (farmIsEmpty)
                    EmptyFarmCard(
                      onAddFirstField: () => _openTab(_fieldsTabIndex),
                    )
                  else ...<Widget>[
                    WeatherCard(weather: data.weather),
                    const SizedBox(height: AppSizes.gap),
                    _StatGrid(
                      fields: fields.length,
                      cropsGrowing: repository.cropCount,
                      data: data,
                    ),
                    const SizedBox(height: AppSizes.gap),
                    TodayTasksCard(
                      tasks: data.tasks,
                      doneFlags: _done,
                      onToggle: (int i) => setState(() => _done[i] = !_done[i]),
                      onSeeAll: () => _openTab(_tasksTabIndex),
                    ),
                    if (harvest != null) ...<Widget>[
                      const SizedBox(height: AppSizes.gap),
                      HarvestSoonCard(
                        field: harvest.field,
                        crop: harvest.crop,
                        onOpen: () => context.go(
                          AppRoutes.cropDetail(
                            harvest.field.id,
                            harvest.crop.id,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.account, required this.now});

  final DemoAccount account;
  final DateTime now;

  static const List<String> _weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// "Monday, 23 November", from the phone's clock.
  static String dateLine(DateTime when) =>
      '${_weekdays[when.weekday - 1]}, ${when.day} ${_months[when.month - 1]}';

  /// "Good morning" before 12:00, "Good afternoon" from 12:00,
  /// "Good evening" from 17:00.
  static String greetingFor(DateTime when) {
    if (when.hour >= 17) return 'Good evening';
    if (when.hour >= 12) return 'Good afternoon';
    return 'Good morning';
  }

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TestId(
                TestIds.homeDateText,
                child: Text(
                  dateLine(now),
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ),
              const SizedBox(height: 4),
              TestId(
                TestIds.homeGreetingText,
                child: Text(
                  '${greetingFor(now)}, ${account.firstName}',
                  style: textTheme.headlineMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _NotificationsBell(),
      ],
    );
  }
}

class _NotificationsBell extends StatelessWidget {
  const _NotificationsBell();

  static const String _count = '3';

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return SizedBox(
      height: AppSizes.minTapTarget,
      width: AppSizes.minTapTarget,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: TestId(
              TestIds.homeNotificationsButton,
              merge: true,
              child: IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => AppSnackbar.show(
                  context,
                  'Notifications come in a later phase.',
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  borderRadius: BorderRadius.circular(9),
                ),
                constraints: const BoxConstraints(minWidth: 18),
                child: TestId(
                  TestIds.homeNotificationsBadge,
                  child: Text(
                    _count,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onTertiary,
                      fontWeight: FontWeight.w600,
                    ),
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

class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.fields,
    required this.cropsGrowing,
    required this.data,
  });

  /// How many fields the account has right now.
  final int fields;

  /// How many crops are growing across every field.
  final int cropsGrowing;

  final FarmData data;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.gap,
      crossAxisSpacing: AppSizes.gap,
      childAspectRatio: 1.05,
      children: <Widget>[
        StatCard(
          testId: TestIds.homeStatFieldsCard,
          label: 'Fields',
          value: '$fields',
          icon: Icons.grid_view_rounded,
        ),
        StatCard(
          testId: TestIds.homeStatCropsCard,
          label: 'Crops growing',
          value: '$cropsGrowing',
          icon: Icons.spa_outlined,
        ),
        StatCard(
          testId: TestIds.homeStatEggsCard,
          label: 'Eggs today',
          value: '${data.eggsToday}',
          icon: Icons.egg_outlined,
        ),
        StatCard(
          testId: TestIds.homeStatProfitCard,
          label: 'Profit this month',
          value: data.profitThisMonth,
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}
