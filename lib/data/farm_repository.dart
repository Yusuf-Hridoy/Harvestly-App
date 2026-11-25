import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/logic/app_clock.dart';
import 'animal_models.dart';
import 'farm_models.dart';
import 'farm_storage.dart';
import 'task_models.dart';
import 'task_rules.dart';

/// Holds the fields, crops, animal groups and tasks of the logged-in
/// account.
///
/// Everything is kept on the phone as JSON in shared_preferences, under one
/// key per account, through [FarmStorage]. Every change is saved at once, so
/// nothing is lost when the app closes. There is no backend.
class FarmRepository extends ChangeNotifier {
  FarmRepository(SharedPreferences prefs) : _storage = FarmStorage(prefs);

  /// The start of the storage key. The account email is added to it.
  static const String keyPrefix = FarmStorage.keyPrefix;

  final FarmStorage _storage;

  String? _accountEmail;
  String? _accountId;
  List<Field> _fields = <Field>[];
  List<AnimalGroup> _animals = <AnimalGroup>[];
  List<FarmTask> _tasks = <FarmTask>[];
  int _idCounter = 0;
  Future<void> _lastWrite = Future<void>.value();

  /// Called whenever the loaded account's tasks change, with the account
  /// email and its tasks.
  ///
  /// The app points this at the notification service, so reminders follow
  /// every add, edit, delete, complete, snooze, reset, login and logout.
  /// Nothing else in the data layer knows notifications exist.
  void Function(String? email, List<FarmTask> tasks)? onRemindersChanged;

  /// The email of the account whose data is loaded, or null when nobody is
  /// logged in.
  String? get accountEmail => _accountEmail;

  /// Every task of the logged-in account, in the order they were added.
  List<FarmTask> get tasks => List<FarmTask>.unmodifiable(_tasks);

  /// Every field of the logged-in account, in the order they were added.
  List<Field> get fields => List<Field>.unmodifiable(_fields);

  /// Every animal group of the logged-in account, in the order they were
  /// added.
  List<AnimalGroup> get animals => List<AnimalGroup>.unmodifiable(_animals);

  /// The save that is running now, or the last one that finished.
  ///
  /// Tests await this to be sure the data reached shared_preferences.
  Future<void> get lastWrite => _lastWrite;

  /// How many crops are growing across all fields.
  int get cropCount =>
      _fields.fold(0, (int total, Field field) => total + field.crops.length);

  /// The storage key for an account email.
  static String keyFor(String accountEmail) => FarmStorage.keyFor(accountEmail);

  /// Loads an account's saved data, or its starting sample the first time.
  ///
  /// Call it again with the same account and nothing happens, so it is safe
  /// to call on every rebuild.
  void openAccount({required String email, required String accountId}) {
    if (_accountEmail == email) return;
    _accountEmail = email;
    _accountId = accountId;

    final FarmLoad load = _storage.load(email: email, accountId: accountId);
    _fields = load.snapshot.fields;
    _animals = load.snapshot.animals;
    _tasks = load.snapshot.tasks;
    // A first run, an upgrade from an older phase or a recovery is written
    // back at once, so the next start reads the current version.
    if (load.needsSave) _write();
    _remindersChanged();
    notifyListeners();
  }

  /// Reads shared_preferences again, then the account's data.
  ///
  /// The app calls this when it comes back to the front, because a
  /// notification button can change the saved data from another isolate
  /// while the app is closed, and the app's own copy would not see it.
  Future<void> reloadFromDisk() async {
    await _storage.refresh();
    reload();
  }

  /// Reads the account's data from storage again.
  void reload() {
    final String? email = _accountEmail;
    final String? accountId = _accountId;
    if (email == null || accountId == null) return;

    final FarmLoad load = _storage.load(email: email, accountId: accountId);
    _fields = load.snapshot.fields;
    _animals = load.snapshot.animals;
    _tasks = load.snapshot.tasks;
    if (load.needsSave) _write();
    // A notification button may have finished a repeating task while the
    // app was shut, which makes a new task that needs its own reminder.
    _remindersChanged();
    notifyListeners();
  }

