import '../shared/logic/app_clock.dart';
import 'animal_models.dart';
import 'farm_models.dart';
import 'task_models.dart';

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
/// Fields, crops, the harvest card, the eggs count, the animal health card
/// and, since Phase 4, the tasks all come from the saved farm data, so they
/// are not in here any more.
class FarmData {
  const FarmData({required this.weather, required this.profitThisMonth});

  final FarmWeather weather;

  /// Already formatted, for example "Tk 12,400".
  final String profitThisMonth;
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
  );

  static const FarmData poultry = FarmData(
    weather: _weather,
    profitThisMonth: 'Tk 5,800',
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

  /// A date and time counted from today, so the sample reads the same on
  /// every run. [daysFromToday] is negative for the past.
  static DateTime _at(int daysFromToday, int hour, int minute) {
    final DateTime day = AppClock.today().add(Duration(days: daysFromToday));
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  /// The tasks an account starts with, and goes back to when the user taps
  /// Reset demo data.
  static List<FarmTask> startingTasks(String accountId) {
    switch (accountId) {
      case 'farmer':
        return _farmerTasks();
      case 'poultry':
        return _poultryTasks();
      default:
        return <FarmTask>[];
    }
  }

  static TaskLink _field(String id) =>
      TaskLink(kind: TaskLinkKind.field, id: id);

  static TaskLink _group(String id) =>
      TaskLink(kind: TaskLinkKind.group, id: id);

  static List<FarmTask> _farmerTasks() => <FarmTask>[
    FarmTask(
      id: 'task-1',
      title: 'Spray beans',
      dueAt: _at(-2, 7, 0),
      link: _field('field-3'),
    ),
    FarmTask(
      id: 'task-2',
      title: 'Water tomato beds',
      dueAt: _at(0, 7, 0),
      repeat: Repeat.daily,
      link: _field('field-2'),
    ),
    FarmTask(
      id: 'task-3',
      title: 'Collect eggs',
      dueAt: _at(0, 8, 0),
      repeat: Repeat.daily,
      link: _group('group-1'),
    ),
    FarmTask(
      id: 'task-4',
      title: 'Clean water pots',
      note: 'Scrub the green off the sides',
      dueAt: _at(0, 17, 0),
      repeat: Repeat.weekly,
      link: _group('group-2'),
      reminder: ReminderOffset.hourBefore,
    ),
    FarmTask(
      id: 'task-5',
      title: 'Buy chicken feed',
      dueAt: _at(2, 10, 0),
      reminder: ReminderOffset.dayBefore,
    ),
    FarmTask(
      id: 'task-6',
      title: 'Check fence',
      dueAt: _at(5, 9, 0),
      repeat: Repeat.weekly,
      link: _field('field-4'),
    ),
    FarmTask(
      id: 'task-7',
      title: 'Vitamin water for hens',
      dueAt: _at(0, 7, 30),
      link: _group('group-1'),
      doneAt: _at(0, 7, 10),
    ),
    FarmTask(
      id: 'task-8',
      title: 'Weed Field 1',
      dueAt: _at(-1, 9, 0),
      link: _field('field-1'),
      doneAt: _at(-1, 9, 0),
    ),
    FarmTask(
      id: 'task-9',
      title: 'Fix coop door',
      dueAt: _at(-3, 16, 0),
      link: _group('group-1'),
      doneAt: _at(-3, 16, 0),
    ),
    FarmTask(
      id: 'task-10',
      title: 'Order seeds',
      dueAt: _at(-6, 11, 0),
      doneAt: _at(-6, 11, 0),
    ),
  ];

  static List<FarmTask> _poultryTasks() => <FarmTask>[
    FarmTask(
      id: 'task-1',
      title: 'Collect eggs',
      dueAt: _at(0, 8, 0),
      repeat: Repeat.daily,
      link: _group('group-1'),
    ),
    FarmTask(
      id: 'task-2',
      title: 'Clean the water pots',
      dueAt: _at(0, 16, 0),
      link: _group('group-1'),
    ),
    FarmTask(
      id: 'task-3',
      title: 'Check the hatching tray',
      dueAt: _at(0, 9, 0),
      link: _group('group-1'),
      doneAt: _at(0, 9, 0),
    ),
  ];
}
