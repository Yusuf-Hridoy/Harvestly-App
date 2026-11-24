import '../shared/logic/app_clock.dart';
import '../shared/logic/date_text.dart';
import 'animal_rules.dart';

/// Whether a group is a flock of birds or a herd of animals.
enum AnimalKind {
  /// Hens, ducks and quail. They lay eggs and hatch chicks.
  flock,

  /// Goats and cows. They give milk and carry young.
  herd,
}

/// The five kinds of animal a group can hold.
enum AnimalType {
  hens('Hens', AnimalKind.flock, 'hen'),
  ducks('Ducks', AnimalKind.flock, 'duck'),
  quail('Quail', AnimalKind.flock, 'quail'),
  goats('Goats', AnimalKind.herd, 'goat'),
  cows('Cows', AnimalKind.herd, 'cow');

  const AnimalType(this.label, this.kind, this.oneWord);

  /// The name on screen, for example "Hens".
  final String label;

  /// Flock or herd. It decides which three tabs the group detail shows.
  final AnimalKind kind;

  /// One animal of this type, for example "hen". Used in "10 hen eggs" and
  /// in "Cow · Mated 2 Apr 2026".
  final String oneWord;

  /// True for hens, ducks and quail.
  bool get isFlock => kind == AnimalKind.flock;

  /// "bird" for a flock, "animal" for a herd.
  String get unitSingular => isFlock ? 'bird' : 'animal';

  /// "birds" for a flock, "animals" for a herd.
  String get unitPlural => isFlock ? 'birds' : 'animals';

  /// "24 birds" or "1 animal".
  String countText(int count) =>
      '$count ${count == 1 ? unitSingular : unitPlural}';

  /// The animal type saved under this name, or Hens when it is unknown.
  static AnimalType fromName(String name) {
    for (final AnimalType type in AnimalType.values) {
      if (type.name == name) return type;
    }
    return AnimalType.hens;
  }
}

/// How many eggs or litres of milk one day brought in.
///
/// A group has at most one log per date. Saving an amount for a date that
/// already has one replaces it.
class DayLog {
  const DayLog({required this.date, required this.amount});

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
    date: DateTime.parse(json['date'] as String),
    amount: (json['amount'] as num).toDouble(),
  );

  /// The day this amount belongs to, with the time of day removed.
  final DateTime date;

  /// Eggs as a whole number, milk in litres with 1 decimal.
  final double amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': AppClock.dateOnly(date).toIso8601String(),
    'amount': amount,
  };
}

/// One tray of eggs set to hatch.
class HatchBatch {
  const HatchBatch({
    required this.id,
    required this.number,
    required this.startedOn,
    required this.eggs,
    this.hatched,
    this.resultOn,
  });

  factory HatchBatch.fromJson(Map<String, dynamic> json) => HatchBatch(
    id: json['id'] as String,
    number: (json['number'] as num).toInt(),
    startedOn: DateTime.parse(json['startedOn'] as String),
    eggs: (json['eggs'] as num).toInt(),
    hatched: (json['hatched'] as num?)?.toInt(),
    resultOn: json['resultOn'] == null
        ? null
        : DateTime.parse(json['resultOn'] as String),
  );

  final String id;

  /// 1, 2, 3 and so on, counting up inside the group.
  final int number;

  final DateTime startedOn;

  /// How many eggs went in.
  final int eggs;

  /// How many hatched, or null while the batch is still running.
  final int? hatched;

  /// The day the result was recorded, or null while it is still running.
  final DateTime? resultOn;

  /// True once the result has been recorded.
  bool get isDone => hatched != null;

  /// "Batch 3".
  String get title => 'Batch $number';

  /// "8 of 10 hatched", only once the result is in.
  String get resultText => '$hatched of $eggs hatched';

  /// How many out of a hundred hatched, rounded down.
  int get ratePercent => eggs <= 0 ? 0 : ((hatched ?? 0) * 100 ~/ eggs);

  HatchBatch copyWith({int? hatched, DateTime? resultOn}) => HatchBatch(
    id: id,
    number: number,
    startedOn: startedOn,
    eggs: eggs,
    hatched: hatched ?? this.hatched,
    resultOn: resultOn ?? this.resultOn,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'number': number,
    'startedOn': AppClock.dateOnly(startedOn).toIso8601String(),
    'eggs': eggs,
    'hatched': hatched,
    'resultOn': resultOn == null
        ? null
        : AppClock.dateOnly(resultOn!).toIso8601String(),
  };
}