  /// Forgets the loaded data. Called when the user logs out.
  void closeAccount() {
    final String? email = _accountEmail;
    if (email == null) return;
    _accountEmail = null;
    _accountId = null;
    _fields = <Field>[];
    _animals = <AnimalGroup>[];
    _tasks = <FarmTask>[];
    // An empty list means "cancel everything", so one account's reminders
    // never fire while another is logged in.
    onRemindersChanged?.call(email, const <FarmTask>[]);
    notifyListeners();
  }

  /// The field with this id, or null when it was deleted or never existed.
  Field? fieldById(String fieldId) {
    for (final Field field in _fields) {
      if (field.id == fieldId) return field;
    }
    return null;
  }

  /// The crop with this id inside this field, or null when it is gone.
  Crop? cropById(String fieldId, String cropId) {
    final Field? field = fieldById(fieldId);
    if (field == null) return null;
    for (final Crop crop in field.crops) {
      if (crop.id == cropId) return crop;
    }
    return null;
  }

  /// The crop closest to harvest across every field, with the field it is in.
  /// Null when the account has no crops.
  ({Field field, Crop crop})? get soonestHarvest {
    ({Field field, Crop crop})? best;
    for (final Field field in _fields) {
      for (final Crop crop in field.crops) {
        if (best == null || crop.growth.daysLeft < best.crop.growth.daysLeft) {
          best = (field: field, crop: crop);
        }
      }
    }
    return best;
  }

  /// True when another field already uses this name, ignoring case.
  ///
  /// Pass [exceptFieldId] when editing, so a field keeps its own name.
  bool isNameTaken(String name, {String? exceptFieldId}) {
    final String needle = name.trim().toLowerCase();
    for (final Field field in _fields) {
      if (field.id == exceptFieldId) continue;
      if (field.name.toLowerCase() == needle) return true;
    }
    return false;
  }

  /// Adds a field and returns it, so the caller can open its detail screen.
  Future<Field> addField({
    required String name,
    required double sizeAcres,
    required SoilType soil,
    required String note,
  }) async {
    final Field field = Field(
      id: _newId('field'),
      name: name,
      sizeAcres: sizeAcres,
      soil: soil,
      note: note,
      corners: Field.defaultCorners,
    );
    _fields = <Field>[..._fields, field];
    await _saveAndTell();
    return field;
  }

  /// Changes a field's name, size, soil and note. The crops stay as they are.
  Future<void> editField({
    required String fieldId,
    required String name,
    required double sizeAcres,
    required SoilType soil,
    required String note,
  }) async {
    _replaceField(
      fieldId,
      (Field field) => field.copyWith(
        name: name,
        sizeAcres: sizeAcres,
        soil: soil,
        note: note,
      ),
    );
    await _saveAndTell();
  }

  /// Saves a new drawn shape for a field.
  Future<void> saveShape({
    required String fieldId,
    required List<MapPoint> corners,
  }) async {
    _replaceField(
      fieldId,
      (Field field) => field.copyWith(corners: List<MapPoint>.of(corners)),
    );
    await _saveAndTell();
  }

  /// Removes a field, with every crop and past harvest in it.
  ///
  /// Tasks linked to it lose the link and become general tasks.
  Future<void> deleteField(String fieldId) async {
    _fields = _fields.where((Field field) => field.id != fieldId).toList();
    _unlinkTasks(TaskLinkKind.field, fieldId);
    await _saveAndTell();
  }

  /// Adds a crop to a field and returns it.
  Future<Crop> addCrop({
    required String fieldId,
    required String typeId,
    required DateTime plantedOn,
    required int plants,
  }) async {
    final Crop crop = Crop(
      id: _newId('crop'),
      typeId: typeId,
      plantedOn: AppClock.dateOnly(plantedOn),
      plants: plants,
    );
    _replaceField(
      fieldId,
      (Field field) => field.copyWith(crops: <Crop>[...field.crops, crop]),
    );
    await _saveAndTell();
    return crop;
  }

  /// Removes a crop. Nothing is added to the past harvests.
  Future<void> deleteCrop({
    required String fieldId,
    required String cropId,
  }) async {
    _replaceField(
      fieldId,
      (Field field) => field.copyWith(
        crops: field.crops.where((Crop crop) => crop.id != cropId).toList(),
      ),
    );
    await _saveAndTell();
  }

