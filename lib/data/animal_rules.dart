import '../shared/logic/app_clock.dart';
import 'animal_models.dart';

/// One step on a hatching or breeding timeline.
class Milestone {
  const Milestone({required this.label, required this.date, this.dayNumber});

  /// "Candle", "Dry off", "Due" and so on.
  final String label;

  /// The day this step falls on.
  final DateTime date;

  /// The day number inside a hatch, counting the start day as 1. Null for a
  /// pregnancy, which shows dates instead of day numbers.
  final int? dayNumber;

  /// True once the step's day has arrived or gone by.
  bool get isPassed => !date.isAfter(AppClock.today());

  /// True when the step falls on today.
  bool get isToday => AppClock.dateOnly(date) == AppClock.today();
}

/// How long a hatch or a pregnancy takes, and the steps along the way.
///
/// Every date rule for animals lives here, so the tabs only draw what this
/// file works out.
class AnimalRules {
  const AnimalRules._();

  /// How many days from setting the eggs to hatch day, or from mating to the
  /// due date.
  static const Map<AnimalType, int> cycleDays = <AnimalType, int>{
    AnimalType.hens: 21,
    AnimalType.ducks: 28,
    AnimalType.quail: 17,
    AnimalType.goats: 150,
    AnimalType.cows: 283,
  };

  /// How long before a hatch the eggs stop being turned, as a day number.
  static const Map<AnimalType, int> _stopTurningDay = <AnimalType, int>{
    AnimalType.hens: 18,
    AnimalType.ducks: 25,
    AnimalType.quail: 14,
  };

  /// How many days after mating the animal is checked.
  static const Map<AnimalType, int> _checkAfterMating = <AnimalType, int>{
    AnimalType.goats: 45,
    AnimalType.cows: 90,
  };

  /// Eggs are candled on this day of a hatch, whatever the bird.
  static const int candleDay = 7;

  /// A milking animal is dried off this many days before it is due.
  static const int dryOffBeforeDue = 60;

  /// The whole length of a cycle for a type.
  static int daysFor(AnimalType type) => cycleDays[type] ?? 0;

  /// Which day of the hatch today is, counting the start day as 1.
  ///
  /// It never goes above the total, so a batch left running past hatch day
  /// still reads "Day 21 of 21".
  static int hatchDayNumber(AnimalType type, DateTime startedOn) {
    final int total = daysFor(type);
    final int since = AppClock.daysBetween(startedOn, AppClock.today());
    return (since + 1).clamp(1, total);
  }

  /// The day the eggs are due to hatch. Day 1 is the start, so hatch day is
  /// the start plus one less than the total.
  static DateTime hatchDate(AnimalType type, DateTime startedOn) =>
      AppClock.dateOnly(startedOn).add(Duration(days: daysFor(type) - 1));

  /// True once hatch day has gone by.
  static bool hatchDayPassed(AnimalType type, DateTime startedOn) =>
      AppClock.today().isAfter(hatchDate(type, startedOn));

  /// How far along a hatch is, from 0.0 to 1.0.
  static double hatchProgress(AnimalType type, DateTime startedOn) {
    final int total = daysFor(type);
    if (total <= 0) return 0;
    return (hatchDayNumber(type, startedOn) / total).clamp(0.0, 1.0);
  }

  /// The day the young are due.
  static DateTime dueDate(AnimalType type, DateTime matedOn) =>
      AppClock.dateOnly(matedOn).add(Duration(days: daysFor(type)));

  /// How many days are left until the due date. Never below 0.
  static int daysUntilDue(AnimalType type, DateTime matedOn) {
    final int left = AppClock.daysBetween(
      AppClock.today(),
      dueDate(type, matedOn),
    );
    return left < 0 ? 0 : left;
  }

  /// True once the due date has gone by.
  static bool dueDatePassed(AnimalType type, DateTime matedOn) =>
      AppClock.today().isAfter(dueDate(type, matedOn));

  /// How far along a pregnancy is, from 0.0 to 1.0, rounded down by day.
  static double pregnancyProgress(AnimalType type, DateTime matedOn) {
    final int total = daysFor(type);
    if (total <= 0) return 0;
    final int since = AppClock.daysBetween(matedOn, AppClock.today());
    return (since / total).clamp(0.0, 1.0);
  }

  /// "47 days left" or "1 day left".
  static String daysLeftText(AnimalType type, DateTime matedOn) {
    final int left = daysUntilDue(type, matedOn);
    return left == 1 ? '1 day left' : '$left days left';
  }

  /// "Day 14 of 21".
  static String dayChipText(AnimalType type, DateTime startedOn) =>
      'Day ${hatchDayNumber(type, startedOn)} of ${daysFor(type)}';

  /// The four steps of a hatch, in date order.
  static List<Milestone> hatchMilestones(AnimalType type, DateTime startedOn) {
    final DateTime start = AppClock.dateOnly(startedOn);
    final int total = daysFor(type);
    final int stopTurning = _stopTurningDay[type] ?? total;

    Milestone step(String label, int day) => Milestone(
      label: label,
      date: start.add(Duration(days: day - 1)),
      dayNumber: day,
    );

    return <Milestone>[
      step('Set eggs', 1),
      step('Candle', candleDay),
      step('Stop turning', stopTurning),
      step('Hatch day', total),
    ];
  }

  /// The four steps of a pregnancy, in date order.
  static List<Milestone> pregnancyMilestones(
    AnimalType type,
    DateTime matedOn,
  ) {
    final DateTime mated = AppClock.dateOnly(matedOn);
    final DateTime due = dueDate(type, mated);
    final int check = _checkAfterMating[type] ?? 0;

    return <Milestone>[
      Milestone(label: 'Mated', date: mated),
      Milestone(
        label: 'Check',
        date: mated.add(Duration(days: check)),
      ),
      Milestone(
        label: 'Dry off',
        date: due.subtract(const Duration(days: dryOffBeforeDue)),
      ),
      Milestone(label: 'Due', date: due),
    ];
  }

  /// "1 calf", "2 calves", "1 kid", "2 kids" or "None survived".
  static String youngText(AnimalType type, int young) {
    if (young <= 0) return 'None survived';
    final String word = type == AnimalType.cows
        ? (young == 1 ? 'calf' : 'calves')
        : (young == 1 ? 'kid' : 'kids');
    return '$young $word';
  }
}
