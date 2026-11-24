import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../../../data/animal_models.dart';
import '../../../data/animal_rules.dart';
import '../../../data/farm_repository.dart';
import '../../../shared/logic/date_text.dart';
import '../../../shared/testing/test_id_wrapper.dart';
import '../../../shared/testing/test_ids.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../widgets/hatch_batch_form.dart';
import '../widgets/hatch_result_dialog.dart';
import '../widgets/milestone_timeline.dart';

/// The Hatching tab, for flocks only.
///
/// It shows the batches still running with their countdown and timeline,
/// then the batches that already hatched.
class HatchingTab extends StatelessWidget {
  const HatchingTab({super.key, required this.groupId});

  final String groupId;

  /// "10 hen eggs · Started 11 Nov 2026 · Hatch around 1 Dec".
  static String batchLine(AnimalType type, HatchBatch batch) =>
      '${batch.eggs} ${type.oneWord} eggs · '
      'Started ${DateText.dayMonthYear(batch.startedOn)} · '
      'Hatch around ${DateText.dayMonth(AnimalRules.hatchDate(type, batch.startedOn))}';

  /// "8 of 10 hatched · 21 Oct 2026".
  static String pastLine(HatchBatch batch) =>
      '${batch.resultText} · ${DateText.dayMonthYear(batch.resultOn!)}';

  Future<void> _newBatch(BuildContext context, AnimalGroup group) async {
    final NewBatch? made = await HatchBatchForm.open(context);
    if (made == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final HatchBatch batch = await context.read<FarmRepository>().addBatch(
      groupId: group.id,
      startedOn: made.startedOn,
      eggs: made.eggs,
    );
    AppSnackbar.showOn(messenger, '${batch.title} started.');
  }

  Future<void> _recordResult(
    BuildContext context,
    AnimalGroup group,
    HatchBatch batch,
  ) async {
    final int? hatched = await HatchResultDialog.show(
      context,
      eggs: batch.eggs,
    );
    if (hatched == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().finishBatch(
      groupId: group.id,
      batchId: batch.id,
      hatched: hatched,
    );
    AppSnackbar.showOn(
      messenger,
      '${batch.title} saved: $hatched of ${batch.eggs} hatched.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AnimalGroup? group = repository.groupById(groupId);
    if (group == null) return const SizedBox.shrink();

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<HatchBatch> active = group.activeBatches;
    final List<HatchBatch> past = group.pastBatches;

    return TestId(
      TestIds.hatchingTab,
      container: true,
      child: ListView(
        key: const PageStorageKey<String>('hatching_tab'),
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.gap,
          AppSizes.screenPadding,
          24,
        ),
        children: <Widget>[
          if (active.isEmpty && past.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: TestId(
                TestIds.hatchingEmptyText,
                child: Text(
                  'No hatching batches yet.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
          for (int i = 0; i < active.length; i++) ...<Widget>[
            _ActiveBatchCard(
              number: i + 1,
              type: group.type,
              batch: active[i],
              onRecord: () => _recordResult(context, group, active[i]),
            ),
            const SizedBox(height: AppSizes.gap),
          ],
          TestId(
            TestIds.hatchingNewBatchButton,
            merge: true,
            child: FilledButton.icon(
              onPressed: () => _newBatch(context, group),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New batch'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          if (past.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            Text('Past batches', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (int i = 0; i < past.length; i++) ...<Widget>[
              _PastBatchRow(number: i + 1, batch: past[i]),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActiveBatchCard extends StatelessWidget {
  const _ActiveBatchCard({
    required this.number,
    required this.type,
    required this.batch,
    required this.onRecord,
  });

  final int number;
  final AnimalType type;
  final HatchBatch batch;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool passed = AnimalRules.hatchDayPassed(type, batch.startedOn);
    final String cardId = TestIds.hatchingBatchItem(number);

    return TestId(
      cardId,
      container: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TestId(
                      TestIds.hatchingBatchItemTitle(number),
                      child: Text(batch.title, style: textTheme.titleMedium),
                    ),
                  ),
                  TestId(
                    TestIds.hatchingBatchItemDayChip(number),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: passed
                            ? colors.background
                            : colors.secondarySoft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: passed ? colors.border : colors.secondarySoft,
                          width: AppSizes.borderWidth,
                        ),
                      ),
                      child: Text(
                        passed
                            ? 'Hatch day passed'
                            : AnimalRules.dayChipText(type, batch.startedOn),
                        style: textTheme.labelSmall?.copyWith(
                          color: passed
                              ? colors.warningText
                              : colors.onSecondarySoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                HatchingTab.batchLine(type, batch),
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: AnimalRules.hatchProgress(type, batch.startedOn),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              MilestoneTimeline(
                cardId: cardId,
                milestones: AnimalRules.hatchMilestones(type, batch.startedOn),
                showDates: false,
              ),
              const SizedBox(height: 8),
              TestId(
                TestIds.hatchingBatchItemRecordButton(number),
                merge: true,
                child: OutlinedButton(
                  onPressed: onRecord,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Record result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastBatchRow extends StatelessWidget {
  const _PastBatchRow({required this.number, required this.batch});

  final int number;
  final HatchBatch batch;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.hatchingPastItem(number),
      container: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(batch.title, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      HatchingTab.pastLine(batch),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TestId(
                TestIds.hatchingPastItemRate(number),
                child: Text(
                  '${batch.ratePercent}%',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
