import '../shared/logic/app_clock.dart';
import '../shared/logic/crop_growth.dart';
import 'crop_catalog.dart';

/// One corner of a drawn field shape.
///
/// Both numbers are 0.0 to 1.0 inside the map box, so the shape works at any
/// screen size.
class MapPoint {
  const MapPoint({required this.x, required this.y});

  factory MapPoint.fromJson(Map<String, dynamic> json) => MapPoint(
    x: _toDouble(json['x']).clamp(0.0, 1.0),
    y: _toDouble(json['y']).clamp(0.0, 1.0),
  );

  /// Across the box, 0.0 at the left edge and 1.0 at the right.
  final double x;

  /// Down the box, 0.0 at the top edge and 1.0 at the bottom.
  final double y;

  MapPoint copyWith({double? x, double? y}) =>
      MapPoint(x: x ?? this.x, y: y ?? this.y);

  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      other is MapPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// One crop growing in a field.
class Crop {
  const Crop({
    required this.id,
    required this.typeId,
    required this.plantedOn,
    required this.plants,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    id: json['id'] as String,
    typeId: json['typeId'] as String,
    plantedOn: DateTime.parse(json['plantedOn'] as String),
    plants: (json['plants'] as num).toInt(),
  );

  final String id;

  /// The crop type id from the catalog, for example "tomato".
  final String typeId;

  /// The planting date. The time of day is always removed.
  final DateTime plantedOn;

  /// How many plants were put in.
  final int plants;

  /// The crop type name, for example "Tomato".
  String get name => CropCatalog.nameOf(typeId);

  /// Stage, progress, days left and the harvest date.
  CropGrowth get growth => CropGrowth.of(typeId: typeId, plantedOn: plantedOn);

  Crop copyWith({String? typeId, DateTime? plantedOn, int? plants}) => Crop(
    id: id,
    typeId: typeId ?? this.typeId,
    plantedOn: plantedOn ?? this.plantedOn,
    plants: plants ?? this.plants,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'typeId': typeId,
    'plantedOn': AppClock.dateOnly(plantedOn).toIso8601String(),
    'plants': plants,
  };
}

/// One crop that has already been picked.
class Harvest {
  const Harvest({
    required this.id,
    required this.typeId,
    required this.plantedOn,
    required this.harvestedOn,
    required this.amountKg,
  });

  factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
    id: json['id'] as String,
    typeId: json['typeId'] as String,
    plantedOn: DateTime.parse(json['plantedOn'] as String),
    harvestedOn: DateTime.parse(json['harvestedOn'] as String),
    amountKg: (json['amountKg'] as num).toDouble(),
  );

  final String id;
  final String typeId;
  final DateTime plantedOn;
  final DateTime harvestedOn;

  /// How much was picked, in kilograms, with 2 decimals.
  final double amountKg;

  /// The crop type name, for example "Lettuce".
  String get name => CropCatalog.nameOf(typeId);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'typeId': typeId,
    'plantedOn': AppClock.dateOnly(plantedOn).toIso8601String(),
    'harvestedOn': AppClock.dateOnly(harvestedOn).toIso8601String(),
    'amountKg': amountKg,
  };
}

/// The four soil types a field can have.
enum SoilType {
  loam('Loam'),
  clay('Clay'),
  sandy('Sandy'),
  silt('Silt');

  const SoilType(this.label);

  /// The soil name as shown on screen.
  final String label;

  /// The soil type saved under this name, or Loam when the name is unknown.
  static SoilType fromName(String name) {
    for (final SoilType soil in SoilType.values) {
      if (soil.name == name) return soil;
    }
    return SoilType.loam;
  }
}

/// One field, with its drawn shape, its crops and its past harvests.
class Field {
  const Field({
    required this.id,
    required this.name,
    required this.sizeAcres,
    required this.soil,
    this.note = '',
    required this.corners,
    this.crops = const <Crop>[],
    this.harvests = const <Harvest>[],
  });

