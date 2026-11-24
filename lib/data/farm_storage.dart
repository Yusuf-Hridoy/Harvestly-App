import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animal_models.dart';
import 'farm_models.dart';
import 'sample_farm_data.dart';

/// Everything one account has saved: its fields and its animal groups.
class FarmSnapshot {
  const FarmSnapshot({required this.fields, required this.animals});

  /// The account's starting sample, used on the first run and by Reset
  /// demo data.
  factory FarmSnapshot.sample(String accountId) => FarmSnapshot(
    fields: SampleFarmData.startingFields(accountId),
    animals: SampleFarmData.startingGroups(accountId),
  );

  final List<Field> fields;
  final List<AnimalGroup> animals;
}

/// Why a load ended up with the starting sample instead of saved data.
enum FarmLoadOutcome {
  /// Nothing was saved yet, so the account starts from its sample.
  firstRun,

  /// Phase 2 data with no version. The fields were kept and sample animals
  /// were added.
  migrated,

  /// Saved data at the current version, loaded as it was.
  loaded,

  /// The saved text could not be read, or came from a newer app. It was
  /// copied to a backup key and the sample was loaded instead.
  recovered,
}

/// What one load produced.
class FarmLoad {
  const FarmLoad({
    required this.snapshot,
    required this.outcome,
    required this.needsSave,
  });

  final FarmSnapshot snapshot;
  final FarmLoadOutcome outcome;

  /// Whether the loaded data must be written back at once, so the next start
  /// reads the current version.
  final bool needsSave;
}

/// Reads and writes one account's farm data, and keeps old saves working.
///
/// Every change to the saved shape goes through here. A new phase raises
/// [schemaVersion] and adds one more step to [_migrate], so the rest of the
/// app never deals with old data.
class FarmStorage {
  const FarmStorage(this._prefs);

  /// The version the app writes today.
  static const int schemaVersion = 2;

  /// The start of the storage key. The account email is added to it.
  static const String keyPrefix = 'farm_data_';

  /// Where unreadable data is parked before the sample replaces it.
  static const String backupKeyPrefix = 'farm_data_backup_';

  /// The start of every warning this file prints.
  static const String logPrefix = 'Harvestly storage:';

  final SharedPreferences _prefs;

  /// The storage key for an account email.
  static String keyFor(String accountEmail) => '$keyPrefix$accountEmail';

  /// The backup key for an account email.
  static String backupKeyFor(String accountEmail) =>
      '$backupKeyPrefix$accountEmail';

  /// Loads an account's data, upgrading or recovering it when needed.
  ///
  /// It never throws and never returns an empty farm because of a bad save:
  /// anything it cannot read is backed up and replaced by the sample.
  FarmLoad load({required String email, required String accountId}) {
    final String? stored = _prefs.getString(keyFor(email));

    if (stored == null) {
      return FarmLoad(
        snapshot: FarmSnapshot.sample(accountId),
        outcome: FarmLoadOutcome.firstRun,
        needsSave: true,
      );
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(stored) as Map<String, dynamic>;
      final int version = (json['schemaVersion'] as num?)?.toInt() ?? 1;

      if (version > schemaVersion) {
        return _recover(
          email: email,
          accountId: accountId,
          stored: stored,
          why:
              'saved data is version $version, '
              'but this app only knows version $schemaVersion',
        );
      }

      return _migrate(json: json, version: version, accountId: accountId);
    } catch (error) {
      return _recover(
        email: email,
        accountId: accountId,
        stored: stored,
        why: 'saved data could not be read ($error)',
      );
    }
  }

  /// Saves a snapshot at the current version.
  Future<void> save({
    required String email,
    required FarmSnapshot snapshot,
  }) async {
    await _prefs.setString(keyFor(email), encode(snapshot));
  }

  /// The JSON text one snapshot is saved as.
  static String encode(FarmSnapshot snapshot) => jsonEncode(<String, dynamic>{
    'schemaVersion': schemaVersion,
    'fields': <Map<String, dynamic>>[
      for (final Field field in snapshot.fields) field.toJson(),
    ],
    'animals': <Map<String, dynamic>>[
      for (final AnimalGroup group in snapshot.animals) group.toJson(),
    ],
  });

  /// Brings saved data up to [schemaVersion].
  ///
  /// Version 1 is Phase 2 data: fields only, with no version number. Its
  /// fields are kept exactly as they are and the account's sample animals
  /// are added, because Phase 2 could not have any.
  FarmLoad _migrate({
    required Map<String, dynamic> json,
    required int version,
    required String accountId,
  }) {
    final List<Field> fields = <Field>[
      for (final dynamic field
          in (json['fields'] as List<dynamic>? ?? const []))
        Field.fromJson(field as Map<String, dynamic>),
    ];

    if (version < 2) {
      return FarmLoad(
        snapshot: FarmSnapshot(
          fields: fields,
          animals: SampleFarmData.startingGroups(accountId),
        ),
        outcome: FarmLoadOutcome.migrated,
        needsSave: true,
      );
    }

    return FarmLoad(
      snapshot: FarmSnapshot(
        fields: fields,
        animals: <AnimalGroup>[
          for (final dynamic group
              in (json['animals'] as List<dynamic>? ?? const []))
            AnimalGroup.fromJson(group as Map<String, dynamic>),
        ],
      ),
      outcome: FarmLoadOutcome.loaded,
      needsSave: false,
    );
  }

  /// Parks data the app cannot use and starts the account again.
  FarmLoad _recover({
    required String email,
    required String accountId,
    required String stored,
    required String why,
  }) {
    debugPrint(
      '$logPrefix $why. The old data was copied to '
      '${backupKeyFor(email)} and the starting sample was loaded.',
    );
    // Fire and forget: the backup must never hold up the screen, and the
    // sample below is already safe to show.
    _prefs.setString(backupKeyFor(email), stored);
    return FarmLoad(
      snapshot: FarmSnapshot.sample(accountId),
      outcome: FarmLoadOutcome.recovered,
      needsSave: true,
    );
  }
}
