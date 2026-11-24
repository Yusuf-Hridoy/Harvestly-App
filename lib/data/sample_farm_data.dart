import '../shared/logic/app_clock.dart';
import 'animal_models.dart';
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
/// Fields, crops, the harvest card, the eggs count and the animal health card
/// now come from the saved farm data, so they are not in here any more.
class FarmData {
  const FarmData({
    required this.weather,
    required this.profitThisMonth,
    this.tasks = const <FarmTask>[],
  });

  final FarmWeather weather;

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

  /// How many days of logs a new sample fills in.
  static const int sampleLogDays = 30;

  /// A date counted back from today, so every run shows the same numbers.
  static DateTime _back(int days) =>
      AppClock.today().subtract(Duration(days: days));

  /// Thirty days of logs: [lastSeven] from T-6 to today, and [older]
  /// repeating from T-29 up to T-7.
  static List<DayLog> _logs(List<double> lastSeven, List<double> older) {
    final List<DayLog> out = <DayLog>[];
    for (int daysAgo = sampleLogDays - 1; daysAgo >= 7; daysAgo--) {
      out.add(
        DayLog(
          date: _back(daysAgo),
          amount: older[(sampleLogDays - 1 - daysAgo) % older.length],
        ),
      );
    }
    for (int i = 0; i < lastSeven.length; i++) {
      out.add(DayLog(date: _back(6 - i), amount: lastSeven[i]));
    }
    return out;
  }

  /// The animal groups an account starts with, and goes back to when the
  /// user taps Reset demo data.
  ///
  /// Every date is counted back from today, except the start dates, which
  /// are fixed so the "since" line never moves.
  static List<AnimalGroup> startingGroups(String accountId) {
    switch (accountId) {
      case 'farmer':
        return _farmerGroups();
      case 'poultry':
        return _poultryGroups();
      default:
        return <AnimalGroup>[];
    }
  }

  static List<AnimalGroup> _farmerGroups() => <AnimalGroup>[
    AnimalGroup(
      id: 'group-1',
      name: 'Flock A',
      type: AnimalType.hens,
      count: 24,
      startedOn: DateTime(2026, 2, 1),
      logs: _logs(<double>[16, 17, 15, 18, 16, 17, 18], <double>[15, 16, 17]),
      batches: <HatchBatch>[
        HatchBatch(
          id: 'batch-1',
          number: 1,
          startedOn: _back(86),
          eggs: 12,
          hatched: 8,
          resultOn: _back(65),
        ),
        HatchBatch(
          id: 'batch-2',
          number: 2,
          startedOn: _back(55),
          eggs: 10,
          hatched: 8,
          resultOn: _back(34),
        ),
        HatchBatch(id: 'batch-3', number: 3, startedOn: _back(13), eggs: 10),
      ],
      tasks: <HealthTask>[
        HealthTask(
          id: 'task-1',
          title: 'Newcastle booster',
          dueOn: AppClock.today(),
        ),
        HealthTask(id: 'task-2', title: 'Deworming', dueOn: _back(-18)),
        HealthTask(
          id: 'task-3',
          title: 'Fowl pox vaccine',
          dueOn: _back(23),
          doneOn: _back(23),
        ),
      ],
      losses: <LossRecord>[
        LossRecord(
          id: 'loss-1',
          amount: 2,
          reason: LossReason.sickness,
          date: _back(37),
        ),
      ],
    ),
    AnimalGroup(
      id: 'group-2',
      name: 'Duck pond',
      type: AnimalType.ducks,
      count: 6,
      startedOn: DateTime(2026, 6, 15),
      logs: _logs(<double>[4, 3, 4, 5, 4, 3, 4], <double>[4]),
    ),
    AnimalGroup(
      id: 'group-3',
      name: 'Goat herd',
      type: AnimalType.goats,
      count: 5,
      startedOn: DateTime(2026, 3, 1),
      logs: _logs(<double>[3.0, 3.5, 3.0, 3.5, 3.0, 3.5, 3.5], <double>[3.0]),
      tasks: <HealthTask>[
        HealthTask(id: 'task-4', title: 'Deworming', dueOn: _back(2)),
      ],
    ),
    AnimalGroup(
      id: 'group-4',
      name: 'Cow shed',
      type: AnimalType.cows,
      count: 2,
      startedOn: DateTime(2025, 1, 1),
      logs: _logs(
        <double>[13.5, 14.0, 12.5, 14.5, 13.0, 14.0, 14.0],
        <double>[13.0],
      ),
      pregnancies: <Pregnancy>[
        Pregnancy(id: 'preg-1', animalName: 'Lali', matedOn: _back(236)),
        Pregnancy(
          id: 'preg-2',
          animalName: 'Shyamoli',
          matedOn: _back(540),
          young: 1,
          bornOn: _back(257),
        ),
      ],
      tasks: <HealthTask>[
        HealthTask(
          id: 'task-5',
          title: 'Foot-and-mouth vaccine',
          dueOn: _back(4),
        ),
        HealthTask(id: 'task-6', title: 'Hoof check', dueOn: _back(-26)),
        HealthTask(
          id: 'task-7',
          title: 'Deworming',
          dueOn: _back(45),
          doneOn: _back(45),
        ),
      ],
    ),
  ];

  static List<AnimalGroup> _poultryGroups() => <AnimalGroup>[
    AnimalGroup(
      id: 'group-1',
      name: 'Backyard flock',
      type: AnimalType.hens,
      count: 30,
      startedOn: DateTime(2026, 5, 1),
      logs: _logs(<double>[24, 25, 27, 26, 25, 26, 26], <double>[25]),
      batches: <HatchBatch>[
        HatchBatch(id: 'batch-1', number: 1, startedOn: _back(5), eggs: 12),
      ],
      tasks: <HealthTask>[
        HealthTask(id: 'task-1', title: 'Fowl pox vaccine', dueOn: _back(-3)),
      ],
    ),
  ];
}
