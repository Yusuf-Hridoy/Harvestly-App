import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the System / Light / Dark choice and saves it on the phone.
///
/// The choice survives a restart and a logout.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) : _mode = _readMode(_prefs);

  static const String _storageKey = 'settings_theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Changes the theme at once and saves it.
  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _prefs.setString(_storageKey, _nameOf(mode));
  }

  static ThemeMode _readMode(SharedPreferences prefs) {
    switch (prefs.getString(_storageKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _nameOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
