/// One crop type a user can plant.
class CropType {
  const CropType({
    required this.id,
    required this.name,
    required this.daysToHarvest,
  });

  /// The name in lowercase snake_case, for example "green_chili".
  final String id;

  /// The name as shown on screen, for example "Green chili".
  final String name;

  /// How many whole days from planting to harvest.
  final int daysToHarvest;
}

/// The 40 crop types Harvestly knows, sorted A to Z.
///
/// The list never changes, so test IDs in the crop picker use the type id
/// instead of a position.
class CropCatalog {
  const CropCatalog._();

  static const List<CropType> all = <CropType>[
    CropType(id: 'amaranth', name: 'Amaranth', daysToHarvest: 30),
    CropType(id: 'bitter_gourd', name: 'Bitter gourd', daysToHarvest: 60),
    CropType(id: 'bottle_gourd', name: 'Bottle gourd', daysToHarvest: 60),
    CropType(id: 'brinjal', name: 'Brinjal', daysToHarvest: 80),
    CropType(id: 'broccoli', name: 'Broccoli', daysToHarvest: 70),
    CropType(id: 'bush_beans', name: 'Bush beans', daysToHarvest: 55),
    CropType(id: 'cabbage', name: 'Cabbage', daysToHarvest: 85),
    CropType(id: 'capsicum', name: 'Capsicum', daysToHarvest: 75),
    CropType(id: 'carrot', name: 'Carrot', daysToHarvest: 75),
    CropType(id: 'cauliflower', name: 'Cauliflower', daysToHarvest: 80),
    CropType(id: 'coriander', name: 'Coriander', daysToHarvest: 40),
    CropType(id: 'cucumber', name: 'Cucumber', daysToHarvest: 55),
    CropType(id: 'garlic', name: 'Garlic', daysToHarvest: 140),
    CropType(id: 'ginger', name: 'Ginger', daysToHarvest: 150),
    CropType(id: 'green_chili', name: 'Green chili', daysToHarvest: 70),
    CropType(id: 'green_peas', name: 'Green peas', daysToHarvest: 65),
    CropType(id: 'kale', name: 'Kale', daysToHarvest: 55),
    CropType(id: 'lettuce', name: 'Lettuce', daysToHarvest: 45),
    CropType(id: 'long_beans', name: 'Long beans', daysToHarvest: 60),
    CropType(id: 'maize', name: 'Maize', daysToHarvest: 100),
    CropType(id: 'mint', name: 'Mint', daysToHarvest: 60),
    CropType(id: 'mustard_greens', name: 'Mustard greens', daysToHarvest: 40),
    CropType(id: 'okra', name: 'Okra', daysToHarvest: 55),
    CropType(id: 'onion', name: 'Onion', daysToHarvest: 120),
    CropType(id: 'potato', name: 'Potato', daysToHarvest: 90),
    CropType(id: 'pumpkin', name: 'Pumpkin', daysToHarvest: 95),
    CropType(id: 'radish', name: 'Radish', daysToHarvest: 30),
    CropType(id: 'rice', name: 'Rice', daysToHarvest: 120),
    CropType(id: 'ridge_gourd', name: 'Ridge gourd', daysToHarvest: 60),
    CropType(id: 'spinach', name: 'Spinach', daysToHarvest: 40),
    CropType(id: 'spring_onion', name: 'Spring onion', daysToHarvest: 45),
    CropType(id: 'strawberry', name: 'Strawberry', daysToHarvest: 90),
    CropType(id: 'sweet_corn', name: 'Sweet corn', daysToHarvest: 80),
    CropType(id: 'sweet_potato', name: 'Sweet potato', daysToHarvest: 110),
    CropType(id: 'tomatillo', name: 'Tomatillo', daysToHarvest: 75),
    CropType(id: 'tomato', name: 'Tomato', daysToHarvest: 65),
    CropType(id: 'turnip', name: 'Turnip', daysToHarvest: 50),
    CropType(id: 'watermelon', name: 'Watermelon', daysToHarvest: 85),
    CropType(id: 'wheat', name: 'Wheat', daysToHarvest: 120),
    CropType(id: 'zucchini', name: 'Zucchini', daysToHarvest: 50),
  ];

  /// How many crop types there are. Used by the "4 of 40" line.
  static int get count => all.length;

  /// The type with this id, or null when the id is unknown.
  static CropType? byId(String id) {
    for (final CropType type in all) {
      if (type.id == id) return type;
    }
    return null;
  }

  /// The name for a type id, or the id itself when the type is unknown.
  static String nameOf(String id) => byId(id)?.name ?? id;

  /// Days to harvest for a type id, or 0 when the type is unknown.
  static int daysToHarvestOf(String id) => byId(id)?.daysToHarvest ?? 0;

  /// The types whose name contains [text], ignoring case. Empty text gives
  /// the whole catalog.
  static List<CropType> search(String text) {
    final String needle = text.trim().toLowerCase();
    if (needle.isEmpty) return all;
    return all
        .where((CropType type) => type.name.toLowerCase().contains(needle))
        .toList();
  }
}
