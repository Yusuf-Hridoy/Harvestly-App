import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/animal_models.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/data/farm_storage.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String email = 'farmer@harvestly.app';
final DateTime today = DateTime(2026, 11, 24);

DateTime back(int days) => today.subtract(Duration(days: days));

/// A repository with the farmer sample already loaded.
Future<FarmRepository> openFarmer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FarmRepository repository = FarmRepository(prefs);
  repository.openAccount(email: email, accountId: 'farmer');
  await repository.lastWrite;
  return repository;
}

/// Loads the same account again from what was saved.
Future<FarmRepository> reopen() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FarmRepository repository = FarmRepository(prefs);
  repository.openAccount(email: email, accountId: 'farmer');
  await repository.lastWrite;
  return repository;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => AppClock.useFixed(today));
  tearDown(AppClock.useRealClock);

  group('groups', () {
    test('add a group and open it again', () async {
      final FarmRepository repository = await openFarmer();

      final AnimalGroup added = await repository.addGroup(
        name: 'Quail pen',
        type: AnimalType.quail,
        count: 40,
        startedOn: back(10),
      );

      expect(repository.animals, hasLength(5));
      expect(repository.groupById(added.id)?.name, 'Quail pen');
      expect(added.count, 40);
      expect(added.type, AnimalType.quail);
    });

    test('edit changes the name, the count and the date', () async {
      final FarmRepository repository = await openFarmer();

      await repository.editGroup(
        groupId: 'group-1',
        name: 'Flock One',
        count: 30,
        startedOn: back(400),
      );

      final AnimalGroup group = repository.groupById('group-1')!;
      expect(group.name, 'Flock One');
      expect(group.count, 30);
      expect(group.startedOn, back(400));
    });

    test('edit never changes the type', () async {
      final FarmRepository repository = await openFarmer();
      final AnimalType before = repository.groupById('group-1')!.type;

      await repository.editGroup(
        groupId: 'group-1',
        name: 'Still hens',
        count: 5,
        startedOn: today,
      );

      expect(repository.groupById('group-1')!.type, before);
      expect(repository.groupById('group-1')!.type, AnimalType.hens);
    });

    test('delete removes the group and all its records', () async {
      final FarmRepository repository = await openFarmer();

      await repository.deleteGroup('group-1');

      expect(repository.groupById('group-1'), isNull);
      expect(repository.animals, hasLength(3));
    });

    test('a name is taken whatever the capitals, except its own', () async {
      final FarmRepository repository = await openFarmer();

      expect(repository.isGroupNameTaken('flock a'), isTrue);
      expect(repository.isGroupNameTaken('FLOCK A'), isTrue);
      expect(repository.isGroupNameTaken('Flock B'), isFalse);
      expect(
        repository.isGroupNameTaken('Flock A', exceptGroupId: 'group-1'),
        isFalse,
      );
    });
  });

  group('day logs', () {
    test(
      'setting an amount replaces that day, it never adds a second',
      () async {
        final FarmRepository repository = await openFarmer();
        final int before = repository.groupById('group-1')!.logs.length;

        await repository.setDayAmount(
          groupId: 'group-1',
          date: today,
          amount: 25,
        );

        final AnimalGroup group = repository.groupById('group-1')!;
        expect(group.logs, hasLength(before));
        expect(group.amountOn(today), 25);
        expect(group.todayAmount, 25);
      },
    );

    test('a day with no log reads null, and today falls back to 0', () async {
      final FarmRepository repository = await openFarmer();
      final AnimalGroup group = repository.groupById('group-1')!;

      expect(group.amountOn(back(400)), isNull);

      final AnimalGroup duck = repository.groupById('group-2')!;
      expect(duck.amountOn(back(60)), isNull);
      expect(duck.hasTodayLog, isTrue);
    });

    test('the sample logs match the brief', () async {
      final FarmRepository repository = await openFarmer();

      expect(repository.groupById('group-1')!.todayAmount, 18);
      expect(repository.groupById('group-2')!.todayAmount, 4);
      expect(repository.groupById('group-3')!.todayAmount, 3.5);
      expect(repository.groupById('group-4')!.todayAmount, 14.0);
      expect(repository.eggsToday, 22);
    });
  });

  group('hatching', () {
    test('batch numbers count up inside a group', () async {
      final FarmRepository repository = await openFarmer();

      final HatchBatch first = await repository.addBatch(
        groupId: 'group-1',
        startedOn: today,
        eggs: 6,
      );
      final HatchBatch second = await repository.addBatch(
        groupId: 'group-1',
        startedOn: today,
        eggs: 6,
      );

      // The sample already holds batches 1 to 3.
      expect(first.number, 4);
      expect(second.number, 5);

      // A group with no batches starts at 1.
      final AnimalGroup duck = repository.groupById('group-2')!;
      final HatchBatch other = await repository.addBatch(
        groupId: duck.id,
        startedOn: today,
        eggs: 4,
      );
      expect(other.number, 1);
    });

    test('recording a result moves the batch to the past list', () async {
      final FarmRepository repository = await openFarmer();
      expect(repository.groupById('group-1')!.activeBatches, hasLength(1));

      await repository.finishBatch(
        groupId: 'group-1',
        batchId: 'batch-3',
        hatched: 7,
      );

      final AnimalGroup group = repository.groupById('group-1')!;
      expect(group.activeBatches, isEmpty);
      expect(group.pastBatches.first.id, 'batch-3');
      expect(group.pastBatches.first.hatched, 7);
      expect(group.pastBatches.first.resultOn, today);
    });

    test('the hatch rate is rounded down', () async {
      final FarmRepository repository = await openFarmer();
      final List<HatchBatch> past = repository
          .groupById('group-1')!
          .pastBatches;

      // Batch 2 is 8 of 10, batch 1 is 8 of 12.
      expect(past.first.ratePercent, 80);
      expect(past.last.ratePercent, 66);
    });
  });

  group('breeding', () {
    test('recording a birth moves the pregnancy to the past list', () async {
      final FarmRepository repository = await openFarmer();
      expect(repository.groupById('group-4')!.activePregnancies, hasLength(1));

      await repository.finishPregnancy(
        groupId: 'group-4',
        pregnancyId: 'preg-1',
        young: 2,
        bornOn: today,
      );

      final AnimalGroup group = repository.groupById('group-4')!;
      expect(group.activePregnancies, isEmpty);
      expect(group.pastBirths.first.id, 'preg-1');
      expect(group.pastBirths.first.young, 2);
    });

    test('a new pregnancy is active and sorted by its due date', () async {
      final FarmRepository repository = await openFarmer();

      // Mated today, so this one is due long after Lali.
      await repository.addPregnancy(
        groupId: 'group-4',
        animalName: 'Rupa',
        matedOn: today,
      );

      final List<Pregnancy> active = repository
          .groupById('group-4')!
          .activePregnancies;
      expect(active.map((Pregnancy p) => p.animalName).toList(), <String>[
        'Lali',
        'Rupa',
      ]);
    });
  });

  group('health', () {
    test('a loss lowers the count and is kept in the history', () async {
      final FarmRepository repository = await openFarmer();

      await repository.recordLoss(
        groupId: 'group-1',
        amount: 4,
        reason: LossReason.predator,
        date: today,
      );

      final AnimalGroup group = repository.groupById('group-1')!;
      expect(group.count, 20);
      expect(group.losses, hasLength(2));
      expect(
        HealthHistoryEntry.of(group).first.text,
        'Lost 4 birds · Predator · 24 Nov 2026',
      );
    });

    test('the count can reach 0 but never goes below it', () async {
      final FarmRepository repository = await openFarmer();

      await repository.recordLoss(
        groupId: 'group-4',
        amount: 2,
        reason: LossReason.sold,
        date: today,
      );
      expect(repository.groupById('group-4')!.count, 0);

      await repository.recordLoss(
        groupId: 'group-4',
        amount: 5,
        reason: LossReason.sold,
        date: today,
      );
      expect(repository.groupById('group-4')!.count, 0);
    });

    test('marking a task done moves it out of the open list', () async {
      final FarmRepository repository = await openFarmer();
      expect(repository.groupById('group-1')!.openTasks, hasLength(2));

      await repository.markTaskDone(groupId: 'group-1', taskId: 'task-1');

      final AnimalGroup group = repository.groupById('group-1')!;
      expect(group.openTasks, hasLength(1));
      expect(group.openTasks.single.title, 'Deworming');
      expect(
        HealthHistoryEntry.of(group).first.text,
        'Newcastle booster · done 24 Nov 2026',
      );
    });

    test(
      'open tasks are sorted late, then due today, then coming up',
      () async {
        final FarmRepository repository = await openFarmer();

        await repository.addHealthTask(
          groupId: 'group-1',
          title: 'Very late',
          dueOn: back(30),
        );

        final List<HealthTask> open = repository
            .groupById('group-1')!
            .openTasks;
        expect(open.map((HealthTask t) => t.title).toList(), <String>[
          'Very late',
          'Newcastle booster',
          'Deworming',
        ]);
      },
    );

    test('the most urgent task across all groups is the most late', () async {
      final FarmRepository repository = await openFarmer();

      final ({AnimalGroup group, HealthTask task})? urgent = repository
          .urgentHealthTask();

      expect(urgent, isNotNull);
      expect(urgent!.group.name, 'Cow shed');
      expect(urgent.task.title, 'Foot-and-mouth vaccine');
      expect(urgent.task.stateText, 'Late by 4 days');
    });

    test('a task further out than a week is not urgent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FarmRepository repository = FarmRepository(prefs);
      repository.openAccount(email: 'p@harvestly.app', accountId: 'poultry');
      await repository.lastWrite;

      // The poultry task is due in 3 days, so it does show.
      expect(repository.urgentHealthTask()?.task.title, 'Fowl pox vaccine');

      await repository.markTaskDone(groupId: 'group-1', taskId: 'task-1');
      await repository.addHealthTask(
        groupId: 'group-1',
        title: 'Far away',
        dueOn: back(-20),
      );
      expect(repository.urgentHealthTask(), isNull);
    });
  });

  group('saving', () {
    test('every change survives a reload', () async {
      final FarmRepository first = await openFarmer();

      final AnimalGroup added = await first.addGroup(
        name: 'Quail pen',
        type: AnimalType.quail,
        count: 40,
        startedOn: back(10),
      );
      await first.setDayAmount(groupId: added.id, date: today, amount: 12);
      await first.addBatch(groupId: added.id, startedOn: today, eggs: 8);
      await first.addHealthTask(
        groupId: added.id,
        title: 'Clean the pen',
        dueOn: back(-2),
      );
      await first.recordLoss(
        groupId: added.id,
        amount: 3,
        reason: LossReason.accident,
        date: today,
      );
      await first.lastWrite;

      final FarmRepository second = await reopen();
      final AnimalGroup group = second.groupById(added.id)!;

      expect(group.name, 'Quail pen');
      expect(group.type, AnimalType.quail);
      expect(group.count, 37);
      expect(group.todayAmount, 12);
      expect(group.activeBatches.single.eggs, 8);
      expect(group.openTasks.single.title, 'Clean the pen');
      expect(group.losses.single.reason, LossReason.accident);
    });

    test('closing the account forgets the groups', () async {
      final FarmRepository repository = await openFarmer();
      expect(repository.animals, isNotEmpty);

      repository.closeAccount();

      expect(repository.animals, isEmpty);
      expect(repository.fields, isEmpty);
      expect(repository.eggsToday, 0);
    });

    test('the saved key is one per account', () async {
      await openFarmer();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(FarmStorage.keyFor(email)), isNotNull);
      expect(prefs.getString(FarmStorage.keyFor('other@x.app')), isNull);
    });
  });
}