/// One animal carrying young.
class Pregnancy {
  const Pregnancy({
    required this.id,
    required this.animalName,
    required this.matedOn,
    this.young,
    this.bornOn,
  });

  factory Pregnancy.fromJson(Map<String, dynamic> json) => Pregnancy(
    id: json['id'] as String,
    animalName: json['animalName'] as String,
    matedOn: DateTime.parse(json['matedOn'] as String),
    young: (json['young'] as num?)?.toInt(),
    bornOn: json['bornOn'] == null
        ? null
        : DateTime.parse(json['bornOn'] as String),
  );

  final String id;

  /// The animal's name or ear tag. It is only a label.
  final String animalName;

  final DateTime matedOn;

  /// How many young were born, or null while the animal is still pregnant.
  /// Zero means none survived.
  final int? young;

  final DateTime? bornOn;

  /// True once the birth has been recorded.
  bool get isDone => young != null;

  Pregnancy copyWith({int? young, DateTime? bornOn}) => Pregnancy(
    id: id,
    animalName: animalName,
    matedOn: matedOn,
    young: young ?? this.young,
    bornOn: bornOn ?? this.bornOn,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'animalName': animalName,
    'matedOn': AppClock.dateOnly(matedOn).toIso8601String(),
    'young': young,
    'bornOn': bornOn == null
        ? null
        : AppClock.dateOnly(bornOn!).toIso8601String(),
  };
}

/// Where an open health task sits against today's date.
enum HealthState {
  /// The due date has gone by.
  late,

  /// The due date is today.
  dueToday,

  /// The due date is still ahead.
  comingUp,
}

/// One job to keep the animals well, for example a vaccine.
class HealthTask {
  const HealthTask({
    required this.id,
    required this.title,
    required this.dueOn,
    this.doneOn,
  });

  factory HealthTask.fromJson(Map<String, dynamic> json) => HealthTask(
    id: json['id'] as String,
    title: json['title'] as String,
    dueOn: DateTime.parse(json['dueOn'] as String),
    doneOn: json['doneOn'] == null
        ? null
        : DateTime.parse(json['doneOn'] as String),
  );

  final String id;

  /// What to do, for example "Newcastle booster".
  final String title;

  final DateTime dueOn;

  /// The day it was marked done, or null while it is still open.
  final DateTime? doneOn;

  /// True once the task has been marked as done.
  bool get isDone => doneOn != null;

  /// Days from today to the due date. Negative when the task is late.
  int get daysFromToday => AppClock.daysBetween(AppClock.today(), dueOn);

  /// Late, due today or coming up.
  HealthState get state {
    final int days = daysFromToday;
    if (days < 0) return HealthState.late;
    if (days == 0) return HealthState.dueToday;
    return HealthState.comingUp;
  }

  /// How many days late the task is. Zero when it is not late.
  int get daysLate => daysFromToday < 0 ? -daysFromToday : 0;

  /// "Late by 4 days", "Due today" or "Coming up · 12 Dec 2026".
  String get stateText {
    switch (state) {
      case HealthState.late:
        return daysLate == 1 ? 'Late by 1 day' : 'Late by $daysLate days';
      case HealthState.dueToday:
        return 'Due today';
      case HealthState.comingUp:
        return 'Coming up · ${DateText.dayMonthYear(dueOn)}';
    }
  }

  HealthTask copyWith({DateTime? doneOn}) => HealthTask(
    id: id,
    title: title,
    dueOn: dueOn,
    doneOn: doneOn ?? this.doneOn,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'dueOn': AppClock.dateOnly(dueOn).toIso8601String(),
    'doneOn': doneOn == null
        ? null
        : AppClock.dateOnly(doneOn!).toIso8601String(),
  };
}

/// Why animals left the group.
enum LossReason {
  sickness('Sickness'),
  predator('Predator'),
  accident('Accident'),
  sold('Sold'),
  other('Other');

  const LossReason(this.label);

  /// The reason on screen, for example "Predator".
  final String label;

  /// The reason saved under this name, or Other when it is unknown.
  static LossReason fromName(String name) {
    for (final LossReason reason in LossReason.values) {
      if (reason.name == name) return reason;
    }
    return LossReason.other;
  }
}

/// Animals that left the group, and why.
class LossRecord {
  const LossRecord({
    required this.id,
    required this.amount,
    required this.reason,
    required this.date,
  });

  factory LossRecord.fromJson(Map<String, dynamic> json) => LossRecord(
    id: json['id'] as String,
    amount: (json['amount'] as num).toInt(),
    reason: LossReason.fromName(json['reason'] as String),
    date: DateTime.parse(json['date'] as String),
  );

