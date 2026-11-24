import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import 'amount_dialog.dart';

/// One day in the chart.
class ChartDay {
  const ChartDay({required this.date, required this.amount});

  final DateTime date;

  /// The amount logged, or 0 for a day with no log.
  final double amount;
}

/// The bar chart of the last 7 or 30 days.
///
/// Bars run oldest on the left to today on the right, so bar 1 is the oldest
/// day. The 30-day chart scrolls sideways and opens scrolled to today.
class ProductionChart extends StatefulWidget {
  const ProductionChart({
    super.key,
    required this.days,
    required this.rules,
    required this.selected,
    required this.onSelect,
  });

  final List<ChartDay> days;
  final AmountRules rules;

  /// Which bar is picked, counting from 0 on the left.
  final int selected;

  final void Function(int index) onSelect;

  /// How tall the bars and their labels are.
  static const double barAreaHeight = 120;

  /// How wide one bar and its gap are in the 30-day chart.
  static const double wideBarWidth = 26;

  /// Above this many days the chart scrolls sideways instead of fitting.
  static const int scrollFromDays = 8;

  @override
  State<ProductionChart> createState() => _ProductionChartState();
}

class _ProductionChartState extends State<ProductionChart> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToToday());
  }

  @override
  void didUpdateWidget(ProductionChart old) {
    super.didUpdateWidget(old);
    // Switching from 7 days to 30 days rebuilds a longer chart, which must
    // open at today as well.
    if (old.days.length != widget.days.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToToday());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToToday() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final bool scrolls = widget.days.length >= ProductionChart.scrollFromDays;
    final double highest = widget.days.fold<double>(
      0,
      (double top, ChartDay day) => day.amount > top ? day.amount : top,
    );

    final Widget bars = Row(
      mainAxisSize: scrolls ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int i = 0; i < widget.days.length; i++)
          _Bar(
            number: i + 1,
            day: widget.days[i],
            highest: highest,
            rules: widget.rules,
            selected: i == widget.selected,
            // 7 days: the value above and the weekday below every bar.
            // 30 days: no values, and a date under every 5th bar counted
            // back from today, so today always has one.
            showValue: !scrolls,
            label: scrolls
                ? ((widget.days.length - 1 - i) % 5 == 0
                      ? DateText.dayMonth(widget.days[i].date)
                      : '')
                : DateText.weekdayShort(widget.days[i].date),
            fixedWidth: scrolls ? ProductionChart.wideBarWidth : null,
            onTap: () => widget.onSelect(i),
          ),
      ],
    );

    return TestId(
      TestIds.productionChart,
      container: true,
      child: SizedBox(
        height: ProductionChart.barAreaHeight,
        // The chart has its own horizontal scroll. It sits deeper in the hit
        // test than the tab view's page scroll, so it takes a sideways drag
        // first and the tab never changes under the user's finger.
        child: scrolls
            ? SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: bars,
              )
            : bars,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.number,
    required this.day,
    required this.highest,
    required this.rules,
    required this.selected,
    required this.showValue,
    required this.label,
    required this.fixedWidth,
    required this.onTap,
  });

  final int number;
  final ChartDay day;
  final double highest;
  final AmountRules rules;
  final bool selected;
  final bool showValue;
  final String label;
  final double? fixedWidth;
  final VoidCallback onTap;

  /// How tall the tallest bar is drawn.
  static const double maxBarHeight = 68;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double height = highest <= 0
        ? 2
        : (day.amount / highest * maxBarHeight).clamp(2.0, maxBarHeight);

    final Widget column = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showValue)
          // One line, whatever the number: "14.5" in a narrow bar would
          // otherwise wrap and push the column past the chart's height.
          SizedBox(
            height: 16,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                rules.value(day.amount),
                maxLines: 1,
                softWrap: false,
                style: textTheme.labelSmall?.copyWith(color: colors.textMuted),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? colors.secondary : colors.secondarySoft,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 14,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: textTheme.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );

    final Widget tappable = TestId(
      TestIds.productionChartBar(number),
      merge: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: fixedWidth == null
              ? column
              : SizedBox(width: fixedWidth, child: column),
        ),
      ),
    );

    return fixedWidth == null ? Expanded(child: tappable) : tappable;
  }
}
