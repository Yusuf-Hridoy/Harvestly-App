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
import '../widgets/birth_dialog.dart';
import '../widgets/milestone_timeline.dart';
import '../widgets/pregnancy_form.dart';

/// The Breeding tab, for herds only.
///
/// It is the Hatching tab's twin: running pregnancies with a countdown and
/// a timeline, then the births that already happened.
class BreedingTab extends StatelessWidget {
  const BreedingTab({super.key, required this.groupId});

  final String groupId;

  /// "Cow · Mated 2 Apr 2026 · Due around 10 Jan 2027".
  static String pregnancyLine(AnimalType type, Pregnancy pregnancy) {
    final String animal =
        type.oneWord[0].toUpperCase() + type.oneWord.substring(1);
    return '$animal · Mated ${DateText.dayMonthYear(pregnancy.matedOn)} · '
        'Due around '
        '${DateText.dayMonthYear(AnimalRules.dueDate(type, pregnancy.matedOn))}';
  }

  Future<void> _newPregnancy(BuildContext context, AnimalGroup group) async {
    final NewPregnancy? made = await PregnancyForm.open(context);
    if (made == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().addPregnancy(
      groupId: group.id,
      animalName: made.animalName,
      matedOn: made.matedOn,
    );
    AppSnackbar.showOn(messenger, 'Pregnancy added for ${made.animalName}.');
  }

  Future<void> _recordBirth(
    BuildContext context,
    AnimalGroup group,
    Pregnancy pregnancy,
  ) async {
    final BirthResult? birth = await BirthDialog.show(
      context,
      matedOn: pregnancy.matedOn,
    );
    if (birth == null || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<FarmRepository>().finishPregnancy(
      groupId: group.id,
      pregnancyId: pregnancy.id,
      young: birth.young,
      bornOn: birth.bornOn,
    );
    AppSnackbar.showOn(messenger, 'Birth saved for ${pregnancy.animalName}.');
  }

  @override
  Widget build(BuildContext context) {
    final FarmRepository repository = context.watch<FarmRepository>();
    final AnimalGroup? group = repository.groupById(groupId);
    if (group == null) return const SizedBox.shrink();

    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<Pregnancy> active = group.activePregnancies;
    final List<Pregnancy> past = group.pastBirths;

    return TestId(
      TestIds.breedingTab,
      container: true,
      child: ListView(
        key: const PageStorageKey<String>('breeding_tab'),
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
                TestIds.breedingEmptyText,
                child: Text(
                  'No pregnancies yet.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
          for (int i = 0; i < active.length; i++) ...<Widget>[
            _ActivePregnancyCard(
              number: i + 1,
              type: group.type,
              pregnancy: active[i],
              onRecord: () => _recordBirth(context, group, active[i]),
            ),
            const SizedBox(height: AppSizes.gap),
          ],
          TestId(
            TestIds.breedingNewButton,
            merge: true,
            child: FilledButton.icon(
              onPressed: () => _newPregnancy(context, group),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New pregnancy'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          if (past.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            Text('Past births', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (int i = 0; i < past.length; i++) ...<Widget>[
              _PastBirthRow(
                number: i + 1,
                type: group.type,
                pregnancy: past[i],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActivePregnancyCard extends StatelessWidget {
  const _ActivePregnancyCard({
    required this.number,
    required this.type,
    required this.pregnancy,
    required this.onRecord,
  });

  final int number;
  final AnimalType type;
  final Pregnancy pregnancy;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool passed = AnimalRules.dueDatePassed(type, pregnancy.matedOn);
    final String cardId = TestIds.breedingItem(number);

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
                      TestIds.breedingItemTitle(number),
                      child: Text(
                        '${pregnancy.animalName} · pregnant',
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TestId(
                    TestIds.breedingItemDaysChip(number),
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
                            ? 'Due date passed'
                            : AnimalRules.daysLeftText(type, pregnancy.matedOn),
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
                BreedingTab.pregnancyLine(type, pregnancy),
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: AnimalRules.pregnancyProgress(type, pregnancy.matedOn),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              MilestoneTimeline(
                cardId: cardId,
                milestones: AnimalRules.pregnancyMilestones(
                  type,
                  pregnancy.matedOn,
                ),
                showDates: true,
              ),
              const SizedBox(height: 8),
              TestId(
                TestIds.breedingItemRecordButton(number),
                merge: true,
                child: OutlinedButton(
                  onPressed: onRecord,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Record birth'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastBirthRow extends StatelessWidget {
  const _PastBirthRow({
    required this.number,
    required this.type,
    required this.pregnancy,
  });

  final int number;
  final AnimalType type;
  final Pregnancy pregnancy;

  @override
  Widget build(BuildContext context) {
    final AppColorSet colors = context.colors;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TestId(
      TestIds.breedingPastItem(number),
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
                    Text(pregnancy.animalName, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Born ${DateText.dayMonthYear(pregnancy.bornOn!)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TestId(
                TestIds.breedingPastItemYoung(number),
                child: Text(
                  AnimalRules.youngText(type, pregnancy.young!),
                  style: textTheme.titleSmall?.copyWith(
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
