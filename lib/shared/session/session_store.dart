import 'package:shared_preferences/shared_preferences.dart';

/// Saves "remember me" and the logged-in account on the phone.
///
/// When "remember me" is off, the session is kept in memory only, so closing
/// the app logs the user out.
class SessionStore {
  SessionStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _rememberMeKey = 'session_remember_me';
  static const String _accountEmailKey = 'session_account_email';

  /// The email saved on the phone, or null when nothing is saved.
  String? savedAccountEmail() {
    if (!rememberMe()) return null;
    return _prefs.getString(_accountEmailKey);
  }

  /// Whether the last login asked to be remembered.
  bool rememberMe() => _prefs.getBool(_rememberMeKey) ?? false;

  /// Stores the session. Nothing is written when [rememberMe] is false.
  Future<void> save({required String email, required bool rememberMe}) async {
    await _prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await _prefs.setString(_accountEmailKey, email);
    } else {
      await _prefs.remove(_accountEmailKey);
    }
  }

  /// Removes the saved session. The theme choice is left alone.
  Future<void> clear() async {
    await _prefs.remove(_accountEmailKey);
    await _prefs.setBool(_rememberMeKey, false);
  }
}
