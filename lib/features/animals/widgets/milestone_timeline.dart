import 'package:material_ui/material_ui.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_rules.dart';
import '../../../shared/logic/app_clock.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';

/// The row of dots under a hatch batch or a pregnancy.
///
/// Passed steps are filled, future ones are outlined, and a Today dot sits
/// in date order among them. When today is a milestone day, that milestone
/// becomes the Today dot instead of adding a second one.
class MilestoneTimeline extends StatefulWidget {
  const MilestoneTimeline({
    super.key,
    required this.cardId,
    required this.milestones,
    required this.showDates,
  });

  /// The card this timeline belongs to, for example
  /// `hatching_batch_item_1`. Every step ID is built from it.
  final String cardId;

  final List<Milestone> milestones;

  /// True for a pregnancy, which shows a date under each step. A hatch shows
  /// "Day 7" instead.
  final bool showDates;

  /// How wide one step is.
  static const double stepWidth = 92;

  /// How tall the whole row is.
  static const double height = 76;

  @override
  State<MilestoneTimeline> createState() => _MilestoneTimelineState();
}

class _MilestoneTimelineState extends State<MilestoneTimeline> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Opens with Today on screen.
  void _scrollToToday() {
    if (!_scroll.hasClients) return;
    final int todayAt = _steps().indexWhere((_Step step) => step.isToday);
    if (todayAt < 0) return;
    final double wanted =
        (todayAt + 0.5) * MilestoneTimeline.stepWidth -
        _scroll.position.viewportDimension / 2;
    _scroll.jumpTo(wanted.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  /// The milestones with the Today dot put in date order.
  List<_Step> _steps() {
    final DateTime today = AppClock.today();
    final List<_Step> steps = <_Step>[
      for (final Milestone milestone in widget.milestones)
        _Step(
          label: milestone.label,
          under: widget.showDates
              ? DateText.dayMonth(milestone.date)
              : 'Day ${milestone.dayNumber}',
          date: milestone.date,
          isPassed: milestone.isPassed,
          isToday: milestone.isToday,
        ),
    ];

    // Only add a Today dot when no milestone already falls on today.
    if (!steps.any((_Step step) => step.isToday)) {
      final _Step todayStep = _Step(
        label: 'Today',
        under: DateText.dayMonth(today),
        date: today,
        isPassed: true,
        isToday: true,
        isTodayMarker: true,
      );
      int at = steps.indexWhere((_Step step) => step.date.isAfter(today));
      if (at < 0) at = steps.length;
      steps.insert(at, todayStep);
    }

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final List<_Step> steps = _steps();
    int number = 0;

    return TestId(
      TestIds.timeline(widget.cardId),
      container: true,
      child: SizedBox(
        height: MilestoneTimeline.height,
        // The timeline has its own horizontal scroll. It sits deeper in the
        // hit test than the tab view's page scroll, so a sideways drag here
        // scrolls the timeline and never changes the tab.
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final _Step step in steps)
                _StepDot(
                  step: step,
                  // The Today dot is not a numbered step, so the milestone
                  // numbers stay the same whatever day it is.
                  testId: step.isTodayMarker
                      ? TestIds.timelineTodayMarker(widget.cardId)
                      : TestIds.timelineStep(widget.cardId, ++number),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  const _Step({
    required this.label,
    required this.under,
    required this.date,
    required this.isPassed,
    required this.isToday,
    this.isTodayMarker = false,
  });

  final String label;

  /// "Day 7" for a hatch, "2 Apr" for a pregnancy.
  final String under;

  final DateTime date;
  final bool isPassed;
  final bool isToday;

  /// True only for the extra Today dot.
  final bool isTodayMarker;
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step, required this.testId});

  final _Step step;
  final String testId;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color fill = step.isToday
        ? colors.tertiary
        : (step.isPassed ? colors.secondary : Colors.transparent);
    final Color edge = step.isToday
        ? colors.tertiary
        : (step.isPassed ? colors.secondary : colors.border);

    return TestId(
      testId,
      container: true,
      child: SizedBox(
        width: MilestoneTimeline.stepWidth,
        child: Column(
          children: <Widget>[
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: edge, width: 2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: step.isToday ? colors.text : colors.text,
                fontWeight: step.isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              step.under,
              maxLines: 1,
              style: textTheme.labelSmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