  factory Field.fromJson(Map<String, dynamic> json) => Field(
    id: json['id'] as String,
    name: json['name'] as String,
    sizeAcres: (json['sizeAcres'] as num).toDouble(),
    soil: SoilType.fromName(json['soil'] as String),
    note: (json['note'] as String?) ?? '',
    corners: <MapPoint>[
      for (final dynamic point in json['corners'] as List<dynamic>)
        MapPoint.fromJson(point as Map<String, dynamic>),
    ],
    crops: <Crop>[
      for (final dynamic crop in (json['crops'] as List<dynamic>? ?? const []))
        Crop.fromJson(crop as Map<String, dynamic>),
    ],
    harvests: <Harvest>[
      for (final dynamic h in (json['harvests'] as List<dynamic>? ?? const []))
        Harvest.fromJson(h as Map<String, dynamic>),
    ],
  );

  /// The shape a brand new field starts with: a rectangle in the middle.
  static const List<MapPoint> defaultCorners = <MapPoint>[
    MapPoint(x: 0.2, y: 0.2),
    MapPoint(x: 0.8, y: 0.2),
    MapPoint(x: 0.8, y: 0.8),
    MapPoint(x: 0.2, y: 0.8),
  ];

  final String id;

  /// The field name, for example "Field 2 · South bed".
  final String name;

  /// The size the user typed, in acres, with 2 decimals.
  final double sizeAcres;

  final SoilType soil;

  /// An optional note, up to 120 characters. Empty when there is none.
  final String note;

  /// The four corners of the drawn shape, clockwise from the top left.
  final List<MapPoint> corners;

  final List<Crop> crops;

  /// Past harvests, newest first.
  final List<Harvest> harvests;

  /// "0.4", the size with the trailing zeros trimmed.
  String get sizeText {
    final String fixed = sizeAcres.toStringAsFixed(2);
    if (fixed.endsWith('00')) return fixed.substring(0, fixed.length - 3);
    if (fixed.endsWith('0')) return fixed.substring(0, fixed.length - 1);
    return fixed;
  }

  /// "2 crops", "1 crop" or "No crops".
  String get cropCountText {
    if (crops.isEmpty) return 'No crops';
    if (crops.length == 1) return '1 crop';
    return '${crops.length} crops';
  }

  /// "0.4 acre · Loam · 2 crops", the line on the field card.
  String get summaryLine => '$sizeText acre · ${soil.label} · $cropCountText';

  /// "0.4 acre · Loam", the line under the field detail title.
  String get shortLine => '$sizeText acre · ${soil.label}';

  /// The crop with the soonest harvest, or null when the field is empty.
  Crop? get mainCrop {
    if (crops.isEmpty) return null;
    final List<Crop> sorted = cropsByDaysLeft;
    return sorted.first;
  }

  /// The crops sorted by days left, soonest first.
  List<Crop> get cropsByDaysLeft {
    final List<Crop> sorted = List<Crop>.of(crops);
    sorted.sort((Crop a, Crop b) {
      final int byDays = a.growth.daysLeft.compareTo(b.growth.daysLeft);
      return byDays != 0 ? byDays : a.name.compareTo(b.name);
    });
    return sorted;
  }

  /// Days left of the soonest crop, or null when the field has no crops.
  int? get soonestDaysLeft => mainCrop?.growth.daysLeft;

  /// True when a crop is 14 days or less from harvest.
  bool get hasHarvestSoon {
    final int? days = soonestDaysLeft;
    return days != null && days <= 14;
  }

  /// The area of the drawn shape, which is only a picture and never changes
  /// [sizeAcres].
  Field copyWith({
    String? name,
    double? sizeAcres,
    SoilType? soil,
    String? note,
    List<MapPoint>? corners,
    List<Crop>? crops,
    List<Harvest>? harvests,
  }) => Field(
    id: id,
    name: name ?? this.name,
    sizeAcres: sizeAcres ?? this.sizeAcres,
    soil: soil ?? this.soil,
    note: note ?? this.note,
    corners: corners ?? this.corners,
    crops: crops ?? this.crops,
    harvests: harvests ?? this.harvests,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'sizeAcres': sizeAcres,
    'soil': soil.name,
    'note': note,
    'corners': <Map<String, dynamic>>[
      for (final MapPoint point in corners) point.toJson(),
    ],
    'crops': <Map<String, dynamic>>[
      for (final Crop crop in crops) crop.toJson(),
    ],
    'harvests': <Map<String, dynamic>>[
      for (final Harvest harvest in harvests) harvest.toJson(),
    ],
  };
}

double _toDouble(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
