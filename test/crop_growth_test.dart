import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/shared/logic/app_clock.dart';
import 'package:harvestly/shared/logic/crop_growth.dart';

void main() {
  /// A fixed date, so the numbers never depend on the real day.
  final DateTime today = DateTime(2026, 11, 24);

  setUp(() => AppClock.useFixed(today));
  tearDown(AppClock.useRealClock);

  /// A tomato takes 65 days. Planting it [daysAgo] days ago gives a known
  /// progress, which keeps the boundary tests easy to read.
  CropGrowth tomatoPlanted(int daysAgo) => CropGrowth.of(
    typeId: 'tomato',
    plantedOn: today.subtract(Duration(days: daysAgo)),
  );

  group('harvest date', () {
    test('is the planting date plus the crop days', () {
      final CropGrowth growth = CropGrowth.of(
        typeId: 'tomato',
        plantedOn: DateTime(2026, 10, 2),
      );
      expect(growth.harvestOn, DateTime(2026, 12, 6));
      expect(growth.daysToHarvest, 65);
    });

    test('ignores the time of day on the planting date', () {
      final CropGrowth growth = CropGrowth.of(
        typeId: 'radish',
        plantedOn: DateTime(2026, 11, 1, 19, 30),
      );
      expect(growth.plantedOn, DateTime(2026, 11, 1));
      expect(growth.harvestOn, DateTime(2026, 12, 1));
    });
  });

  group('days left', () {
    test('counts the whole days to the harvest date', () {
      expect(tomatoPlanted(53).daysLeft, 12);
    });

    test('is never below 0, even long after the harvest date', () {
      expect(tomatoPlanted(200).daysLeft, 0);
    });

    test('is 0 on the harvest date itself', () {
      expect(tomatoPlanted(65).daysLeft, 0);
    });
  });

  group('progress', () {
    test('is 0 on the planting day', () {
      expect(tomatoPlanted(0).percent, 0);
    });

    test('is always rounded down', () {
      // 53 of 65 days is 81.53%.
      expect(tomatoPlanted(53).percent, 81);
    });

    test('never goes past 100', () {
      expect(tomatoPlanted(200).percent, 100);
    });

    test('matches the progress bar value', () {
      expect(tomatoPlanted(53).progress, closeTo(0.81, 0.001));
    });
  });

  group('stage boundaries', () {
    // Spinach takes 40 days, so one day is exactly 2.5%.
    CropGrowth spinachAt(int daysAgo) => CropGrowth.of(
      typeId: 'spinach',
      plantedOn: today.subtract(Duration(days: daysAgo)),
    );

    test('24% is still Seedling', () {
      // 9 of 40 days is 22.5%, which floors to 22.
      expect(spinachAt(9).percent, 22);
      expect(spinachAt(9).stage, CropStage.seedling);
    });

    test('25% is Growing', () {
      expect(spinachAt(10).percent, 25);
      expect(spinachAt(10).stage, CropStage.growing);
    });

    test('59% is still Growing', () {
      // 23 of 40 days is 57.5%.
      expect(spinachAt(23).percent, 57);
      expect(spinachAt(23).stage, CropStage.growing);
    });

    test('60% is Flowering', () {
      expect(spinachAt(24).percent, 60);
      expect(spinachAt(24).stage, CropStage.flowering);
    });

    test('99% is still Flowering', () {
      // 39 of 40 days is 97.5%.
      expect(spinachAt(39).percent, 97);
      expect(spinachAt(39).stage, CropStage.flowering);
    });

    test('100% is Ready to harvest', () {
      expect(spinachAt(40).percent, 100);
      expect(spinachAt(40).stage, CropStage.ready);
    });
  });

  group('days left text', () {
    test('uses the plural for more than one day', () {
      expect(tomatoPlanted(53).daysLeftText, '12 days left');
    });

    test('uses "1 day left" for exactly one day', () {
      expect(tomatoPlanted(64).daysLeftText, '1 day left');
    });

    test('says "Ready to harvest" instead of "0 days left"', () {
      expect(tomatoPlanted(65).daysLeftText, 'Ready to harvest');
      expect(tomatoPlanted(200).daysLeftText, 'Ready to harvest');
    });
  });
}
