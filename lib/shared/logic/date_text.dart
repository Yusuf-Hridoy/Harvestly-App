/// Turns dates into the short text Harvestly shows on screen.
///
/// Kept in one file so every screen writes a date the same way, and so no
/// screen needs a date formatting package.
class DateText {
  const DateText._();

  static const List<String> _shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "2 Oct 2026".
  static String dayMonthYear(DateTime when) =>
      '${when.day} ${_shortMonths[when.month - 1]} ${when.year}';

  /// "2 Oct", used where the year is not needed.
  static String dayMonth(DateTime when) =>
      '${when.day} ${_shortMonths[when.month - 1]}';
}
