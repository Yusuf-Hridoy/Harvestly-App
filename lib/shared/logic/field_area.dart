import '../../data/farm_models.dart';

/// Works out how big a drawn field shape is.
///
/// The whole map box counts as 1.00 acre, and the corners are 0.0 to 1.0
/// inside that box, so the shoelace area of the corners is the acres.
class FieldArea {
  const FieldArea._();

  /// The area of the shape in acres.
  static double acres(List<MapPoint> corners) {
    if (corners.length < 3) return 0;
    double sum = 0;
    for (int i = 0; i < corners.length; i++) {
      final MapPoint a = corners[i];
      final MapPoint b = corners[(i + 1) % corners.length];
      sum += a.x * b.y - b.x * a.y;
    }
    return (sum.abs() / 2);
  }

  /// "0.42", the area with 2 decimals.
  static String acresNumber(List<MapPoint> corners) =>
      acres(corners).toStringAsFixed(2);

  /// "Area ≈ 0.42 acre", the label shown under the map.
  static String label(List<MapPoint> corners) =>
      'Area ≈ ${acresNumber(corners)} acre';
}
