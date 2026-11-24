import '../shared/logic/app_clock.dart';
import 'farm_models.dart';

/// One job on today's list. Still sample text in Phase 2.
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

/// Today's weather line. Still sample text in Phase 2.
class FarmWeather {
  const FarmWeather({required this.summary, required this.warning});

  /// For example "31C, sunny".
  final String summary;

  /// For example "Rain tomorrow. Delay spraying the beans."
  final String warning;
}

/// The parts of the home screen that are still sample values.
///
/// Fields, crops and the harvest card now come from the saved farm data, so
/// they are not in here any more.
class FarmData {
  const FarmData({
    required this.weather,
    required this.eggsToday,
    required this.profitThisMonth,
    this.tasks = const <FarmTask>[],
  });

  final FarmWeather weather;

  final int eggsToday;

  /// Already formatted, for example "Tk 12,400".
  final String profitThisMonth;

  final List<FarmTask> tasks;
}

/// Sample data for each demo account: the home screen values, and the fields
/// and crops the account starts with.
class SampleFarmData {
  const SampleFarmData._();

  static const FarmWeather _weather = FarmWeather(
    summary: '31°C, sunny',
    warning: 'Rain tomorrow. Delay spraying the beans.',
  );

  static const FarmData farmer = FarmData(
    weather: _weather,
    eggsToday: 18,
    profitThisMonth: 'Tk 12,400',
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
    weather: _weather,
    eggsToday: 26,
    profitThisMonth: 'Tk 5,800',
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

  static const FarmData newFarm = FarmData(
    weather: _weather,
    eggsToday: 0,
    profitThisMonth: 'Tk 0',
  );

  /// Picks the home screen sample values for a demo account id.
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

  /// The fields and crops an account starts with, and goes back to when the
  /// user taps Reset demo data.
  ///
  /// Every planting date is counted back from today, so the days-left numbers
  /// are the same on every run.
  static List<Field> startingFields(String accountId) {
    if (accountId != 'farmer') return <Field>[];

    Crop plant(String id, String typeId, int daysAgo, int plants) => Crop(
      id: id,
      typeId: typeId,
      plantedOn: AppClock.today().subtract(Duration(days: daysAgo)),
      plants: plants,
    );

    return <Field>[
      Field(
        id: 'field-1',
        name: 'Field 1 · North plot',
        sizeAcres: 0.6,
        soil: SoilType.clay,
        corners: const <MapPoint>[
          MapPoint(x: 0.1, y: 0.15),
          MapPoint(x: 0.9, y: 0.15),
          MapPoint(x: 0.9, y: 0.9),
          MapPoint(x: 0.1, y: 0.9),
        ],
        crops: <Crop>[
          plant('crop-1', 'spinach', 18, 30),
          plant('crop-2', 'coriander', 10, 50),
          plant('crop-3', 'radish', 5, 60),
        ],
      ),
      Field(
        id: 'field-2',
        name: 'Field 2 · South bed',
        sizeAcres: 0.4,
        soil: SoilType.loam,
        note: 'Near the water pump',
        corners: const <MapPoint>[
          MapPoint(x: 0.1, y: 0.25),
          MapPoint(x: 0.9, y: 0.25),
          MapPoint(x: 0.9, y: 0.75),
          MapPoint(x: 0.1, y: 0.75),
        ],
        crops: <Crop>[
          plant('crop-4', 'tomato', 53, 40),
          plant('crop-5', 'green_chili', 36, 25),
        ],
      ),
      Field(
        id: 'field-3',
        name: 'Field 3 · Bean rows',
        sizeAcres: 0.3,
        soil: SoilType.sandy,
        corners: const <MapPoint>[
          MapPoint(x: 0.2, y: 0.25),
          MapPoint(x: 0.8, y: 0.25),
          MapPoint(x: 0.8, y: 0.75),
          MapPoint(x: 0.2, y: 0.75),
        ],
        crops: <Crop>[
          plant('crop-6', 'long_beans', 8, 30),
          plant('crop-7', 'bush_beans', 9, 30),
        ],
      ),
      Field(
        id: 'field-4',
        name: 'Field 4 · Pond side',
        sizeAcres: 0.5,
        soil: SoilType.silt,
        corners: const <MapPoint>[
          MapPoint(x: 0.1, y: 0.2),
          MapPoint(x: 0.9, y: 0.1),
          MapPoint(x: 0.9, y: 0.85),
          MapPoint(x: 0.1, y: 0.8),
        ],
        harvests: <Harvest>[
          Harvest(
            id: 'harvest-1',
            typeId: 'lettuce',
            plantedOn: AppClock.today().subtract(const Duration(days: 65)),
            harvestedOn: AppClock.today().subtract(const Duration(days: 20)),
            amountKg: 12.5,
          ),
        ],
      ),
    ];
  }
}
