import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/animal_models.dart';
import 'package:harvestly/data/animal_rules.dart';
import 'package:harvestly/shared/logic/app_clock.dart';

/// Today for every test in this file, so the day numbers never move.
final DateTime today = DateTime(2026, 11, 24);

DateTime back(int days) => today.subtract(Duration(days: days));

void main() {
  setUp(() => AppClock.useFixed(today));
  tearDown(AppClock.useRealClock);

  group('hatch day numbers', () {
    test('the start day is day 1', () {
      expect(AnimalRules.hatchDayNumber(AnimalType.hens, today), 1);
      expect(AnimalRules.hatchDayNumber(AnimalType.ducks, today), 1);
      expect(AnimalRules.hatchDayNumber(AnimalType.quail, today), 1);
    });

    test('day N is days since the start plus one', () {
      expect(AnimalRules.hatchDayNumber(AnimalType.hens, back(13)), 14);
      expect(AnimalRules.hatchDayNumber(AnimalType.ducks, back(9)), 10);
      expect(AnimalRules.hatchDayNumber(AnimalType.quail, back(5)), 6);
    });

    test('the day number never goes past the total', () {
      expect(AnimalRules.hatchDayNumber(AnimalType.hens, back(40)), 21);
      expect(AnimalRules.hatchDayNumber(AnimalType.ducks, back(40)), 28);
      expect(AnimalRules.hatchDayNumber(AnimalType.quail, back(40)), 17);
    });

    test('the chip reads "Day 14 of 21"', () {
      expect(
        AnimalRules.dayChipText(AnimalType.hens, back(13)),
        'Day 14 of 21',
      );
    });
  });

  group('hatch dates', () {
    test('hatch day is the start plus one less than the total', () {
      expect(
        AnimalRules.hatchDate(AnimalType.hens, today),
        today.add(const Duration(days: 20)),
      );
      expect(
        AnimalRules.hatchDate(AnimalType.ducks, today),
        today.add(const Duration(days: 27)),
      );
      expect(
        AnimalRules.hatchDate(AnimalType.quail, today),
        today.add(const Duration(days: 16)),
      );
    });

    test('a batch started 13 days ago hatches in 7 days', () {
      expect(
        AnimalRules.hatchDate(AnimalType.hens, back(13)),
        today.add(const Duration(days: 7)),
      );
    });

    test('hatch day passed is only true after hatch day', () {
      expect(AnimalRules.hatchDayPassed(AnimalType.hens, back(20)), isFalse);
      expect(AnimalRules.hatchDayPassed(AnimalType.hens, back(21)), isTrue);
    });
  });

  group('pregnancy dates', () {
    test('a goat is due 150 days after mating', () {
      expect(
        AnimalRules.dueDate(AnimalType.goats, today),
        today.add(const Duration(days: 150)),
      );
    });

    test('a cow is due 283 days after mating', () {
      expect(
        AnimalRules.dueDate(AnimalType.cows, today),
        today.add(const Duration(days: 283)),
      );
    });

    test('Lali, mated 236 days ago, has 47 days left', () {
      expect(AnimalRules.daysUntilDue(AnimalType.cows, back(236)), 47);
      expect(
        AnimalRules.daysLeftText(AnimalType.cows, back(236)),
        '47 days left',
      );
    });

    test('one day left is singular', () {
      expect(
        AnimalRules.daysLeftText(AnimalType.cows, back(282)),
        '1 day left',
      );
    });

    test('days left never goes below zero, and the due date can pass', () {
      expect(AnimalRules.daysUntilDue(AnimalType.goats, back(200)), 0);
      expect(AnimalRules.dueDatePassed(AnimalType.goats, back(200)), isTrue);
      expect(AnimalRules.dueDatePassed(AnimalType.goats, back(150)), isFalse);
    });

    test('Lali is 83% of the way through', () {
      final double progress = AnimalRules.pregnancyProgress(
        AnimalType.cows,
        back(236),
      );
      expect((progress * 100).floor(), 83);
    });
  });

  group('milestones', () {
    test('a hen hatch has set eggs, candle, stop turning and hatch day', () {
      final List<Milestone> steps = AnimalRules.hatchMilestones(
        AnimalType.hens,
        today,
      );

      expect(steps.map((Milestone m) => m.label).toList(), <String>[
        'Set eggs',
        'Candle',
        'Stop turning',
        'Hatch day',
      ]);
      expect(steps.map((Milestone m) => m.dayNumber).toList(), <int>[
        1,
        7,
        18,
        21,
      ]);
      expect(steps.first.date, today);
      expect(steps.last.date, today.add(const Duration(days: 20)));
    });

    test('ducks stop turning on day 25 and quail on day 14', () {
      expect(
        AnimalRules.hatchMilestones(
          AnimalType.ducks,
          today,
        ).map((Milestone m) => m.dayNumber).toList(),
        <int>[1, 7, 25, 28],
      );
      expect(
        AnimalRules.hatchMilestones(
          AnimalType.quail,
          today,
        ).map((Milestone m) => m.dayNumber).toList(),
        <int>[1, 7, 14, 17],
      );
    });

    test('a cow pregnancy checks at 90 days and dries off 60 before due', () {
      final List<Milestone> steps = AnimalRules.pregnancyMilestones(
        AnimalType.cows,
        today,
      );
      final DateTime due = today.add(const Duration(days: 283));

      expect(steps.map((Milestone m) => m.label).toList(), <String>[
        'Mated',
        'Check',
        'Dry off',
        'Due',
      ]);
      expect(steps[0].date, today);
      expect(steps[1].date, today.add(const Duration(days: 90)));
      expect(steps[2].date, due.subtract(const Duration(days: 60)));
      expect(steps[3].date, due);
    });

    test('a goat is checked 45 days after mating', () {
      final List<Milestone> steps = AnimalRules.pregnancyMilestones(
        AnimalType.goats,
        today,
      );
      expect(steps[1].date, today.add(const Duration(days: 45)));
    });

    test('a step counts as passed on its own day', () {
      final List<Milestone> steps = AnimalRules.hatchMilestones(
        AnimalType.hens,
        back(6),
      );
      // Day 7 is today.
      expect(steps[1].isPassed, isTrue);
      expect(steps[1].isToday, isTrue);
      expect(steps[2].isPassed, isFalse);
      expect(steps[2].isToday, isFalse);
    });
  });

  group('health task states', () {
    HealthTask taskDue(int daysAgo) =>
        HealthTask(id: 't', title: 'Deworming', dueOn: back(daysAgo));

    test('a due date before today is late', () {
      expect(taskDue(4).state, HealthState.late);
      expect(taskDue(4).stateText, 'Late by 4 days');
    });

    test('one day late is singular', () {
      expect(taskDue(1).stateText, 'Late by 1 day');
    });

    test('a due date of today is due today', () {
      expect(taskDue(0).state, HealthState.dueToday);
      expect(taskDue(0).stateText, 'Due today');
    });

    test('a due date ahead is coming up, with the date', () {
      expect(taskDue(-18).state, HealthState.comingUp);
      expect(taskDue(-18).stateText, 'Coming up · 12 Dec 2026');
    });
  });

  group('young words', () {
    test('cows have calves and goats have kids', () {
      expect(AnimalRules.youngText(AnimalType.cows, 1), '1 calf');
      expect(AnimalRules.youngText(AnimalType.cows, 2), '2 calves');
      expect(AnimalRules.youngText(AnimalType.goats, 1), '1 kid');
      expect(AnimalRules.youngText(AnimalType.goats, 3), '3 kids');
    });

    test('zero young reads None survived', () {
      expect(AnimalRules.youngText(AnimalType.cows, 0), 'None survived');
      expect(AnimalRules.youngText(AnimalType.goats, 0), 'None survived');
    });
  });

  group('unit words', () {
    test('flocks count birds and herds count animals', () {
      expect(AnimalType.hens.countText(24), '24 birds');
      expect(AnimalType.hens.countText(1), '1 bird');
      expect(AnimalType.cows.countText(5), '5 animals');
      expect(AnimalType.cows.countText(1), '1 animal');
    });
  });
}