  final String id;

  /// How many animals were lost.
  final int amount;

  final LossReason reason;
  final DateTime date;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'amount': amount,
    'reason': reason.name,
    'date': AppClock.dateOnly(date).toIso8601String(),
  };
}

/// One flock or herd, with everything recorded about it.
class AnimalGroup {
  const AnimalGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.count,
    required this.startedOn,
    this.logs = const <DayLog>[],
    this.batches = const <HatchBatch>[],
    this.pregnancies = const <Pregnancy>[],
    this.tasks = const <HealthTask>[],
    this.losses = const <LossRecord>[],
  });

  factory AnimalGroup.fromJson(Map<String, dynamic> json) => AnimalGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    type: AnimalType.fromName(json['type'] as String),
    count: (json['count'] as num).toInt(),
    startedOn: DateTime.parse(json['startedOn'] as String),
    logs: <DayLog>[
      for (final dynamic log in (json['logs'] as List<dynamic>? ?? const []))
        DayLog.fromJson(log as Map<String, dynamic>),
    ],
    batches: <HatchBatch>[
      for (final dynamic b in (json['batches'] as List<dynamic>? ?? const []))
        HatchBatch.fromJson(b as Map<String, dynamic>),
    ],
    pregnancies: <Pregnancy>[
      for (final dynamic p
          in (json['pregnancies'] as List<dynamic>? ?? const []))
        Pregnancy.fromJson(p as Map<String, dynamic>),
    ],
    tasks: <HealthTask>[
      for (final dynamic t in (json['tasks'] as List<dynamic>? ?? const []))
        HealthTask.fromJson(t as Map<String, dynamic>),
    ],
    losses: <LossRecord>[
      for (final dynamic l in (json['losses'] as List<dynamic>? ?? const []))
        LossRecord.fromJson(l as Map<String, dynamic>),
    ],
  );

  final String id;

  /// The group name, for example "Flock A".
  final String name;

  final AnimalType type;

  /// How many animals are in the group right now.
  final int count;

  final DateTime startedOn;

  /// One amount per day, in no set order.
  final List<DayLog> logs;

  final List<HatchBatch> batches;
  final List<Pregnancy> pregnancies;
  final List<HealthTask> tasks;
  final List<LossRecord> losses;

  /// True for hens, ducks and quail.
  bool get isFlock => type.isFlock;

  /// The amount logged for a date, or null when that day has no log.
  double? amountOn(DateTime date) {
    final DateTime wanted = AppClock.dateOnly(date);
    for (final DayLog log in logs) {
      if (AppClock.dateOnly(log.date) == wanted) return log.amount;
    }
    return null;
  }

  /// Today's amount, or 0 when nothing was logged today.
  double get todayAmount => amountOn(AppClock.today()) ?? 0;

  /// True when today already has a log, even a log of 0.
  bool get hasTodayLog => amountOn(AppClock.today()) != null;

  /// "Hens · 24 birds", the second line on the group card.
  String get summaryLine => '${type.label} · ${type.countText(count)}';

  /// "Hens · 24 birds · since 1 Feb 2026", the line under the detail title.
  String get infoLine =>
      '$summaryLine · since ${DateText.dayMonthYear(startedOn)}';

  /// "18 eggs today", "3.5 L milk today" or "Nothing logged today".
  String get todayText {
    if (!hasTodayLog) return 'Nothing logged today';
    if (isFlock) {
      final int eggs = todayAmount.round();
      return eggs == 1 ? '1 egg today' : '$eggs eggs today';
    }
    return '${todayAmount.toStringAsFixed(1)} L milk today';
  }

  /// Open tasks in the order the Health tab shows them: late first (most
  /// late), then due today, then coming up (soonest first).
  List<HealthTask> get openTasks {
    final List<HealthTask> open = tasks
        .where((HealthTask task) => !task.isDone)
        .toList();
    open.sort(
      (HealthTask a, HealthTask b) =>
          a.daysFromToday.compareTo(b.daysFromToday),
    );
    return open;
  }

  /// The task the group card and Home warn about, or null when nothing is
  /// late or due today.
  HealthTask? get warningTask {
    final List<HealthTask> open = openTasks;
    if (open.isEmpty) return null;
    final HealthTask first = open.first;
    return first.state == HealthState.comingUp ? null : first;
  }

  /// "Late: Deworming" or "Newcastle booster due today", or null.
  String? get warningText {
    final HealthTask? task = warningTask;
    if (task == null) return null;
    if (task.state == HealthState.late) return 'Late: ${task.title}';
    return '${task.title} due today';
  }

  /// Hatch batches still running, newest start first.
  List<HatchBatch> get activeBatches {
    final List<HatchBatch> active = batches
        .where((HatchBatch batch) => !batch.isDone)
        .toList();
    active.sort(
      (HatchBatch a, HatchBatch b) => b.startedOn.compareTo(a.startedOn),
    );
    return active;
  }

  /// Finished hatch batches, newest result first.
  List<HatchBatch> get pastBatches {
    final List<HatchBatch> past = batches
        .where((HatchBatch batch) => batch.isDone)
        .toList();
    past.sort(
      (HatchBatch a, HatchBatch b) => b.resultOn!.compareTo(a.resultOn!),
    );
    return past;
  }

  /// Running pregnancies, soonest due first.
  List<Pregnancy> get activePregnancies {
    final List<Pregnancy> active = pregnancies
        .where((Pregnancy p) => !p.isDone)
        .toList();
    active.sort(
      (Pregnancy a, Pregnancy b) => AnimalRules.dueDate(
        type,
        a.matedOn,
      ).compareTo(AnimalRules.dueDate(type, b.matedOn)),
    );
    return active;
  }

  /// Finished pregnancies, newest birth first.
  List<Pregnancy> get pastBirths {
    final List<Pregnancy> past = pregnancies
        .where((Pregnancy p) => p.isDone)
        .toList();
    past.sort((Pregnancy a, Pregnancy b) => b.bornOn!.compareTo(a.bornOn!));
    return past;
  }

  /// The next batch number for this group.
  int get nextBatchNumber {
    int highest = 0;
    for (final HatchBatch batch in batches) {
      if (batch.number > highest) highest = batch.number;
    }
    return highest + 1;
  }

  AnimalGroup copyWith({
    String? name,
    int? count,
    DateTime? startedOn,
    List<DayLog>? logs,
    List<HatchBatch>? batches,
    List<Pregnancy>? pregnancies,
    List<HealthTask>? tasks,
    List<LossRecord>? losses,
  }) => AnimalGroup(
    id: id,
    name: name ?? this.name,
    // The type is fixed once the group is made, so it is not here.
    type: type,
    count: count ?? this.count,
    startedOn: startedOn ?? this.startedOn,
    logs: logs ?? this.logs,
    batches: batches ?? this.batches,
    pregnancies: pregnancies ?? this.pregnancies,
    tasks: tasks ?? this.tasks,
    losses: losses ?? this.losses,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'type': type.name,
    'count': count,
    'startedOn': AppClock.dateOnly(startedOn).toIso8601String(),
    'logs': <Map<String, dynamic>>[for (final DayLog l in logs) l.toJson()],
    'batches': <Map<String, dynamic>>[
      for (final HatchBatch b in batches) b.toJson(),
    ],
    'pregnancies': <Map<String, dynamic>>[
      for (final Pregnancy p in pregnancies) p.toJson(),
    ],
    'tasks': <Map<String, dynamic>>[
      for (final HealthTask t in tasks) t.toJson(),
    ],
    'losses': <Map<String, dynamic>>[
      for (final LossRecord l in losses) l.toJson(),
    ],
  };
}

/// One line in the Health tab's history: a done task or a loss.
class HealthHistoryEntry {
  const HealthHistoryEntry({required this.date, required this.text});

  /// The day the line is about, used to sort newest first.
  final DateTime date;

  /// "Fowl pox vaccine · done 1 Nov 2026" or
  /// "Lost 2 birds · Sickness · 18 Oct 2026".
  final String text;

  /// Every done task and loss in a group, newest first.
  static List<HealthHistoryEntry> of(AnimalGroup group) {
    final List<HealthHistoryEntry> lines = <HealthHistoryEntry>[
      for (final HealthTask task in group.tasks)
        if (task.isDone)
          HealthHistoryEntry(
            date: task.doneOn!,
            text: '${task.title} · done ${DateText.dayMonthYear(task.doneOn!)}',
          ),
      for (final LossRecord loss in group.losses)
        HealthHistoryEntry(
          date: loss.date,
          text:
              'Lost ${group.type.countText(loss.amount)} · '
              '${loss.reason.label} · ${DateText.dayMonthYear(loss.date)}',
        ),
    ];
    lines.sort(
      (HealthHistoryEntry a, HealthHistoryEntry b) => b.date.compareTo(a.date),
    );
    return lines;
  }
}
