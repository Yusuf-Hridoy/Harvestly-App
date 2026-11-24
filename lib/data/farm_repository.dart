import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/logic/app_clock.dart';
import 'farm_models.dart';
import 'sample_farm_data.dart';

/// Holds the fields, crops and past harvests of the account that is logged in.
///
/// Everything is kept on the phone as JSON in shared_preferences, under one
/// key per account. Every change is saved at once, so nothing is lost when the
/// app closes. There is no backend.
class FarmRepository extends ChangeNotifier {
  FarmRepository(this._prefs);

  /// The start of the storage key. The account email is added to it.
  static const String keyPrefix = 'farm_data_';

  final SharedPreferences _prefs;

  String? _accountEmail;
  String? _accountId;
  List<Field> _fields = <Field>[];
  int _idCounter = 0;

  /// The email of the account whose data is loaded, or null when nobody is
  /// logged in.
  String? get accountEmail => _accountEmail;

  /// Every field of the logged-in account, in the order they were added.
  List<Field> get fields => List<Field>.unmodifiable(_fields);

  /// How many crops are growing across all fields.
  int get cropCount =>
      _fields.fold(0, (int total, Field field) => total + field.crops.length);

  /// The storage key for an account email.
  static String keyFor(String accountEmail) => '$keyPrefix$accountEmail';

  /// Loads an account's saved data, or its starting sample the first time.
  ///
  /// Call it again with the same account and nothing happens, so it is safe
  /// to call on every rebuild.
  void openAccount({required String email, required String accountId}) {
    if (_accountEmail == email) return;
    _accountEmail = email;
    _accountId = accountId;

    final String? stored = _prefs.getString(keyFor(email));
    if (stored == null) {
      _fields = SampleFarmData.startingFields(accountId);
      unawaited(_save());
    } else {
      _fields = _decode(stored);
    }
    notifyListeners();
  }

  /// Forgets the loaded data. Called when the user logs out.
  void closeAccount() {
    if (_accountEmail == null) return;
    _accountEmail = null;
    _accountId = null;
    _fields = <Field>[];
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
  Future<void> deleteField(String fieldId) async {
    _fields = _fields.where((Field field) => field.id != fieldId).toList();
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

  /// Puts this account's fields and crops back to the starting sample.
  ///
  /// It does not touch any other account, the theme or the session.
  Future<void> resetToSample() async {
    final String? accountId = _accountId;
    if (accountId == null) return;
    _fields = SampleFarmData.startingFields(accountId);
    await _saveAndTell();
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
    await _save();
  }

  Future<void> _save() async {
    final String? email = _accountEmail;
    if (email == null) return;
    final String json = jsonEncode(<String, dynamic>{
      'fields': <Map<String, dynamic>>[
        for (final Field field in _fields) field.toJson(),
      ],
    });
    await _prefs.setString(keyFor(email), json);
  }

  static List<Field> _decode(String stored) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(stored) as Map<String, dynamic>;
      return <Field>[
        for (final dynamic field in json['fields'] as List<dynamic>)
          Field.fromJson(field as Map<String, dynamic>),
      ];
    } catch (_) {
      // Broken or old saved data should never stop the app starting.
      return <Field>[];
    }
  }
}
