import 'package:flutter/foundation.dart';

import '../../data/demo_accounts.dart';
import '../../shared/session/session_store.dart';

/// Holds who is logged in, checks the login form, and logs out.
///
/// There is no backend. A valid login waits 800 ms on purpose so tests have a
/// real wait to handle.
class LoginController extends ChangeNotifier {
  LoginController(this._sessionStore, {DemoAccount? startAccount})
    : _account = startAccount;

  /// How long the fake network wait takes.
  static const Duration fakeNetworkWait = Duration(milliseconds: 800);

  static const String emailEmptyError = 'Please enter your email.';
  static const String emailFormatError = 'Please enter a valid email.';
  static const String passwordEmptyError = 'Please enter your password.';
  static const String wrongDetailsError = 'Email or password is wrong.';

  final SessionStore _sessionStore;

  DemoAccount? _account;
  String? _emailError;
  String? _passwordError;
  String? _bannerError;
  bool _busy = false;

  /// The logged-in account, or null when nobody is logged in.
  DemoAccount? get account => _account;

  bool get isLoggedIn => _account != null;

  /// Message under the email field, or null.
  String? get emailError => _emailError;

  /// Message under the password field, or null.
  String? get passwordError => _passwordError;

  /// Message in the red banner above the button, or null.
  String? get bannerError => _bannerError;

  /// True while the fake network wait is running.
  bool get busy => _busy;

  /// Clears the email error as soon as the user types in that field.
  void onEmailChanged() {
    if (_emailError == null) return;
    _emailError = null;
    notifyListeners();
  }

  /// Clears the password error as soon as the user types in that field.
  void onPasswordChanged() {
    if (_passwordError == null) return;
    _passwordError = null;
    notifyListeners();
  }

  /// Clears every message. Used when the demo "Use" buttons fill the form.
  void clearErrors() {
    if (_emailError == null && _passwordError == null && _bannerError == null) {
      return;
    }
    _emailError = null;
    _passwordError = null;
    _bannerError = null;
    notifyListeners();
  }

  /// Checks the form and logs in. Returns true when the login worked.
  Future<bool> submit({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (_busy) return false;

    _bannerError = null;
    _emailError = _checkEmail(email);
    _passwordError = password.isEmpty ? passwordEmptyError : null;

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    _busy = true;
    notifyListeners();

    await Future<void>.delayed(fakeNetworkWait);

    final DemoAccount? found = DemoAccounts.signIn(email, password);
    _busy = false;

    if (found == null) {
      _bannerError = wrongDetailsError;
      notifyListeners();
      return false;
    }

    await _sessionStore.save(email: found.email, rememberMe: rememberMe);
    _account = found;
    notifyListeners();
    return true;
  }

  /// Logs out and clears the saved session. The theme choice stays.
  Future<void> logOut() async {
    await _sessionStore.clear();
    _account = null;
    _emailError = null;
    _passwordError = null;
    _bannerError = null;
    notifyListeners();
  }

  static String? _checkEmail(String email) {
    final String cleaned = email.trim();
    if (cleaned.isEmpty) return emailEmptyError;
    final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(cleaned)) return emailFormatError;
    return null;
  }
}
