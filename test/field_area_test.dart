import 'package:flutter_test/flutter_test.dart';
import 'package:harvestly/data/farm_models.dart';
import 'package:harvestly/shared/logic/field_area.dart';

void main() {
  /// A rectangle from (left, top) to (right, bottom), clockwise from the top
  /// left, the same order the map uses.
  List<MapPoint> box(double left, double top, double right, double bottom) =>
      <MapPoint>[
        MapPoint(x: left, y: top),
        MapPoint(x: right, y: top),
        MapPoint(x: right, y: bottom),
        MapPoint(x: left, y: bottom),
      ];

  test('the whole map box is 1.00 acre', () {
    expect(FieldArea.acresNumber(box(0, 0, 1, 1)), '1.00');
  });

  test('half the box is 0.50 acre', () {
    expect(FieldArea.acresNumber(box(0, 0, 1, 0.5)), '0.50');
    expect(FieldArea.acresNumber(box(0, 0, 0.5, 1)), '0.50');
  });

  test('a shape with a known area comes out right', () {
    // 0.8 wide by 0.75 tall is 0.60.
    expect(FieldArea.acresNumber(box(0.1, 0.15, 0.9, 0.9)), '0.60');
  });

  test(
    'a four corner shape that is not a rectangle uses the shoelace area',
    () {
      // Worked out by hand: the shoelace sum is 1.08, so the area is 0.54.
      final List<MapPoint> shape = <MapPoint>[
        const MapPoint(x: 0.1, y: 0.2),
        const MapPoint(x: 0.9, y: 0.1),
        const MapPoint(x: 0.9, y: 0.85),
        const MapPoint(x: 0.1, y: 0.8),
      ];
      expect(FieldArea.acres(shape), closeTo(0.54, 0.0001));
      expect(FieldArea.acresNumber(shape), '0.54');
    },
  );

  test('the corner order does not change the area', () {
    final List<MapPoint> clockwise = box(0.2, 0.25, 0.8, 0.75);
    final List<MapPoint> other = clockwise.reversed.toList();
    expect(FieldArea.acres(other), closeTo(FieldArea.acres(clockwise), 1e-9));
  });

  test('a flat shape has no area', () {
    expect(FieldArea.acresNumber(box(0.2, 0.5, 0.8, 0.5)), '0.00');
  });

  test('the label reads "Area ~ 0.42 acre"', () {
    // 0.6 wide by 0.7 tall is 0.42.
    expect(FieldArea.label(box(0.2, 0.1, 0.8, 0.8)), 'Area ≈ 0.42 acre');
  });
}