  /// Takes a crop out of the field and puts it in the past harvests, with
  /// today's date and the amount the user typed.
  Future<void> harvestCrop({
    required String fieldId,
    required String cropId,
    required double amountKg,
  }) async {
    final Crop? crop = cropById(fieldId, cropId);
    if (crop == null) return;

    final Harvest harvest = Harvest(
      id: _newId('harvest'),
      typeId: crop.typeId,
      plantedOn: crop.plantedOn,
      harvestedOn: AppClock.today(),
      amountKg: amountKg,
    );

    _replaceField(
      fieldId,
      (Field field) => field.copyWith(
        crops: field.crops.where((Crop c) => c.id != cropId).toList(),
        harvests: <Harvest>[harvest, ...field.harvests],
      ),
    );
    await _saveAndTell();
  }

  /// Puts this account's fields, crops and animal groups back to the
  /// starting sample.
  ///
  /// It does not touch any other account, the theme or the session.
  Future<void> resetToSample() async {
    final String? accountId = _accountId;
    if (accountId == null) return;
    final FarmSnapshot sample = FarmSnapshot.sample(accountId);
    _fields = sample.fields;
    _animals = sample.animals;
    _tasks = sample.tasks;
    await _saveAndTell();
    _remindersChanged();
  }

  // ---------------------------------------------------------------- animals

  /// How many eggs were logged today across every flock.
  int get eggsToday {
    double total = 0;
    for (final AnimalGroup group in _animals) {
      if (group.isFlock) total += group.todayAmount;
    }
    return total.round();
  }

  /// The group with this id, or null when it was deleted or never existed.
  AnimalGroup? groupById(String groupId) {
    for (final AnimalGroup group in _animals) {
      if (group.id == groupId) return group;
    }
    return null;
  }

  /// True when another group already uses this name, ignoring case.
  ///
  /// Pass [exceptGroupId] when editing, so a group keeps its own name.
  bool isGroupNameTaken(String name, {String? exceptGroupId}) {
    final String needle = name.trim().toLowerCase();
    for (final AnimalGroup group in _animals) {
      if (group.id == exceptGroupId) continue;
      if (group.name.toLowerCase() == needle) return true;
    }
    return false;
  }

  /// The open health task Home warns about, with the group it belongs to.
  ///
  /// Late comes first (most late), then due today, then coming up inside
  /// [comingUpDays]. Null when nothing needs attention.
  ({AnimalGroup group, HealthTask task})? urgentHealthTask({
    int comingUpDays = 7,
  }) {
    ({AnimalGroup group, HealthTask task})? best;
    for (final AnimalGroup group in _animals) {
      for (final HealthTask task in group.openTasks) {
        if (task.daysFromToday > comingUpDays) continue;
        if (best == null || task.daysFromToday < best.task.daysFromToday) {
          best = (group: group, task: task);
        }
      }
    }
    return best;
  }

  /// Adds a group and returns it, so the caller can open its detail screen.
  Future<AnimalGroup> addGroup({
    required String name,
    required AnimalType type,
    required int count,
    required DateTime startedOn,
  }) async {
    final AnimalGroup group = AnimalGroup(
      id: _newId('group'),
      name: name,
      type: type,
      count: count,
      startedOn: AppClock.dateOnly(startedOn),
    );
    _animals = <AnimalGroup>[..._animals, group];
    await _saveAndTell();
    return group;
  }

