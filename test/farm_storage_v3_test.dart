import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/data/farm_storage.dart';
import 'package:harvestly/data/task_models.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Today for every test here: Wednesday 25 November 2026.
final DateTime _today = DateTime(2026, 11, 25, 9);

const String _email = 'farmer@harvestly.app';

/// Phase 3 data: fields and animals, version 2, and no tasks at all.
String _version2({required String fieldName}) => jsonEncode(<String, dynamic>{
  'schemaVersion': 2,
  'fields': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'field-9',
      'name': fieldName,
      'sizeAcres': 0.2,
      'soil': 'loam',
      'note': '',
      'corners': <Map<String, dynamic>>[
        <String, dynamic>{'x': 0.2, 'y': 0.2},
        <String, dynamic>{'x': 0.8, 'y': 0.2},
        <String, dynamic>{'x': 0.8, 'y': 0.8},
        <String, dynamic>{'x': 0.2, 'y': 0.8},
      ],
      'crops': <Map<String, dynamic>>[],
      'harvests': <Map<String, dynamic>>[],
    },
  ],
  'animals': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'group-9',
      'name': 'Upgrade flock',
      'type': 'hens',
      'count': 5,
      'startedOn': '2026-11-01T00:00:00.000',
    },
  ],
});

Future<FarmRepository> _open(String? stored) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    FarmStorage.keyFor(_email): ?stored,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FarmRepository repository = FarmRepository(prefs);
  repository.openAccount(email: _email, accountId: 'farmer');
  await repository.lastWrite;
  return repository;
}

Future<Map<String, dynamic>> _saved() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(FarmStorage.keyFor(_email))!)
      as Map<String, dynamic>;
}

void main() {
  setUp(() => AppClock.useFixed(_today));
  tearDown(AppClock.useRealClock);

  test('the app writes version 3', () {
    expect(FarmStorage.schemaVersion, 3);
  });

  test('version 2 data keeps its fields and animals and gains tasks', () async {
    final FarmRepository repository = await _open(
      _version2(fieldName: 'Upgrade check 4'),
    );

    // Nothing the user had is touched.
    expect(repository.fields, hasLength(1));
    expect(repository.fields.single.name, 'Upgrade check 4');
    expect(repository.animals, hasLength(1));
    expect(repository.animals.single.name, 'Upgrade flock');

    // Phase 3 could not have tasks, so the sample ones are added.
    expect(repository.tasks, hasLength(10));
    expect(repository.tasks.first.title, 'Spray beans');
  });

  test('the upgrade is written back as version 3 at once', () async {
    await _open(_version2(fieldName: 'Upgrade check 4'));

    final Map<String, dynamic> saved = await _saved();
    expect(saved['schemaVersion'], 3);
    expect(saved['fields'] as List<dynamic>, hasLength(1));
    expect(saved['animals'] as List<dynamic>, hasLength(1));
    expect(saved['tasks'] as List<dynamic>, hasLength(10));
  });

  test('version 1 data gains both animals and tasks', () async {
    const String version1 = '{"fields":[]}';
    final FarmRepository repository = await _open(version1);

    expect(repository.fields, isEmpty);
    expect(repository.animals, hasLength(4));
    expect(repository.tasks, hasLength(10));
    expect((await _saved())['schemaVersion'], 3);
  });

  test('version 3 data is loaded exactly as it was', () async {
    final FarmRepository first = await _open(null);
    await first.addTask(
      title: 'Only task',
      note: '',
      dueAt: DateTime(2026, 11, 26, 9),
      repeat: Repeat.none,
      link: null,
      reminder: ReminderOffset.none,
    );
    await first.lastWrite;

    final String saved = (await SharedPreferences.getInstance()).getString(
      FarmStorage.keyFor(_email),
    )!;
    final FarmRepository second = await _open(saved);

    expect(second.tasks, hasLength(11));
    expect(second.tasks.last.title, 'Only task');
    // Nothing was added a second time.
    expect(
      second.tasks.where((FarmTask t) => t.title == 'Spray beans'),
      hasLength(1),
    );
  });

  test('broken data is backed up and the sample is loaded', () async {
    const String broken = 'not json at all';
    final FarmRepository repository = await _open(broken);

    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));
    expect(repository.tasks, hasLength(10));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(FarmStorage.backupKeyFor(_email)), broken);
    expect((await _saved())['schemaVersion'], 3);
  });

  test('a newer version is backed up and the sample is loaded', () async {
    const String fromTheFuture =
        '{"schemaVersion":4,"fields":[],"animals":[],"tasks":[],"barns":[]}';
    final FarmRepository repository = await _open(fromTheFuture);

    expect(repository.fields, hasLength(4));
    expect(repository.tasks, hasLength(10));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(FarmStorage.backupKeyFor(_email)), fromTheFuture);
  });

  test('a task survives a save and a load with everything on it', () async {
    final FarmRepository first = await _open(null);
    await first.addTask(
      title: 'Clean water pots',
      note: 'Scrub the green off the sides',
      dueAt: DateTime(2026, 11, 25, 17),
      repeat: Repeat.weekly,
      link: const TaskLink(kind: TaskLinkKind.group, id: 'group-2'),
      reminder: ReminderOffset.hourBefore,
    );
    await first.lastWrite;

    final String saved = (await SharedPreferences.getInstance()).getString(
      FarmStorage.keyFor(_email),
    )!;
    final FarmRepository second = await _open(saved);
    final FarmTask task = second.tasks.last;

    expect(task.title, 'Clean water pots');
    expect(task.note, 'Scrub the green off the sides');
    expect(task.dueAt, DateTime(2026, 11, 25, 17));
    expect(task.repeat, Repeat.weekly);
    expect(task.link?.kind, TaskLinkKind.group);
    expect(task.link?.id, 'group-2');
    expect(task.reminder, ReminderOffset.hourBefore);
  });

  test('Reset demo data puts the tasks back too', () async {
    final FarmRepository repository = await _open(null);
    await repository.deleteTask('task-1');
    expect(repository.tasks, hasLength(9));

    await repository.resetToSample();
    expect(repository.tasks, hasLength(10));
    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));
  });

  test('an account with no sample starts with no tasks', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FarmRepository repository = FarmRepository(prefs);
    repository.openAccount(email: 'new@harvestly.app', accountId: 'new');
    await repository.lastWrite;

    expect(repository.tasks, isEmpty);
    expect(prefs.getString(FarmStorage.keyFor('new@harvestly.app')), isNotNull);
  });
}
