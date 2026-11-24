import 'package:material_ui/material_ui.dart';

/// One full set of Harvestly colors (light or dark).
///
/// This is the only file in the app that may contain hex color values.
@immutable
class AppColorSet {
  const AppColorSet({
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.link,
    required this.secondary,
    required this.secondarySoft,
    required this.onSecondarySoft,
    required this.tertiary,
    required this.onTertiary,
    required this.warningText,
    required this.error,
  });

  /// Screen behind everything.
  final Color background;

  /// Cards, tab bar, inputs.
  final Color surface;

  /// Card and input outlines.
  final Color border;

  /// Main text.
  final Color text;

  /// Dates, hints, labels.
  final Color textMuted;

  /// Buttons, checkboxes, + button, logo tile.
  final Color primary;

  /// Text and icons on primary.
  final Color onPrimary;

  /// Links, "See all", selected tab.
  final Color link;

  /// Progress bars, chart bars, stat icons.
  final Color secondary;

  /// Chips, icon tiles, progress tracks.
  final Color secondarySoft;

  /// Text and icons on secondarySoft.
  final Color onSecondarySoft;

  /// Notification badge.
  final Color tertiary;

  /// Text on the badge.
  final Color onTertiary;

  /// Warnings like "Rain tomorrow".
  final Color warningText;

  /// Form errors and error banner.
  final Color error;
}

/// Every color token in Harvestly.
class AppColors {
  const AppColors._();

  static const AppColorSet light = AppColorSet(
    background: Color(0xFFF1ECE4),
    surface: Color(0xFFFBF8F3),
    border: Color(0xFFE2DACD),
    text: Color(0xFF17181C),
    textMuted: Color(0xFF5B5852),
    primary: Color(0xFF17181C),
    onPrimary: Color(0xFFFFFFFF),
    link: Color(0xFF2340E6),
    secondary: Color(0xFF2347FF),
    secondarySoft: Color(0xFFE3E8FF),
    onSecondarySoft: Color(0xFF1C35C2),
    tertiary: Color(0xFFFF8A5B),
    onTertiary: Color(0xFF2B0E02),
    warningText: Color(0xFFB5461B),
    error: Color(0xFFB3261E),
  );

  static const AppColorSet dark = AppColorSet(
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1E),
    border: Color(0xFF2E2E31),
    text: Color(0xFFF2F0EC),
    textMuted: Color(0xFFA9A6A0),
    primary: Color(0xFFF2F0EC),
    onPrimary: Color(0xFF121212),
    link: Color(0xFF8FA2FF),
    secondary: Color(0xFF7D93FF),
    secondarySoft: Color(0xFF1C2347),
    onSecondarySoft: Color(0xFFA9B7FF),
    tertiary: Color(0xFFFFA071),
    onTertiary: Color(0xFF2B0E02),
    warningText: Color(0xFFFFA071),
    error: Color(0xFFF2B8B5),
  );
}
