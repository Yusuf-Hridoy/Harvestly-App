import 'app_routes.dart';

/// Turns a `harvestly://app/...` link into a route the app can open.
///
/// Flutter hands the router only the path of a link, never the host, so
/// every Harvestly link uses the same host, `app`. In
/// `harvestly://app/tasks/task-4` the path is then `/tasks/task-4`, which is
/// already a route. Without the host, `tasks` would be read as the host and
/// lost.
class DeepLinks {
  const DeepLinks._();

  /// The scheme in AndroidManifest.xml.
  static const String scheme = 'harvestly';

  /// The fixed host, so the rest of the link is the route path.
  static const String host = 'app';

  /// Shown when a link points at nothing Harvestly knows.
  static const String badLinkMessage = "That link doesn't work.";

  /// The paths a link may open, each with how many parts it has.
  static const Map<String, bool> _listsThatTakeAnId = <String, bool>{
    'home': false,
    'fields': true,
    'animals': true,
    'tasks': true,
  };

  /// Path parts that are screens of their own, never an item id.
  static const Set<String> _notAnId = <String>{'new', 'edit'};

  /// The route a link or path should open, or null when it is not one of
  /// ours.
  ///
  /// Takes a full link (`harvestly://app/tasks/task-4`) or a bare path
  /// (`/tasks/task-4?tab=health`). The query is kept, so the Animals tab
  /// name survives.
  static String? safePath(String? link) {
    if (link == null || link.isEmpty) return null;

    final Uri? uri = Uri.tryParse(link);
    if (uri == null) return null;

    // A full link must be ours. A bare path must really be a path, so an
    // address like "https://example.com/tasks" can never get through.
    if (uri.hasScheme) {
      if (uri.scheme != scheme || uri.host != host) return null;
    } else if (!link.startsWith('/')) {
      return null;
    }

    final List<String> parts = uri.pathSegments
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty || parts.length > 2) return null;

    final bool? takesId = _listsThatTakeAnId[parts.first];
    if (takesId == null) return null;
    if (parts.length == 2) {
      if (!takesId) return null;
      if (_notAnId.contains(parts[1])) return null;
    }

    final String path = '/${parts.join('/')}';
    final String tab = uri.queryParameters[AppRoutes.tabQuery] ?? '';
    // Only the Animals tab name is carried over; nothing else is needed.
    if (tab.isEmpty || parts.first != 'animals' || parts.length != 2) {
      return path;
    }
    return '$path?${AppRoutes.tabQuery}=${Uri.encodeComponent(tab)}';
  }
}
