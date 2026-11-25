import 'package:flutter/services.dart';

/// The small bridge to the Kotlin side in `MainActivity.kt`.
///
/// Two things the notification package cannot tell Harvestly on its own:
/// opening Android's own notification page for this app, and which Android
/// version the phone runs. Both are a few lines of Kotlin, so Harvestly adds
/// no package for them.
class AndroidSettingsChannel {
  const AndroidSettingsChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// The channel name, matching `MainActivity.kt`.
  static const String channelName = 'harvestly/settings';

  /// The first Android version with a runtime notification permission.
  static const int android13 = 33;

  final MethodChannel _channel;

  /// Opens Android's notification page for Harvestly.
  ///
  /// Returns false when the phone has no such page, which no test phone
  /// should hit, and never throws.
  Future<bool> openNotificationSettings() async {
    try {
      final bool? opened = await _channel.invokeMethod<bool>(
        'openNotificationSettings',
      );
      return opened ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// The phone's Android API level, or 0 when it cannot be read.
  ///
  /// Harvestly only needs this to tell "never asked yet" from "turned off",
  /// which only differ from Android 13 on.
  Future<int> sdkInt() async {
    try {
      final int? level = await _channel.invokeMethod<int>('androidSdkInt');
      return level ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }
}