  /// Changes a group's name, how many animals are in it and its start date.
  ///
  /// The type is fixed once the group is made, so it is not a parameter.
  Future<void> editGroup({
    required String groupId,
    required String name,
    required int count,
    required DateTime startedOn,
  }) async {
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        name: name,
        count: count,
        startedOn: AppClock.dateOnly(startedOn),
      ),
    );
    await _saveAndTell();
  }

  /// Removes a group with every record in it.
  ///
  /// Tasks linked to it lose the link and become general tasks.
  Future<void> deleteGroup(String groupId) async {
    _animals = _animals
        .where((AnimalGroup group) => group.id != groupId)
        .toList();
    _unlinkTasks(TaskLinkKind.group, groupId);
    await _saveAndTell();
  }

  /// Sets the eggs or milk for one day, replacing that day's log.
  Future<void> setDayAmount({
    required String groupId,
    required DateTime date,
    required double amount,
  }) async {
    final DateTime day = AppClock.dateOnly(date);
    _replaceGroup(groupId, (AnimalGroup group) {
      final List<DayLog> logs = <DayLog>[
        for (final DayLog log in group.logs)
          if (AppClock.dateOnly(log.date) != day) log,
        DayLog(date: day, amount: amount),
      ];
      return group.copyWith(logs: logs);
    });
    await _saveAndTell();
  }

  /// Starts a hatch batch and returns it. Its number is the group's next one.
  Future<HatchBatch> addBatch({
    required String groupId,
    required DateTime startedOn,
    required int eggs,
  }) async {
    final AnimalGroup? group = groupById(groupId);
    final HatchBatch batch = HatchBatch(
      id: _newId('batch'),
      number: group?.nextBatchNumber ?? 1,
      startedOn: AppClock.dateOnly(startedOn),
      eggs: eggs,
    );
    _replaceGroup(
      groupId,
      (AnimalGroup g) => g.copyWith(batches: <HatchBatch>[...g.batches, batch]),
    );
    await _saveAndTell();
    return batch;
  }

  /// Records how many eggs hatched, which moves the batch to Past batches.
  Future<void> finishBatch({
    required String groupId,
    required String batchId,
    required int hatched,
  }) async {
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        batches: <HatchBatch>[
          for (final HatchBatch batch in group.batches)
            if (batch.id == batchId)
              batch.copyWith(hatched: hatched, resultOn: AppClock.today())
            else
              batch,
        ],
      ),
    );
    await _saveAndTell();
  }

  /// Adds a pregnancy and returns it.
  Future<Pregnancy> addPregnancy({
    required String groupId,
    required String animalName,
    required DateTime matedOn,
  }) async {
    final Pregnancy pregnancy = Pregnancy(
      id: _newId('pregnancy'),
      animalName: animalName,
      matedOn: AppClock.dateOnly(matedOn),
    );
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        pregnancies: <Pregnancy>[...group.pregnancies, pregnancy],
      ),
    );
    await _saveAndTell();
    return pregnancy;
  }

  /// Records a birth, which moves the pregnancy to Past births.
  Future<void> finishPregnancy({
    required String groupId,
    required String pregnancyId,
    required int young,
    required DateTime bornOn,
  }) async {
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        pregnancies: <Pregnancy>[
          for (final Pregnancy pregnancy in group.pregnancies)
            if (pregnancy.id == pregnancyId)
              pregnancy.copyWith(
                young: young,
                bornOn: AppClock.dateOnly(bornOn),
              )
            else
              pregnancy,
        ],
      ),
    );
    await _saveAndTell();
  }

  /// Adds an open health task.
  Future<HealthTask> addHealthTask({
    required String groupId,
    required String title,
    required DateTime dueOn,
  }) async {
    final HealthTask task = HealthTask(
      id: _newId('task'),
      title: title,
      dueOn: AppClock.dateOnly(dueOn),
    );
    _replaceGroup(
      groupId,
      (AnimalGroup group) =>
          group.copyWith(tasks: <HealthTask>[...group.tasks, task]),
    );
    await _saveAndTell();
    return task;
  }

  /// Marks a health task as done today, which moves it to the history.
  Future<void> markTaskDone({
    required String groupId,
    required String taskId,
  }) async {
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        tasks: <HealthTask>[
          for (final HealthTask task in group.tasks)
            if (task.id == taskId)
              task.copyWith(doneOn: AppClock.today())
            else
              task,
        ],
      ),
    );
    await _saveAndTell();
  }

  /// Records animals lost and takes them off the count.
  ///
  /// The count stops at 0, so a loss bigger than the group can never make it
  /// go negative.
  Future<void> recordLoss({
    required String groupId,
    required int amount,
    required LossReason reason,
    required DateTime date,
  }) async {
    final LossRecord loss = LossRecord(
      id: _newId('loss'),
      amount: amount,
      reason: reason,
      date: AppClock.dateOnly(date),
    );
    _replaceGroup(
      groupId,
      (AnimalGroup group) => group.copyWith(
        count: (group.count - amount).clamp(0, group.count),
        losses: <LossRecord>[...group.losses, loss],
      ),
    );
    await _saveAndTell();
  }

  // ------------------------------------------------------------------ tasks

  /// The task with this id, or null when it was deleted or never existed.
  FarmTask? taskById(String taskId) {
    for (final FarmTask task in _tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }

  /// The name of what a task is linked to, or "General" when it has none.
  ///
  /// A link to something that was deleted also reads "General".
  String linkNameFor(FarmTask task) {
    final TaskLink? link = task.link;
    if (link == null) return TaskRules.generalName;
    switch (link.kind) {
      case TaskLinkKind.field:
        return fieldById(link.id)?.name ?? TaskRules.generalName;
      case TaskLinkKind.group:
        return groupById(link.id)?.name ?? TaskRules.generalName;
    }
  }

  /// The open tasks, in no particular order.
  List<FarmTask> get openTasks =>
      _tasks.where((FarmTask task) => task.isOpen).toList();

  /// The tasks in one group of the Tasks list, already sorted.
  ///
  /// Done only holds tasks finished in the last 30 days.
  List<FarmTask> tasksIn(TaskGroup group) {
    final List<FarmTask> inGroup = _tasks
        .where(
          (FarmTask task) =>
              TaskRules.groupOf(task) == group &&
              (group != TaskGroup.done || TaskRules.showsUnderDone(task)),
        )
        .toList();
    return TaskRules.sorted(inGroup, group);
  }

  /// How many open tasks are overdue, for the line on Home.
  int get overdueCount => tasksIn(TaskGroup.overdue).length;

  /// The tasks Home shows: the open ones due today by time, then the ones
  /// already done today.
  List<FarmTask> todayTasks({int limit = 3}) {
    final DateTime today = AppClock.today();
    final List<FarmTask> open = tasksIn(TaskGroup.today);
    final List<FarmTask> doneToday =
        _tasks
            .where(
              (FarmTask task) =>
                  task.isDone && AppClock.dateOnly(task.doneAt!) == today,
            )
            .toList()
          ..sort((FarmTask a, FarmTask b) => a.dueAt.compareTo(b.dueAt));
    return <FarmTask>[...open, ...doneToday].take(limit).toList();
  }

  /// Adds a task and returns it, so the caller can open its detail screen.
  Future<FarmTask> addTask({
    required String title,
    required String note,
    required DateTime dueAt,
    required Repeat repeat,
    required TaskLink? link,
    required ReminderOffset reminder,
  }) async {
    final FarmTask task = FarmTask(
      id: _newId('task'),
      title: title,
      note: note,
      dueAt: dueAt,
      repeat: repeat,
      link: link,
      reminder: reminder,
    );
    _tasks = <FarmTask>[..._tasks, task];
    await _saveAndTell();
    _remindersChanged();
    return task;
  }

  /// Changes a task. Editing always clears a snooze, because the user has
  /// just said when they want it instead.
  Future<void> editTask({
    required String taskId,
    required String title,
    required String note,
    required DateTime dueAt,
    required Repeat repeat,
    required TaskLink? link,
    required ReminderOffset reminder,
  }) async {
    _replaceTask(
      taskId,
      (FarmTask task) => task.copyWith(
        title: title,
        note: note,
        dueAt: dueAt,
        repeat: repeat,
        link: link,
        clearLink: link == null,
        reminder: reminder,
        clearSnooze: true,
      ),
    );
    await _saveAndTell();
    _remindersChanged();
  }

  /// Removes a task and its reminder.
  Future<void> deleteTask(String taskId) async {
    _tasks = _tasks.where((FarmTask task) => task.id != taskId).toList();
    await _saveAndTell();
    _remindersChanged();
  }

  /// Marks a task done, and starts the next one when it repeats.
  ///
  /// The result says what to put back if the user taps Undo.
  Future<TaskCompletion> completeTask(String taskId) async {
    final FarmTask? task = taskById(taskId);
    if (task == null || task.isDone) {
      return const TaskCompletion(taskId: '', createdTaskId: null);
    }

    _replaceTask(
      taskId,
      (FarmTask t) => t.copyWith(doneAt: AppClock.now(), clearSnooze: true),
    );

    String? createdId;
    if (task.repeats) {
      final FarmTask next = FarmTask(
        id: _newId('task'),
        title: task.title,
        note: task.note,
        dueAt: TaskRules.nextDueAt(task.dueAt, task.repeat),
        repeat: task.repeat,
        link: task.link,
        reminder: task.reminder,
      );
      createdId = next.id;
      _tasks = <FarmTask>[..._tasks, next];
    }

    await _saveAndTell();
    _remindersChanged();
    return TaskCompletion(taskId: taskId, createdTaskId: createdId);
  }

  /// Puts a completion back: the task opens again and the task it started is
  /// removed.
  Future<void> undoComplete(TaskCompletion completion) async {
    final String? createdId = completion.createdTaskId;
    if (createdId != null) {
      _tasks = _tasks.where((FarmTask task) => task.id != createdId).toList();
    }
    _replaceTask(
      completion.taskId,
      (FarmTask task) => task.copyWith(clearDone: true),
    );
    await _saveAndTell();
    _remindersChanged();
  }

  /// Opens a done task again. A repeating task cannot be reopened, because
  /// finishing it already made the next one.
  Future<void> reopenTask(String taskId) async {
    final FarmTask? task = taskById(taskId);
    if (task == null || task.isOpen || task.repeats) return;
    _replaceTask(taskId, (FarmTask t) => t.copyWith(clearDone: true));
    await _saveAndTell();
    _remindersChanged();
  }

  /// Pushes a task's reminder back to [until]. Used by the Snooze button.
  Future<void> snoozeTask({
    required String taskId,
    required DateTime until,
  }) async {
    _replaceTask(taskId, (FarmTask task) => task.copyWith(snoozedUntil: until));
    await _saveAndTell();
    _remindersChanged();
  }

  /// Drops the link on every task that pointed at something now deleted.
  void _unlinkTasks(TaskLinkKind kind, String id) {
    _tasks = <FarmTask>[
      for (final FarmTask task in _tasks)
        if (task.link?.kind == kind && task.link?.id == id)
          task.copyWith(clearLink: true)
        else
          task,
    ];
  }

  void _replaceTask(String taskId, FarmTask Function(FarmTask task) change) {
    _tasks = <FarmTask>[
      for (final FarmTask task in _tasks)
        if (task.id == taskId) change(task) else task,
    ];
  }

  /// Asks for the reminders to be set again without changing any data.
  ///
  /// The task form calls this after the user allows notifications, because
  /// the save happened while they were still off.
  void refreshReminders() => _remindersChanged();

  void _remindersChanged() => onRemindersChanged?.call(_accountEmail, tasks);

  void _replaceGroup(
    String groupId,
    AnimalGroup Function(AnimalGroup group) change,
  ) {
    _animals = <AnimalGroup>[
      for (final AnimalGroup group in _animals)
        if (group.id == groupId) change(group) else group,
    ];
  }

  void _replaceField(String fieldId, Field Function(Field field) change) {
    _fields = <Field>[
      for (final Field field in _fields)
        if (field.id == fieldId) change(field) else field,
    ];
  }

  /// A new id made from the current time plus a counter, so two items made in
  /// the same millisecond still differ.
  String _newId(String prefix) {
    _idCounter++;
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$_idCounter';
  }

  Future<void> _saveAndTell() async {
    notifyListeners();
    _write();
    await _lastWrite;
  }

  /// Starts a save without waiting for it, and remembers it as [lastWrite].
  void _write() => _lastWrite = _save();

  Future<void> _save() async {
    final String? email = _accountEmail;
    if (email == null) return;
    await _storage.save(
      email: email,
      snapshot: FarmSnapshot(fields: _fields, animals: _animals, tasks: _tasks),
    );
  }
}

/// What completing a task did, so Undo can put it back.
class TaskCompletion {
  const TaskCompletion({required this.taskId, required this.createdTaskId});

  /// The task that was marked done.
  final String taskId;

  /// The task a repeat started, or null when the task does not repeat.
  final String? createdTaskId;

  /// False when there was nothing to complete, so Undo has nothing to do.
  bool get happened => taskId.isNotEmpty;
}
