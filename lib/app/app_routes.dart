/// Every route path in Harvestly, in one place.
///
/// Screens build their links from here, so no screen writes a path by hand.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String fields = '/fields';
  static const String animals = '/animals';
  static const String tasks = '/tasks';
  static const String more = '/more';

  /// Add a field.
  static const String fieldNew = '/fields/new';

  /// The route parameter names used inside the Fields tab.
  static const String fieldIdParam = 'fieldId';
  static const String cropIdParam = 'cropId';

  /// One field's detail screen.
  static String fieldDetail(String fieldId) => '/fields/$fieldId';

  /// Edit one field.
  static String fieldEdit(String fieldId) => '/fields/$fieldId/edit';

  /// Add a crop to one field.
  static String cropNew(String fieldId) => '/fields/$fieldId/crops/new';

  /// One crop's detail screen.
  static String cropDetail(String fieldId, String cropId) =>
      '/fields/$fieldId/crops/$cropId';
}
