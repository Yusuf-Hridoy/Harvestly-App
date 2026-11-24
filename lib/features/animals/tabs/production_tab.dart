import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../data/farm_repository.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../widgets/amount_dialog.dart';
import '../widgets/production_chart.dart';

/// The Eggs tab for a flock and the Milk tab for a herd.
///
/// Both kinds use this one widget and the same `production_*` test IDs, so
/// one page object can drive either. Only the words, the steps and the
/// number format change.
class ProductionTab extends StatefulWidget {
  const ProductionTab({super.key, required this.groupId});

  final String groupId;

  /// How many days each range shows.
  static const int shortRange = 7;
  static const int longRange = 30;

  /// The daily average of the days in range that have a log, with 1 decimal.
  /// "–" when no day in range has one.
  static String averageText({
    required List<double?> amounts,
    required AmountRules rules,
  }) {
    final List<double> logged = <double>[
      for (final double? amount in amounts) ?amount,
    ];
    if (logged.isEmpty) return '–';
    final double total = logged.fold<double>(
      0,
      (double sum, double amount) => sum + amount,
    );
    final String unit = rules.isEggs ? 'eggs' : 'L';
    return '${(total / logged.length).toStringAsFixed(1)} $unit';
  }

  /// "75%" for a flock, "7.0 L" for a herd, or "–" with no animals.
  static String secondStatText(AnimalGroup group) {
    if (group.count <= 0) return '–';
    if (group.isFlock) {
      return '${(group.todayAmount * 100 ~/ group.count)}%';
    }
    return '${(group.todayAmount / group.count).toStringAsFixed(1)} L';
  }

  @override
  State<ProductionTab> createState() => _ProductionTabState();
}

class _ProductionTabState extends State<ProductionTab> {
  int _rangeDays = ProductionTab.shortRange;

  /// Which bar is picked, counting from 0 on the left. Null means today,
  /// which is the bar on the right.
  int? _selected;

  AmountRules _rulesFor(AnimalGroup group) =>
      group.isFlock ? AmountRules.eggs : AmountRules.milk;

  /// The days the chart shows, oldest first and ending today.
  List<ChartDay> _days(AnimalGroup group) {
    final DateTime today = AppClock.today();
    return <ChartDay>[
      for (int back = _rangeDays - 1; back >= 0; back--)
        () {
          final DateTime date = today.subtract(Duration(days: back));
          return ChartDay(date: date, amount: group.amountOn(date) ?? 0);
        }(),
    ];
  }

  /// The raw amounts for the same days, with null for a day that has no log.
  List<double?> _loggedAmounts(AnimalGroup group) {
    final DateTime today = AppClock.today();
    return <double?>[
      for (int back = _rangeDays - 1; back >= 0; back--)
        group.amountOn(today.subtract(Duration(days: back))),
    ];
  }

  Future<void> _setToday(AnimalGroup group, double amount) async {
    await context.read<FarmRepository>().setDayAmount(
      groupId: group.id,
      date: AppClock.today(),
      amount: amount,
    );
  }

  /// Moves today's amount by [by], keeping it inside the range.
  Future<void> _step(AnimalGroup group, double by) async {
    final AmountRules rules = _rulesFor(group);
    final double next = (group.todayAmount + by).clamp(0, rules.max);
    await _setToday(group, next);
  }

  Future<void> _typeAmount(AnimalGroup group) async {
    final AmountRules rules = _rulesFor(group);
    final double? amount = await AmountDialog.show(
      context,
      rules: rules,
      title: group.isFlock ? 'Eggs today' : 'Milk today',
      startAmount: group.todayAmount,
    );
    if (amount == null || !mounted) return;
    await _setToday(group, amount);
  }

