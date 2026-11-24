import '../../data/crop_catalog.dart';
import 'app_clock.dart';

/// How far along a crop is.
enum CropStage {
  seedling('Seedling'),
  growing('Growing'),
  flowering('Flowering'),
  ready('Ready to harvest');

  const CropStage(this.label);

  /// The stage name as shown on screen.
  final String label;
}

/// Everything the screens need to know about one crop's growth.
///
/// All the maths uses whole days and reads today from [AppClock], so tests
/// can fix the date.
class CropGrowth {
  const CropGrowth({
    required this.plantedOn,
    required this.harvestOn,
    required this.daysToHarvest,
    required this.daysLeft,
    required this.percent,
  });

  /// Works out the growth of a crop type planted on a date.
  factory CropGrowth.of({required String typeId, required DateTime plantedOn}) {
    final int days = CropCatalog.daysToHarvestOf(typeId);
    final DateTime planted = AppClock.dateOnly(plantedOn);
    final DateTime harvest = planted.add(Duration(days: days));
    final int since = AppClock.daysBetween(planted, AppClock.today());

    final int left = AppClock.daysBetween(AppClock.today(), harvest);
    final int percent = days <= 0
        ? 100
        : ((since / days) * 100).floor().clamp(0, 100);

    return CropGrowth(
      plantedOn: planted,
      harvestOn: harvest,
      daysToHarvest: days,
      daysLeft: left < 0 ? 0 : left,
      percent: percent,
    );
  }

  /// The planting date, with the time of day removed.
  final DateTime plantedOn;

  /// Planting date plus the crop's days to harvest.
  final DateTime harvestOn;

  /// The crop type's days to harvest.
  final int daysToHarvest;

  /// Days from today to the harvest date, never below 0.
  final int daysLeft;

  /// How far along, from 0 to 100, always rounded down.
  final int percent;

  /// The same progress as a 0.0 to 1.0 value, for progress bars.
  double get progress => percent / 100;

  /// Which of the four stages the crop is in.
  CropStage get stage {
    if (percent >= 100) return CropStage.ready;
    if (percent >= 60) return CropStage.flowering;
    if (percent >= 25) return CropStage.growing;
    return CropStage.seedling;
  }

  /// "12 days left", "1 day left" or "Ready to harvest".
  String get daysLeftText {
    if (stage == CropStage.ready) return CropStage.ready.label;
    if (daysLeft == 1) return '1 day left';
    return '$daysLeft days left';
  }
}
