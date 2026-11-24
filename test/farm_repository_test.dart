import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/farm_models.dart';
import 'package:harvestly/data/farm_repository.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String farmerEmail = 'farmer@harvestly.test';
  const String poultryEmail = 'poultry@harvestly.test';
  final DateTime today = DateTime(2026, 11, 24);

  late SharedPreferences prefs;

  /// A repository with the farmer's starting data already loaded.
  Future<FarmRepository> openFarmer() async {
    final FarmRepository repository = FarmRepository(prefs);
    repository.openAccount(email: farmerEmail, accountId: 'farmer');
    return repository;
  }

  setUp(() async {
    AppClock.useFixed(today);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(AppClock.useRealClock);

  test('a new account starts with its sample fields', () async {
    final FarmRepository repository = await openFarmer();
    expect(repository.fields.length, 4);
    expect(repository.cropCount, 7);
    expect(repository.fieldById('field-2')?.name, 'Field 2 · South bed');
  });

  test('an account with no sample data starts empty', () async {
    final FarmRepository repository = FarmRepository(prefs);
    repository.openAccount(email: poultryEmail, accountId: 'poultry');
    expect(repository.fields, isEmpty);
    expect(repository.cropCount, 0);
  });

  group('fields', () {
    test('add puts a new field at the end with the default shape', () async {
      final FarmRepository repository = await openFarmer();
      final Field added = await repository.addField(
        name: 'Field 5 · West plot',
        sizeAcres: 0.25,
        soil: SoilType.sandy,
        note: 'By the gate',
      );

      expect(repository.fields.length, 5);
      expect(repository.fields.last.id, added.id);
      expect(added.corners, Field.defaultCorners);
      expect(added.crops, isEmpty);
    });

    test('edit changes the details and keeps the crops', () async {
      final FarmRepository repository = await openFarmer();
      await repository.editField(
        fieldId: 'field-1',
        name: 'North plot',
        sizeAcres: 1.25,
        soil: SoilType.silt,
        note: '',
      );

      final Field field = repository.fieldById('field-1')!;
      expect(field.name, 'North plot');
      expect(field.sizeAcres, 1.25);
      expect(field.soil, SoilType.silt);
      expect(field.crops.length, 3);
    });

    test('delete removes the field and its crops', () async {
      final FarmRepository repository = await openFarmer();
      await repository.deleteField('field-1');

      expect(repository.fieldById('field-1'), isNull);
      expect(repository.fields.length, 3);
      expect(repository.cropCount, 4);
    });

    test('saving a shape keeps the typed size', () async {
      final FarmRepository repository = await openFarmer();
      const List<MapPoint> corners = <MapPoint>[
        MapPoint(x: 0, y: 0),
        MapPoint(x: 1, y: 0),
        MapPoint(x: 1, y: 1),
        MapPoint(x: 0, y: 1),
      ];
      await repository.saveShape(fieldId: 'field-2', corners: corners);

      final Field field = repository.fieldById('field-2')!;
      expect(field.corners, corners);
      expect(field.sizeAcres, 0.4);
    });

    test('a name already used is found, ignoring case', () async {
      final FarmRepository repository = await openFarmer();
      expect(repository.isNameTaken('field 2 · south bed'), isTrue);
      expect(
        repository.isNameTaken('Field 2 · South bed', exceptFieldId: 'field-2'),
        isFalse,
      );
      expect(repository.isNameTaken('Field 9'), isFalse);
    });
  });

  group('crops', () {
    test('add puts the crop in the right field', () async {
      final FarmRepository repository = await openFarmer();
      final Crop crop = await repository.addCrop(
        fieldId: 'field-4',
        typeId: 'kale',
        plantedOn: today,
        plants: 25,
      );

      expect(repository.fieldById('field-4')!.crops.single.id, crop.id);
      expect(crop.name, 'Kale');
      expect(crop.plants, 25);
      expect(repository.cropCount, 8);
    });

    test('delete removes it and adds nothing to the past harvests', () async {
      final FarmRepository repository = await openFarmer();
      await repository.deleteCrop(fieldId: 'field-2', cropId: 'crop-4');

      final Field field = repository.fieldById('field-2')!;
      expect(field.crops.length, 1);
      expect(field.harvests, isEmpty);
      expect(repository.cropCount, 6);
    });

    test('harvest moves it to the past harvests with today\'s date', () async {
      final FarmRepository repository = await openFarmer();
      await repository.harvestCrop(
        fieldId: 'field-2',
        cropId: 'crop-4',
        amountKg: 18.5,
      );

      final Field field = repository.fieldById('field-2')!;
      expect(field.crops.length, 1);
      expect(field.harvests.length, 1);
      expect(field.harvests.first.name, 'Tomato');
      expect(field.harvests.first.harvestedOn, today);
      expect(field.harvests.first.amountKg, 18.5);
    });

    test('the soonest harvest is the crop closest to picking', () async {
      final FarmRepository repository = await openFarmer();
      final ({Field field, Crop crop}) soonest = repository.soonestHarvest!;
      expect(soonest.crop.name, 'Tomato');
      expect(soonest.field.name, 'Field 2 · South bed');
      expect(soonest.crop.growth.daysLeft, 12);
    });
  });

  group('storage', () {
    test('changes survive a reload', () async {
      final FarmRepository first = await openFarmer();
      await first.addField(
        name: 'Field 5 · West plot',
        sizeAcres: 0.25,
        soil: SoilType.sandy,
        note: 'By the gate',
      );
      await first.deleteField('field-3');

      final FarmRepository second = FarmRepository(prefs);
      second.openAccount(email: farmerEmail, accountId: 'farmer');

      expect(second.fields.length, 4);
      expect(second.fieldById('field-3'), isNull);
      expect(second.fields.last.name, 'Field 5 · West plot');
      expect(second.fields.last.soil, SoilType.sandy);
    });

    test('an empty farm stays empty after a reload', () async {
      final FarmRepository first = await openFarmer();
      for (final Field field in first.fields.toList()) {
        await first.deleteField(field.id);
      }

      final FarmRepository second = FarmRepository(prefs);
      second.openAccount(email: farmerEmail, accountId: 'farmer');
      expect(second.fields, isEmpty);
    });

    test('one account never sees another account\'s data', () async {
      final FarmRepository repository = await openFarmer();
      await repository.addField(
        name: 'Field 5 · West plot',
        sizeAcres: 0.25,
        soil: SoilType.sandy,
        note: '',
      );

      final FarmRepository other = FarmRepository(prefs);
      other.openAccount(email: poultryEmail, accountId: 'poultry');
      expect(other.fields, isEmpty);

      await other.addField(
        name: 'Hen run',
        sizeAcres: 0.1,
        soil: SoilType.clay,
        note: '',
      );

      final FarmRepository back = FarmRepository(prefs);
      back.openAccount(email: farmerEmail, accountId: 'farmer');
      expect(back.fields.length, 5);
      expect(back.fields.where((Field f) => f.name == 'Hen run'), isEmpty);
    });

    test('each account is saved under its own key', () async {
      await openFarmer();
      expect(prefs.getString(FarmRepository.keyFor(farmerEmail)), isNotNull);
      expect(prefs.getString(FarmRepository.keyFor(poultryEmail)), isNull);
    });
  });

  group('reset demo data', () {
    test('puts the starting sample back', () async {
      final FarmRepository repository = await openFarmer();
      await repository.deleteField('field-1');
      await repository.deleteField('field-2');
      await repository.addField(
        name: 'Made up field',
        sizeAcres: 2,
        soil: SoilType.loam,
        note: '',
      );
      expect(repository.fields.length, 3);

      await repository.resetToSample();

      expect(repository.fields.length, 4);
      expect(repository.cropCount, 7);
      expect(repository.fieldById('field-1')?.name, 'Field 1 · North plot');
      expect(
        repository.fields.where((Field f) => f.name == 'Made up field'),
        isEmpty,
      );
    });

    test('does not touch another account', () async {
      final FarmRepository other = FarmRepository(prefs);
      other.openAccount(email: poultryEmail, accountId: 'poultry');
      await other.addField(
        name: 'Hen run',
        sizeAcres: 0.1,
        soil: SoilType.clay,
        note: '',
      );

      final FarmRepository repository = await openFarmer();
      await repository.resetToSample();

      final FarmRepository poultryAgain = FarmRepository(prefs);
      poultryAgain.openAccount(email: poultryEmail, accountId: 'poultry');
      expect(poultryAgain.fields.single.name, 'Hen run');
    });
  });
}