  Future<void> _editPastDay(AnimalGroup group) async {
    final AmountRules rules = _rulesFor(group);
    final PastDayAmount? picked = await PastDayDialog.show(
      context,
      rules: rules,
    );
    if (picked == null || !mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().setDayAmount(
      groupId: group.id,
      date: picked.date,
      amount: picked.amount,
    );
    AppSnackbar.showOn(
      messenger,
      'Saved ${rules.withUnit(picked.amount)} '
      'for ${DateText.dayMonth(picked.date)}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AnimalGroup? group = repository.groupById(widget.groupId);
    if (group == null) return const SizedBox.shrink();

    final AmountRules rules = _rulesFor(group);
    final List<ChartDay> days = _days(group);
    final int selected = (_selected ?? days.length - 1).clamp(
      0,
      days.length - 1,
    );
    final ChartDay picked = days[selected];

    return TestId(
      TestIds.productionTab,
      container: true,
      child: ListView(
        // Keeps where the user had scrolled when they come back to this tab.
        key: const PageStorageKey<String>('production_tab'),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.gap,
          AppSizes.screenPadding,
          24,
        ),
        children: <Widget>[
          _TodayCard(
            group: group,
            rules: rules,
            onStep: (double by) => _step(group, by),
            onType: () => _typeAmount(group),
          ),
          const SizedBox(height: AppSizes.gap),
          _ChartCard(
            days: days,
            rules: rules,
            rangeDays: _rangeDays,
            selected: selected,
            selectedLine:
                '${DateText.weekdayDayMonth(picked.date)} · '
                '${rules.withUnit(picked.amount)}',
            onRange: (int range) => setState(() {
              _rangeDays = range;
              // The pick is a place in the list, so a new range starts at
              // today again.
              _selected = null;
            }),
            onSelect: (int index) => setState(() => _selected = index),
            onEditPast: () => _editPastDay(group),
          ),
          const SizedBox(height: AppSizes.gap),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatBox(
                  testId: TestIds.productionAverageText,
                  label: 'Daily average',
                  value: ProductionTab.averageText(
                    amounts: _loggedAmounts(group),
                    rules: rules,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.gap),
              Expanded(
                child: _StatBox(
                  testId: TestIds.productionRateText,
                  label: group.isFlock ? 'Laying rate' : 'Per animal',
                  value: ProductionTab.secondStatText(group),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The big number with minus and plus.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.group,
    required this.rules,
    required this.onStep,
    required this.onType,
  });

  final AnimalGroup group;
  final AmountRules rules;
  final void Function(double by) onStep;
  final VoidCallback onType;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double amount = group.todayAmount;
    final double step = rules.isEggs ? 1 : 0.5;
    final double longStep = rules.isEggs ? 10 : 5;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          children: <Widget>[
            TestId(
              TestIds.productionTodayTitleText,
              child: Text(
                group.isFlock ? 'Eggs today' : 'Milk today',
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _StepButton(
                  testId: TestIds.productionMinusButton,
                  tooltip: 'Less',
                  icon: Icons.remove_rounded,
                  onTap: amount <= 0 ? null : () => onStep(-step),
                  onLongPress: amount <= 0 ? null : () => onStep(-longStep),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onType,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TestId(
                        TestIds.productionTodayValueText,
                        child: Text(
                          rules.value(amount),
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall?.copyWith(
                            color: colors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _StepButton(
                  testId: TestIds.productionPlusButton,
                  tooltip: 'More',
                  icon: Icons.add_rounded,
                  onTap: amount >= rules.max ? null : () => onStep(step),
                  onLongPress: amount >= rules.max
                      ? null
                      : () => onStep(longStep),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TestId(
              TestIds.productionHintText,
              child: Text(
                rules.isEggs
                    ? 'Long press + to add 10'
                    : 'Long press + to add 5',
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.testId,
    required this.tooltip,
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  final String testId;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final bool on = onTap != null;

    return TestId(
      testId,
      merge: true,
      child: Semantics(
        button: true,
        enabled: on,
        label: tooltip,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: on
                    ? colors.border
                    : colors.border.withValues(alpha: 0.4),
                width: AppSizes.borderWidth,
              ),
            ),
            child: Icon(icon, color: on ? colors.text : colors.textMuted),
          ),
        ),
      ),
    );
  }
}

/// The range switch, the chart, the picked day and Edit a past day.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.days,
    required this.rules,
    required this.rangeDays,
    required this.selected,
    required this.selectedLine,
    required this.onRange,
    required this.onSelect,
    required this.onEditPast,
  });

  final List<ChartDay> days;
  final AmountRules rules;
  final int rangeDays;
  final int selected;
  final String selectedLine;
  final void Function(int range) onRange;
  final void Function(int index) onSelect;
  final VoidCallback onEditPast;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Last $rangeDays days',
                    style: textTheme.titleMedium,
                  ),
                ),
                _RangeSwitch(selected: rangeDays, onPick: onRange),
              ],
            ),
            const SizedBox(height: 12),
            ProductionChart(
              days: days,
              rules: rules,
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TestId(
                    TestIds.productionSelectedText,
                    child: Text(
                      selectedLine,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ),
                TestId(
                  TestIds.productionEditPastButton,
                  merge: true,
                  child: TextButton(
                    onPressed: onEditPast,
                    child: const Text('Edit a past day'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSwitch extends StatelessWidget {
  const _RangeSwitch({required this.selected, required this.onPick});

  final int selected;
  final void Function(int range) onPick;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border, width: AppSizes.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _RangeOption(
            testId: TestIds.productionRange7Option,
            label: '7 days',
            on: selected == ProductionTab.shortRange,
            onTap: () => onPick(ProductionTab.shortRange),
          ),
          _RangeOption(
            testId: TestIds.productionRange30Option,
            label: '30 days',
            on: selected == ProductionTab.longRange,
            onTap: () => onPick(ProductionTab.longRange),
          ),
        ],
      ),
    );
  }
}

class _RangeOption extends StatelessWidget {
  const _RangeOption({
    required this.testId,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final String testId;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;

    return TestId(
      testId,
      merge: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: on ? colors.secondarySoft : null,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: on ? colors.onSecondarySoft : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.testId,
    required this.label,
    required this.value,
  });

  final String testId;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 6),
            TestId(testId, child: Text(value, style: textTheme.headlineSmall)),
          ],
        ),
      ),
    );
  }
}
