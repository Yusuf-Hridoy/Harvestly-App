import 'package:package_info_plus/package_info_plus.dart';

/// The app version, read from the app itself.
class AppVersion {
  const AppVersion({required this.name, required this.code});

  /// Unknown version, used only when the version cannot be read.
  static const AppVersion unknown = AppVersion(name: '', code: '');

  /// The version name, for example "0.1.0".
  final String name;

  /// The build number, for example "1".
  final String code;

  /// The line shown on the settings screen, for example "Version 0.1.0 (1)".
  String get label =>
      name.isEmpty ? 'Version unknown' : 'Version $name ($code)';
}

/// Reads the version the app was built with.
///
/// Reading it means the number on screen always matches the build, instead of
/// being typed in by hand.
class AppVersionReader {
  const AppVersionReader._();

  static Future<AppVersion> load() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return AppVersion(name: info.version, code: info.buildNumber);
    } catch (_) {
      return AppVersion.unknown;
    }
  }
}
