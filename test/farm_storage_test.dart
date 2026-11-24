import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/animal_models.dart';
import 'package:harvestly/data/farm_models.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/data/farm_storage.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String email = 'farmer@harvestly.app';
const String accountId = 'farmer';

/// Phase 2 saved one key with no version and no animals in it.
const String phase2Json = '''
{"fields":[{"id":"field-9","name":"Upgrade check","sizeAcres":0.2,
"soil":"loam","note":"","corners":[{"x":0.2,"y":0.2},{"x":0.8,"y":0.2},
{"x":0.8,"y":0.8},{"x":0.2,"y":0.8}],
"crops":[{"id":"crop-9","typeId":"radish","plantedOn":"2026-11-20T00:00:00.000",
"plants":12}],"harvests":[]}]}
''';

Future<FarmRepository> openWith(String? stored) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    FarmStorage.keyFor(email): ?stored,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final FarmRepository repository = FarmRepository(prefs);
  repository.openAccount(email: email, accountId: accountId);
  await repository.lastWrite;
  return repository;
}

/// What is in shared_preferences for this account right now.
Future<Map<String, dynamic>> savedJson() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(FarmStorage.keyFor(email))!)
      as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => AppClock.useFixed(DateTime(2026, 11, 24)));
  tearDown(AppClock.useRealClock);

  test('nothing saved loads the account\'s full sample', () async {
    final FarmRepository repository = await openWith(null);

    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));
    expect(repository.animals.first.name, 'Flock A');

    final Map<String, dynamic> saved = await savedJson();
    expect(saved['schemaVersion'], FarmStorage.schemaVersion);
  });

  test('Phase 2 data keeps its fields and gains the sample animals', () async {
    final FarmRepository repository = await openWith(phase2Json);

    // The fields are exactly what was saved, not the sample.
    expect(repository.fields, hasLength(1));
    expect(repository.fields.single.name, 'Upgrade check');
    expect(repository.fields.single.crops.single.typeId, 'radish');
    expect(repository.fields.single.crops.single.plants, 12);

    // The animals could not have been saved by Phase 2, so the sample fills
    // them in.
    expect(repository.animals, hasLength(4));
    expect(repository.animals.map((AnimalGroup g) => g.name).toList(), <String>[
      'Flock A',
      'Duck pond',
      'Goat herd',
      'Cow shed',
    ]);
  });

  test('the upgrade is written back as version 2 at once', () async {
    await openWith(phase2Json);

    final Map<String, dynamic> saved = await savedJson();
    expect(saved['schemaVersion'], 2);
    expect((saved['fields'] as List<dynamic>), hasLength(1));
    expect((saved['animals'] as List<dynamic>), hasLength(4));
  });

  test('broken data is backed up and the sample is loaded', () async {
    const String broken = 'this is not json at all';
    final FarmRepository repository = await openWith(broken);

    // The farm is never empty because of a load error.
    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(FarmStorage.backupKeyFor(email)), broken);

    final Map<String, dynamic> saved = await savedJson();
    expect(saved['schemaVersion'], 2);
  });

  test('a newer version is backed up and the sample is loaded', () async {
    const String fromTheFuture =
        '{"schemaVersion":3,"fields":[],"animals":[],"barns":[]}';
    final FarmRepository repository = await openWith(fromTheFuture);

    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(FarmStorage.backupKeyFor(email)), fromTheFuture);
  });

  test('version 2 data is loaded exactly as it was', () async {
    final FarmRepository first = await openWith(null);
    await first.addField(
      name: 'Only field',
      sizeAcres: 0.3,
      soil: SoilType.clay,
      note: '',
    );
    await first.deleteGroup('group-2');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String stored = prefs.getString(FarmStorage.keyFor(email))!;

    final FarmRepository second = await openWith(stored);
    expect(second.fields, hasLength(5));
    expect(second.fields.last.name, 'Only field');
    expect(second.animals, hasLength(3));
    expect(
      second.animals.map((AnimalGroup g) => g.name).toList(),
      isNot(contains('Duck pond')),
    );

    final SharedPreferences after = await SharedPreferences.getInstance();
    expect(
      after.getString(FarmStorage.backupKeyFor(email)),
      isNull,
      reason: 'good data must never be backed up',
    );
  });

  test('Reset demo data puts back both the fields and the animals', () async {
    final FarmRepository repository = await openWith(null);
    await repository.deleteField('field-1');
    await repository.deleteGroup('group-1');
    expect(repository.fields, hasLength(3));
    expect(repository.animals, hasLength(3));

    await repository.resetToSample();

    expect(repository.fields, hasLength(4));
    expect(repository.animals, hasLength(4));
    expect(repository.animals.first.name, 'Flock A');
  });

  test('an account with no sample starts empty but still saves', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FarmRepository repository = FarmRepository(prefs);
    repository.openAccount(email: 'new@harvestly.app', accountId: 'new');
    await repository.lastWrite;

    expect(repository.fields, isEmpty);
    expect(repository.animals, isEmpty);
    expect(prefs.getString(FarmStorage.keyFor('new@harvestly.app')), isNotNull);
  });
}
