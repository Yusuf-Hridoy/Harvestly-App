/// One job on today's list.
class FarmTask {
  const FarmTask({
    required this.title,
    required this.detail,
    this.startsDone = false,
    this.detailIsWarning = false,
  });

  /// What to do, for example "Water tomato beds".
  final String title;

  /// Where and when, for example "Field 2 - Morning".
  final String detail;

  /// Whether the task is already ticked when the screen opens.
  final bool startsDone;

  /// Whether the detail line is a warning and should use the warning color.
  final bool detailIsWarning;
}

/// The crop that is closest to picking.
class HarvestSoon {
  const HarvestSoon({
    required this.crop,
    required this.field,
    required this.progress,
    required this.daysLeft,
  });

  final String crop;
  final String field;

  /// How far along the crop is, from 0.0 to 1.0.
  final double progress;

  final int daysLeft;

  /// The progress as a whole number, for example 80.
  int get progressPercent => (progress * 100).round();
}

/// The four numbers on the home screen.
class FarmStats {
  const FarmStats({
    required this.fields,
    required this.cropsGrowing,
    required this.eggsToday,
    required this.profitThisMonth,
  });

  final int fields;
  final int cropsGrowing;
  final int eggsToday;

  /// Already formatted, for example "Tk 12,400".
  final String profitThisMonth;
}

/// Today's weather line. Static text in Phase 1.
class FarmWeather {
  const FarmWeather({required this.summary, required this.warning});

  /// For example "31C, sunny".
  final String summary;

  /// For example "Rain tomorrow. Delay spraying the beans."
  final String warning;
}

/// Everything the home screen needs for one account.
class FarmData {
  const FarmData({
    required this.isEmpty,
    this.stats,
    this.weather,
    this.tasks = const <FarmTask>[],
    this.harvest,
  });

  /// True for a brand new account with nothing on the farm yet.
  final bool isEmpty;

  final FarmStats? stats;
  final FarmWeather? weather;
  final List<FarmTask> tasks;

  /// Null when the account has no crops, which hides the harvest card.
  final HarvestSoon? harvest;
}

/// Sample home screen data for each demo account.
class SampleFarmData {
  const SampleFarmData._();

  static const FarmWeather _weather = FarmWeather(
    summary: '31°C, sunny',
    warning: 'Rain tomorrow. Delay spraying the beans.',
  );

  static const FarmData farmer = FarmData(
    isEmpty: false,
    weather: _weather,
    stats: FarmStats(
      fields: 4,
      cropsGrowing: 7,
      eggsToday: 18,
      profitThisMonth: 'Tk 12,400',
    ),
    harvest: HarvestSoon(
      crop: 'Tomato',
      field: 'Field 2',
      progress: 0.8,
      daysLeft: 12,
    ),
    tasks: <FarmTask>[
      FarmTask(title: 'Water tomato beds', detail: 'Field 2 · Morning'),
      FarmTask(
        title: 'Vitamin water for hens',
        detail: 'Flock A',
        startsDone: true,
      ),
      FarmTask(
        title: 'Spray beans',
        detail: 'Moved to Thursday because of rain',
        detailIsWarning: true,
      ),
    ],
  );

  static const FarmData poultry = FarmData(
    isEmpty: false,
    weather: _weather,
    stats: FarmStats(
      fields: 0,
      cropsGrowing: 0,
      eggsToday: 26,
      profitThisMonth: 'Tk 5,800',
    ),
    tasks: <FarmTask>[
      FarmTask(title: 'Collect eggs', detail: 'Flock A · Morning'),
      FarmTask(title: 'Clean the water pots', detail: 'Coop'),
      FarmTask(
        title: 'Check the hatching tray',
        detail: 'Batch 3',
        startsDone: true,
      ),
    ],
  );

  static const FarmData newFarm = FarmData(isEmpty: true);

  /// Picks the sample data for a demo account id.
  static FarmData forAccount(String accountId) {
    switch (accountId) {
      case 'farmer':
        return farmer;
      case 'poultry':
        return poultry;
      default:
        return newFarm;
    }
  }
}
